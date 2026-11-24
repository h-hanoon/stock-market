import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

const double kStartingBalance = 100000.0;

class WalletHolding {
  const WalletHolding({
    required this.symbol,
    required this.quantity,
    required this.averagePurchasePrice,
  });

  final String symbol;
  final double quantity;
  final double averagePurchasePrice;
}

class WalletOverview {
  const WalletOverview({
    required this.uid,
    required this.username,
    required this.virtualBalance,
    required this.portfolioId,
    required this.holdings,
  });

  final String uid;
  final String username;
  final double virtualBalance;
  final String portfolioId;
  final List<WalletHolding> holdings;

  WalletHolding? holdingFor(String symbol) {
    for (final holding in holdings) {
      if (holding.symbol == symbol) return holding;
    }
    return null;
  }
}

class WalletTransactionRecord {
  const WalletTransactionRecord({
    required this.id,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.priceAtExecution,
    required this.timestamp,
  });

  final String id;
  final String symbol;
  final String type;
  final double quantity;
  final double priceAtExecution;
  final DateTime timestamp;
}

class WalletService {
  WalletService._();

  static final WalletService instance = WalletService._();

  SupabaseClient get _db => Supabase.instance.client;

  String get _uid {
    final user = _db.auth.currentUser;
    if (user == null) throw StateError('No signed-in user.');
    return user.id;
  }

  /// Ensures a profile row exists for the signed-in Supabase user, then
  /// returns their current wallet state.
  Future<WalletOverview> ensureWalletProvisioned() async {
    final existing = await getOverview();
    if (existing != null) return existing;

    final user = _db.auth.currentUser;
    if (user == null) throw StateError('No signed-in user.');
    final email = user.email ?? '${user.id}@example.com';
    final username =
        (user.userMetadata?['username'] as String?) ?? email.split('@').first;

    await _run(
      () => _db.rpc(
        'ensure_wallet',
        params: {
          'p_username': username,
          'p_starting_balance': kStartingBalance,
        },
      ),
    );

    final created = await getOverview();
    if (created == null) throw StateError('Failed to provision wallet.');
    return created;
  }

  Future<WalletOverview?> getOverview() async {
    final uid = _uid;
    final profile = await _run(
      () => _db
          .from('profiles')
          .select('id, username, virtual_balance')
          .eq('id', uid)
          .maybeSingle(),
    );
    if (profile == null) return null;
    final holdings = await _run(
      () => _db
          .from('holdings')
          .select('symbol, quantity, average_purchase_price')
          .eq('user_id', uid)
          .order('symbol')
          .limit(200),
    );
    return WalletOverview(
      uid: profile['id'] as String,
      username: profile['username'] as String,
      virtualBalance: (profile['virtual_balance'] as num).toDouble(),
      // Holdings are keyed by user now; there is no separate portfolio row.
      portfolioId: profile['id'] as String,
      holdings: holdings
          .map(
            (h) => WalletHolding(
              symbol: h['symbol'] as String,
              quantity: (h['quantity'] as num).toDouble(),
              averagePurchasePrice: (h['average_purchase_price'] as num)
                  .toDouble(),
            ),
          )
          .toList(),
    );
  }

  /// Live wallet overview: pushes an update whenever the balance or
  /// holdings change on the server (e.g. a buy/sell from any device),
  /// instead of requiring a manual refresh.
  Stream<WalletOverview?> watchOverview() =>
      _watch(getOverview, const ['profiles', 'holdings']);

  Future<List<WalletTransactionRecord>> getTransactionHistory({
    int limit = 20,
  }) async {
    final rows = await _run(
      () => _db
          .from('transactions')
          .select('id, symbol, type, quantity, price_at_execution, timestamp')
          .eq('user_id', _uid)
          .order('timestamp', ascending: false)
          .limit(limit),
    );
    return rows
        .map(
          (t) => WalletTransactionRecord(
            id: t['id'] as String,
            symbol: t['symbol'] as String,
            type: t['type'] as String,
            quantity: (t['quantity'] as num).toDouble(),
            priceAtExecution: (t['price_at_execution'] as num).toDouble(),
            timestamp: DateTime.parse(t['timestamp'] as String).toLocal(),
          ),
        )
        .toList();
  }

  /// Live transaction history: pushes an update whenever a buy/sell
  /// happens, instead of requiring a manual refresh.
  Stream<List<WalletTransactionRecord>> watchTransactionHistory({
    int limit = 20,
  }) =>
      _watch(() => getTransactionHistory(limit: limit), const ['transactions']);

  /// Buys shares. Balance checks, the weighted average price and the
  /// transaction record are handled atomically by the `buy_stock` function.
  Future<WalletOverview> buyStock({
    required String symbol,
    required double quantity,
    required double price,
  }) async {
    final overview = await getOverview();
    if (overview == null) throw StateError('Wallet not provisioned yet.');
    if (quantity * price > overview.virtualBalance) {
      throw Exception('Insufficient balance');
    }
    await _run(
      () => _db.rpc(
        'buy_stock',
        params: {'p_symbol': symbol, 'p_quantity': quantity, 'p_price': price},
      ),
    );
    return await getOverview() ?? overview;
  }

  /// Sells shares via the atomic `sell_stock` function.
  Future<WalletOverview> sellStock({
    required String symbol,
    required double quantity,
    required double price,
  }) async {
    final overview = await getOverview();
    if (overview == null) throw StateError('Wallet not provisioned yet.');
    final existing = overview.holdingFor(symbol);
    if (existing == null || existing.quantity < quantity) {
      throw Exception('Not enough shares to sell');
    }
    await _run(
      () => _db.rpc(
        'sell_stock',
        params: {'p_symbol': symbol, 'p_quantity': quantity, 'p_price': price},
      ),
    );
    return await getOverview() ?? overview;
  }

  /// Emits [fetch] once, then again whenever any of the user's rows in
  /// [tables] change (via Supabase Realtime).
  Stream<T> _watch<T>(Future<T> Function() fetch, List<String> tables) {
    late final StreamController<T> controller;
    RealtimeChannel? channel;

    Future<void> emit() async {
      try {
        final value = await fetch();
        if (!controller.isClosed) controller.add(value);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      }
    }

    controller = StreamController<T>(
      onListen: () {
        final uid = _uid;
        var ch = _db.channel(
          'wallet:${tables.join(',')}:$uid:${DateTime.now().microsecondsSinceEpoch}',
        );
        for (final table in tables) {
          ch = ch.onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: table == 'profiles' ? 'id' : 'user_id',
              value: uid,
            ),
            callback: (_) => emit(),
          );
        }
        channel = ch.subscribe();
        emit();
      },
      onCancel: () async {
        final ch = channel;
        if (ch != null) await _db.removeChannel(ch);
        await controller.close();
      },
    );
    return controller.stream;
  }

  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }
}
