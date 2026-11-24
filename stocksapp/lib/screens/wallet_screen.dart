import 'dart:async';

import 'package:flutter/material.dart';

import '../services/stock_service.dart';
import '../services/wallet_service.dart';

const _priceRefreshInterval = Duration(seconds: 5);

const _bullGreen = Color(0xFF2ECC71);
const _bearRed = Color(0xFFE74C3C);
const _bgTop = Color(0xFF0B0F14);
const _bgBottom = Color(0xFF121A24);

const _sectionTitleStyle = TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontWeight: FontWeight.w700,
);

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _wallet = WalletService.instance;
  final _stocks = StockService.instance;

  StreamSubscription<WalletOverview?>? _overviewSub;
  StreamSubscription<List<WalletTransactionRecord>>? _transactionsSub;
  Timer? _priceTimer;

  WalletOverview? _overview;
  Map<String, double> _livePrices = {};
  List<WalletTransactionRecord>? _transactions;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _overviewSub?.cancel();
    _transactionsSub?.cancel();
    _priceTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _error = null);
    try {
      await _wallet.ensureWalletProvisioned();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not load wallet.\n$e');
      return;
    }
    if (!mounted) return;

    // Live subscriptions: balance/holdings/transactions update as soon as
    // the server sees a buy or sell, from this device or any other.
    _overviewSub = _wallet.watchOverview().listen(
      (overview) {
        if (!mounted) return;
        setState(() {
          _overview = overview;
          _error = null;
        });
        _refreshPrices();
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _error = 'Could not load wallet.\n$e');
      },
    );
    _transactionsSub = _wallet.watchTransactionHistory().listen((transactions) {
      if (!mounted) return;
      setState(() => _transactions = transactions);
    });

    // Holdings are priced off the mock market feed, which isn't pushed by
    // Data Connect, so poll it on an interval to keep market value live.
    _priceTimer = Timer.periodic(
      _priceRefreshInterval,
      (_) => _refreshPrices(),
    );
  }

  Future<void> _refreshPrices() async {
    final symbols = _overview?.holdings.map((h) => h.symbol).toList() ?? [];
    if (symbols.isEmpty) return;
    try {
      final quotes = await _stocks.fetchQuotes(symbols);
      if (!mounted) return;
      setState(() {
        _livePrices = {for (final q in quotes) q.symbol: q.price};
      });
    } catch (_) {
      // Keep showing last known prices if a background refresh fails.
    }
  }

  Future<void> _sell(WalletHolding holding) async {
    final price = _livePrices[holding.symbol] ?? holding.averagePurchasePrice;
    final quantity = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: _bgBottom,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SellSheet(holding: holding, price: price),
    );
    if (quantity == null || quantity <= 0) return;
    try {
      await _wallet.sellStock(
        symbol: holding.symbol,
        quantity: quantity,
        price: price,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sold ${quantity.toStringAsFixed(4)} ${holding.symbol}',
          ),
        ),
      );
      // The overview/transaction streams will push the update; the sold
      // holding's price still needs a fresh quote for the summary above.
      _refreshPrices();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: _bearRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgTop,
      appBar: AppBar(backgroundColor: _bgTop, title: const Text('Wallet')),
      body: RefreshIndicator(
        onRefresh: _refreshPrices,
        color: _bullGreen,
        backgroundColor: _bgBottom,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _init);
    }
    final overview = _overview;
    final transactions = _transactions;
    if (overview == null || transactions == null) {
      return const Center(child: CircularProgressIndicator(color: _bullGreen));
    }

    final holdingsValue = overview.holdings.fold<double>(
      0,
      (sum, h) =>
          sum + h.quantity * (_livePrices[h.symbol] ?? h.averagePurchasePrice),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _BalanceHeader(
          cash: overview.virtualBalance,
          holdingsValue: holdingsValue,
        ),
        const SizedBox(height: 24),
        const Text('Holdings', style: _sectionTitleStyle),
        const SizedBox(height: 12),
        if (overview.holdings.isEmpty)
          const _EmptyState(
            text:
                "You don't own any stocks yet.\nBuy some from a stock's chart page.",
          )
        else
          ...overview.holdings.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HoldingTile(
                holding: h,
                currentPrice: _livePrices[h.symbol] ?? h.averagePurchasePrice,
                onSell: () => _sell(h),
              ),
            ),
          ),
        const SizedBox(height: 24),
        const Text('Recent activity', style: _sectionTitleStyle),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const _EmptyState(text: 'No transactions yet.')
        else
          ...transactions.map((t) => _TransactionTile(transaction: t)),
      ],
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.cash, required this.holdingsValue});

  final double cash;
  final double holdingsValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_bullGreen.withValues(alpha: 0.18), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total portfolio value',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${_formatMoney(cash + holdingsValue)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Cash',
                value: '\$${_formatMoney(cash)}',
              ),
              const SizedBox(width: 10),
              _statChip(
                icon: Icons.pie_chart_rounded,
                label: 'Holdings',
                value: '\$${_formatMoney(holdingsValue)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: _bullGreen, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldingTile extends StatelessWidget {
  const _HoldingTile({
    required this.holding,
    required this.currentPrice,
    required this.onSell,
  });

  final WalletHolding holding;
  final double currentPrice;
  final VoidCallback onSell;

  @override
  Widget build(BuildContext context) {
    final marketValue = holding.quantity * currentPrice;
    final costBasis = holding.quantity * holding.averagePurchasePrice;
    final gain = marketValue - costBasis;
    final gainPct = costBasis == 0 ? 0.0 : (gain / costBasis) * 100;
    final isUp = gain >= 0;
    final color = isUp ? _bullGreen : _bearRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${holding.quantity.toStringAsFixed(4)} sh · avg \$${holding.averagePurchasePrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_formatMoney(marketValue)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${isUp ? '+' : ''}${gainPct.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onSell,
            style: OutlinedButton.styleFrom(
              foregroundColor: _bearRed,
              side: const BorderSide(color: _bearRed),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Sell'),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final WalletTransactionRecord transaction;

  @override
  Widget build(BuildContext context) {
    final isBuy = transaction.type == 'BUY';
    final color = isBuy ? _bullGreen : _bearRed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBuy ? Icons.add_rounded : Icons.remove_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isBuy ? 'Bought' : 'Sold'} ${transaction.symbol}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  _formatDate(transaction.timestamp),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.quantity.toStringAsFixed(4)} @ \$${transaction.priceAtExecution.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SellSheet extends StatefulWidget {
  const _SellSheet({required this.holding, required this.price});

  final WalletHolding holding;
  final double price;

  @override
  State<_SellSheet> createState() => _SellSheetState();
}

class _SellSheetState extends State<_SellSheet> {
  final _controller = TextEditingController();

  double get _quantity => double.tryParse(_controller.text) ?? 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxQuantity = widget.holding.quantity;
    final proceeds = _quantity * widget.price;
    final isValid = _quantity > 0 && _quantity <= maxQuantity;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sell ${widget.holding.symbol}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You own ${maxQuantity.toStringAsFixed(4)} sh · \$${widget.price.toStringAsFixed(2)}/sh',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Quantity',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              suffixText: 'sh',
              suffixStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _bearRed),
              ),
              suffixIcon: TextButton(
                onPressed: () =>
                    setState(() => _controller.text = maxQuantity.toString()),
                child: const Text('MAX'),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Estimated proceeds',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
              const Spacer(),
              Text(
                '\$${_formatMoney(proceeds)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isValid
                  ? () => Navigator.of(context).pop(_quantity)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _bearRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Confirm sell'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: _bearRed, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _bullGreen,
                foregroundColor: Colors.black,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatMoney(double value) {
  final isNegative = value < 0;
  final intPart = value.abs().toInt().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i != 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(intPart[i]);
  }
  final cents = (value.abs() * 100).round() % 100;
  return '${isNegative ? '-' : ''}$buffer.${cents.toString().padLeft(2, '0')}';
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$month/$day $hour:$minute';
}
