import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class Stock {
  const Stock({required this.symbol, required this.price});

  final String symbol;
  final double price;
}

class StockHistoryPoint {
  const StockHistoryPoint({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory StockHistoryPoint.fromJson(Map<String, dynamic> json) {
    return StockHistoryPoint(
      date: DateTime.parse(json['date'] as String),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );
  }

  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
}

class StockService {
  StockService._();

  static final StockService instance = StockService._();

  static String get _baseUrl {
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:5001';
    return 'http://127.0.0.1:5001';
  }

  Future<List<String>> fetchSymbols() async {
    final response = await http.get(Uri.parse('$_baseUrl/stocks_list'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load stock symbols (${response.statusCode})');
    }
    return (jsonDecode(response.body) as List).cast<String>();
  }

  Future<Stock> fetchQuote(String symbol) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/exchange_rate/$symbol'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load quote for $symbol (${response.statusCode})',
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Stock(symbol: symbol, price: (data['rate'] as num).toDouble());
  }

  Future<List<Stock>> fetchQuotes(List<String> symbols) {
    return Future.wait(symbols.map(fetchQuote));
  }

  Future<List<StockHistoryPoint>> fetchHistory(
    String symbol, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final uri = Uri.parse('$_baseUrl/hist/$symbol').replace(
      queryParameters: {
        'start_date': _formatDate(startDate),
        'end_date': _formatDate(endDate),
      },
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load history for $symbol (${response.statusCode})',
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final values = (data['values'] as List).cast<Map<String, dynamic>>();
    return values.map(StockHistoryPoint.fromJson).toList();
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
