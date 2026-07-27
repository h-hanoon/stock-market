import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/stock_service.dart';

const _bullGreen = Color(0xFF2ECC71);
const _bearRed = Color(0xFFE74C3C);
const _bgTop = Color(0xFF0B0F14);
const _bgBottom = Color(0xFF121A24);
const _initialBalance = 1000000.0;
const _watchlistSize = 20;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = StockService.instance;
  final Map<String, double> _previousPrices = {};

  List<Stock>? _stocks;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadStocks();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refreshQuotes());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStocks() async {
    setState(() => _error = null);
    try {
      final symbols = await _service.fetchSymbols();
      final selected = symbols.take(_watchlistSize).toList();
      final stocks = await _service.fetchQuotes(selected);
      if (!mounted) return;
      setState(() => _stocks = stocks);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not reach the mock stock server.\n$e');
    }
  }

  Future<void> _refreshQuotes() async {
    final current = _stocks;
    if (current == null) return;
    try {
      final refreshed = await _service.fetchQuotes(current.map((s) => s.symbol).toList());
      if (!mounted) return;
      setState(() {
        for (final stock in current) {
          _previousPrices[stock.symbol] = stock.price;
        }
        _stocks = refreshed;
      });
    } catch (_) {
      // Keep showing the last known quotes if a background refresh fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: _bgTop,
      appBar: AppBar(
        backgroundColor: _bgTop,
        title: const Text('Bull & Bear Markets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStocks,
        color: _bullGreen,
        backgroundColor: _bgBottom,
        child: _buildBody(email),
      ),
      bottomNavigationBar: const _BalanceBar(balance: _initialBalance),
    );
  }

  Widget _buildBody(String email) {
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _loadStocks);
    }
    final stocks = _stocks;
    if (stocks == null) {
      return const Center(child: CircularProgressIndicator(color: _bullGreen));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: stocks.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Welcome, $email',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
            ),
          );
        }
        final stock = stocks[index - 1];
        return _StockTile(stock: stock, previousPrice: _previousPrices[stock.symbol]);
      },
    );
  }
}

class _StockTile extends StatelessWidget {
  const _StockTile({required this.stock, required this.previousPrice});

  final Stock stock;
  final double? previousPrice;

  @override
  Widget build(BuildContext context) {
    final change = previousPrice == null ? 0.0 : stock.price - previousPrice!;
    final changePct = (previousPrice == null || previousPrice == 0)
        ? 0.0
        : (change / previousPrice!) * 100;
    final isUp = change >= 0;
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
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stock.symbol,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${stock.price.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              if (previousPrice != null)
                Text(
                  '${isUp ? '+' : ''}${changePct.toStringAsFixed(2)}%',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceBar extends StatelessWidget {
  const _BalanceBar({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgBottom,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: _bullGreen, size: 22),
              const SizedBox(width: 10),
              Text(
                'Available balance',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
              const Spacer(),
              Text(
                '\$${_formatBalance(balance)}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatBalance(double value) {
    final intPart = value.toInt().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i != 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '$buffer.00';
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
              style: ElevatedButton.styleFrom(backgroundColor: _bullGreen, foregroundColor: Colors.black),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
