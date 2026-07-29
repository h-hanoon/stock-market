library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_wallet_profile.dart';

part 'buy_stock.dart';

part 'sell_stock_partial.dart';

part 'sell_stock_all.dart';

part 'get_wallet_overview.dart';

part 'get_transaction_history.dart';







class ExampleConnector {
  
  
  CreateWalletProfileVariablesBuilder createWalletProfile ({required String username, required String email, required double startingBalance, }) {
    return CreateWalletProfileVariablesBuilder(dataConnect, username: username,email: email,startingBalance: startingBalance,);
  }
  
  
  BuyStockVariablesBuilder buyStock ({required String portfolioId, required String symbol, required double quantity, required double price, required double cost, required double newHoldingQuantity, required double newAveragePrice, }) {
    return BuyStockVariablesBuilder(dataConnect, portfolioId: portfolioId,symbol: symbol,quantity: quantity,price: price,cost: cost,newHoldingQuantity: newHoldingQuantity,newAveragePrice: newAveragePrice,);
  }
  
  
  SellStockPartialVariablesBuilder sellStockPartial ({required String portfolioId, required String symbol, required double quantity, required double price, required double proceeds, required double newHoldingQuantity, }) {
    return SellStockPartialVariablesBuilder(dataConnect, portfolioId: portfolioId,symbol: symbol,quantity: quantity,price: price,proceeds: proceeds,newHoldingQuantity: newHoldingQuantity,);
  }
  
  
  SellStockAllVariablesBuilder sellStockAll ({required String portfolioId, required String symbol, required double quantity, required double price, required double proceeds, }) {
    return SellStockAllVariablesBuilder(dataConnect, portfolioId: portfolioId,symbol: symbol,quantity: quantity,price: price,proceeds: proceeds,);
  }
  
  
  GetWalletOverviewVariablesBuilder getWalletOverview () {
    return GetWalletOverviewVariablesBuilder(dataConnect, );
  }
  
  
  GetTransactionHistoryVariablesBuilder getTransactionHistory () {
    return GetTransactionHistoryVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'europe-west9',
    'example',
    'financial-fdfb8-service',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    
    CacheSettings cacheSettings = CacheSettings(
      maxAge: Duration(milliseconds:0),
      storage: CacheStorage.persistent,
    );
    
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            
            cacheSettings: cacheSettings,
            
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
