import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class Stock {
  const Stock({required this.symbol, required this.price});

  final String symbol;
  final double price;
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
    final response = await http.get(Uri.parse('$_baseUrl/exchange_rate/$symbol'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load quote for $symbol (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Stock(symbol: symbol, price: (data['rate'] as num).toDouble());
  }

  Future<List<Stock>> fetchQuotes(List<String> symbols) {
    return Future.wait(symbols.map(fetchQuote));
  }
}
