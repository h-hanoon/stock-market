import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_data_connect/firebase_data_connect.dart';

import '../dataconnect_generated/generated.dart';

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

  final ExampleConnector _connector = ExampleConnector.instance;

  /// Ensures a User + Portfolio row exists for the signed-in Firebase Auth
  /// user, then returns their current wallet state.
  Future<WalletOverview> ensureWalletProvisioned() async {
    final existing = await getOverview();
    if (existing != null) return existing;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('No signed-in user.');
    }
    final email = user.email ?? '${user.uid}@example.com';
    final username = user.displayName ?? email.split('@').first;

    await _run(
      () => _connector
          .createWalletProfile(
            username: username,
            email: email,
            startingBalance: kStartingBalance,
          )
          .execute(),
    );

    final created = await getOverview();
    if (created == null) {
      throw StateError('Failed to provision wallet.');
    }
    return created;
  }

  Future<WalletOverview?> getOverview() async {
    final result = await _run(
      () => _connector
          .getWalletOverview()
          .execute(fetchPolicy: QueryFetchPolicy.serverOnly),
    );
    final user = result.data.user;
    if (user == null) return null;
    final portfolio = user.portfolio;
    return WalletOverview(
      uid: user.uid,
      username: user.username,
      virtualBalance: user.virtualBalance,
      portfolioId: portfolio?.id ?? '',
      holdings: (portfolio?.holdings ?? [])
          .map(
            (h) => WalletHolding(
              symbol: h.symbol,
              quantity: h.quantity,
              averagePurchasePrice: h.averagePurchasePrice,
            ),
          )
          .toList(),
    );
  }

  Future<List<WalletTransactionRecord>> getTransactionHistory({
    int limit = 20,
  }) async {
    final result = await _run(
      () => _connector
          .getTransactionHistory()
          .limit(limit)
          .execute(fetchPolicy: QueryFetchPolicy.serverOnly),
    );
    return result.data.transactions
        .map(
          (t) => WalletTransactionRecord(
            id: t.id,
            symbol: t.symbol,
            type: t.type,
            quantity: t.quantity,
            priceAtExecution: t.priceAtExecution,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              t.timestamp.seconds * 1000,
            ),
          ),
        )
        .toList();
  }

  Future<WalletOverview> buyStock({
    required String symbol,
    required double quantity,
    required double price,
  }) async {
    final overview = await getOverview();
    if (overview == null) {
      throw StateError('Wallet not provisioned yet.');
    }
    final cost = quantity * price;
    if (cost > overview.virtualBalance) {
      throw Exception('Insufficient balance');
    }
    final existing = overview.holdingFor(symbol);
    final newHoldingQuantity = (existing?.quantity ?? 0) + quantity;
    final newAveragePrice = existing == null
        ? price
        : ((existing.quantity * existing.averagePurchasePrice) +
                  (quantity * price)) /
              newHoldingQuantity;

    await _run(
      () => _connector
          .buyStock(
            portfolioId: overview.portfolioId,
            symbol: symbol,
            quantity: quantity,
            price: price,
            cost: cost,
            newHoldingQuantity: newHoldingQuantity,
            newAveragePrice: newAveragePrice,
          )
          .execute(),
    );

    final refreshed = await getOverview();
    return refreshed ?? overview;
  }

  Future<WalletOverview> sellStock({
    required String symbol,
    required double quantity,
    required double price,
  }) async {
    final overview = await getOverview();
    if (overview == null) {
      throw StateError('Wallet not provisioned yet.');
    }
    final existing = overview.holdingFor(symbol);
    if (existing == null || existing.quantity < quantity) {
      throw Exception('Not enough shares to sell');
    }
    final proceeds = quantity * price;
    final newHoldingQuantity = existing.quantity - quantity;

    if (newHoldingQuantity <= 0) {
      await _run(
        () => _connector
            .sellStockAll(
              portfolioId: overview.portfolioId,
              symbol: symbol,
              quantity: quantity,
              price: price,
              proceeds: proceeds,
            )
            .execute(),
      );
    } else {
      await _run(
        () => _connector
            .sellStockPartial(
              portfolioId: overview.portfolioId,
              symbol: symbol,
              quantity: quantity,
              price: price,
              proceeds: proceeds,
              newHoldingQuantity: newHoldingQuantity,
            )
            .execute(),
      );
    }

    final refreshed = await getOverview();
    return refreshed ?? overview;
  }

  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DataConnectOperationError catch (e) {
      final message = e.response.errors.isNotEmpty
          ? e.response.errors.first.message
          : e.message;
      throw Exception(message ?? 'Data Connect operation failed');
    }
  }
}
