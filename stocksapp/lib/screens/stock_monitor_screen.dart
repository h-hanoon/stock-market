import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/stock_service.dart';
import '../services/wallet_service.dart';

const _bullGreen = Color(0xFF2ECC71);
const _bearRed = Color(0xFFE74C3C);
const _bgTop = Color(0xFF0B0F14);
const _bgBottom = Color(0xFF121A24);
const _historyDays = 90;

enum _ChartType { line, candles, volume }

class StockMonitorScreen extends StatefulWidget {
  const StockMonitorScreen({super.key, required this.stock});

  final Stock stock;

  @override
  State<StockMonitorScreen> createState() => _StockMonitorScreenState();
}

class _StockMonitorScreenState extends State<StockMonitorScreen> {
  final _service = StockService.instance;

  List<StockHistoryPoint>? _history;
  String? _error;
  _ChartType _chartType = _ChartType.line;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _error = null);
    try {
      final now = DateTime.now();
      final history = await _service.fetchHistory(
        widget.stock.symbol,
        startDate: now.subtract(const Duration(days: _historyDays)),
        endDate: now,
      );
      if (!mounted) return;
      setState(() => _history = history);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _error = 'Could not load history for ${widget.stock.symbol}.\n$e',
      );
    }
  }

  Future<void> _buy() async {
    final wallet = WalletService.instance;
    WalletOverview overview;
    try {
      overview = await wallet.ensureWalletProvisioned();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: _bearRed));
      return;
    }
    if (!mounted) return;

    final quantity = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: _bgBottom,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BuySheet(stock: widget.stock, balance: overview.virtualBalance),
    );
    if (quantity == null || quantity <= 0) return;

    try {
      await wallet.buyStock(
        symbol: widget.stock.symbol,
        quantity: quantity,
        price: widget.stock.price,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bought ${quantity.toStringAsFixed(4)} ${widget.stock.symbol}',
          ),
        ),
      );
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
      appBar: AppBar(backgroundColor: _bgTop, title: Text(widget.stock.symbol)),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: _bullGreen,
        backgroundColor: _bgBottom,
        child: _buildBody(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _buy,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: Text('Buy ${widget.stock.symbol}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _bullGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _loadHistory);
    }
    final history = _history;
    if (history == null) {
      return const Center(child: CircularProgressIndicator(color: _bullGreen));
    }
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'No historical data available.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _PriceHeader(stock: widget.stock, history: history),
        const SizedBox(height: 20),
        _ChartTypeSelector(
          selected: _chartType,
          onChanged: (type) => setState(() => _chartType = type),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 320,
          child: switch (_chartType) {
            _ChartType.line => _LineChart(history: history),
            _ChartType.candles => _CandlestickChart(history: history),
            _ChartType.volume => _VolumeChart(history: history),
          },
        ),
      ],
    );
  }
}

class _PriceHeader extends StatelessWidget {
  const _PriceHeader({required this.stock, required this.history});

  final Stock stock;
  final List<StockHistoryPoint> history;

  @override
  Widget build(BuildContext context) {
    final first = history.first.close;
    final last = history.last.close;
    final change = last - first;
    final changePct = first == 0 ? 0.0 : (change / first) * 100;
    final isUp = change >= 0;
    final color = isUp ? _bullGreen : _bearRed;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${stock.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${isUp ? '+' : ''}${change.toStringAsFixed(2)} (${changePct.toStringAsFixed(2)}%) · ${_historyDays}d',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Icon(
          isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: color,
          size: 32,
        ),
      ],
    );
  }
}

class _ChartTypeSelector extends StatelessWidget {
  const _ChartTypeSelector({required this.selected, required this.onChanged});

  final _ChartType selected;
  final ValueChanged<_ChartType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _segment('Line', Icons.show_chart_rounded, _ChartType.line),
        const SizedBox(width: 8),
        _segment(
          'Candles',
          Icons.candlestick_chart_rounded,
          _ChartType.candles,
        ),
        const SizedBox(width: 8),
        _segment('Volume', Icons.bar_chart_rounded, _ChartType.volume),
      ],
    );
  }

  Widget _segment(String label, IconData icon, _ChartType type) {
    final isSelected = selected == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? _bullGreen.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? _bullGreen
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? _bullGreen : Colors.white70,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _bullGreen : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.history});

  final List<StockHistoryPoint> history;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < history.length; i++)
        FlSpot(i.toDouble(), history[i].close),
    ];
    final minY = history.map((p) => p.close).reduce(min);
    final maxY = history.map((p) => p.close).reduce(max);
    final padding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _titlesData(history),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              final point = history[s.x.toInt()];
              return LineTooltipItem(
                '\$${point.close.toStringAsFixed(2)}\n${DateFormat.MMMd().format(point.date)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _bullGreen,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: _bullGreen.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeChart extends StatelessWidget {
  const _VolumeChart({required this.history});

  final List<StockHistoryPoint> history;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: _titlesData(history),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final point = history[group.x];
              return BarTooltipItem(
                '${point.volume.toStringAsFixed(0)}\n${DateFormat.MMMd().format(point.date)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        barGroups: [
          for (var i = 0; i < history.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: history[i].volume,
                  color: history[i].close >= history[i].open
                      ? _bullGreen
                      : _bearRed,
                  width: max(2, 500 / history.length),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CandlestickChart extends StatelessWidget {
  const _CandlestickChart({required this.history});

  final List<StockHistoryPoint> history;

  @override
  Widget build(BuildContext context) {
    final minY = history.map((p) => p.low).reduce(min);
    final maxY = history.map((p) => p.high).reduce(max);
    final padding = (maxY - minY) * 0.1;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CustomPaint(
              size: Size.infinite,
              painter: _CandlestickPainter(
                history: history,
                minY: minY - padding,
                maxY: maxY + padding,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _DateAxisLabels(history: history),
      ],
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter({
    required this.history,
    required this.minY,
    required this.maxY,
  });

  final List<StockHistoryPoint> history;
  final double minY;
  final double maxY;

  @override
  void paint(Canvas canvas, Size size) {
    final range = max(maxY - minY, 0.0001);
    final candleWidth = size.width / history.length;

    double yFor(double value) =>
        size.height - ((value - minY) / range) * size.height;

    for (var i = 0; i < history.length; i++) {
      final point = history[i];
      final x = candleWidth * i + candleWidth / 2;
      final isBull = point.close >= point.open;
      final color = isBull ? _bullGreen : _bearRed;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 1.2;

      canvas.drawLine(
        Offset(x, yFor(point.high)),
        Offset(x, yFor(point.low)),
        paint,
      );

      final top = yFor(max(point.open, point.close));
      final bottom = yFor(min(point.open, point.close));
      canvas.drawRect(
        Rect.fromLTWH(
          x - candleWidth * 0.3,
          top,
          candleWidth * 0.6,
          max(bottom - top, 1.5),
        ),
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) =>
      oldDelegate.history != history ||
      oldDelegate.minY != minY ||
      oldDelegate.maxY != maxY;
}

class _DateAxisLabels extends StatelessWidget {
  const _DateAxisLabels({required this.history});

  final List<StockHistoryPoint> history;

  @override
  Widget build(BuildContext context) {
    const labelCount = 4;
    final indices = [
      for (var i = 0; i < labelCount; i++)
        (history.length - 1) * i ~/ (labelCount - 1),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final i in indices)
          Text(
            DateFormat.MMMd().format(history[i].date),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
      ],
    );
  }
}

FlTitlesData _titlesData(List<StockHistoryPoint> history) {
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 44,
        getTitlesWidget: (value, meta) => Text(
          value >= 1000
              ? '${(value / 1000).toStringAsFixed(1)}k'
              : value.toStringAsFixed(0),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 24,
        interval: max(1, (history.length / 4).floorToDouble()),
        getTitlesWidget: (value, meta) {
          final index = value.round();
          if (index < 0 || index >= history.length) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              DateFormat.MMMd().format(history[index].date),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _BuySheet extends StatefulWidget {
  const _BuySheet({required this.stock, required this.balance});

  final Stock stock;
  final double balance;

  @override
  State<_BuySheet> createState() => _BuySheetState();
}

class _BuySheetState extends State<_BuySheet> {
  final _controller = TextEditingController();

  double get _quantity => double.tryParse(_controller.text) ?? 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxAffordable = widget.stock.price == 0
        ? 0.0
        : widget.balance / widget.stock.price;
    final cost = _quantity * widget.stock.price;
    final isValid = _quantity > 0 && cost <= widget.balance;

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
            'Buy ${widget.stock.symbol}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Balance \$${widget.balance.toStringAsFixed(2)} · \$${widget.stock.price.toStringAsFixed(2)}/sh',
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
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _bullGreen),
              ),
              suffixIcon: TextButton(
                onPressed: () => setState(
                  () => _controller.text = maxAffordable.toStringAsFixed(4),
                ),
                child: const Text('MAX'),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Estimated cost',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
              const Spacer(),
              Text(
                '\$${cost.toStringAsFixed(2)}',
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
                backgroundColor: _bullGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Confirm buy'),
            ),
          ),
        ],
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
