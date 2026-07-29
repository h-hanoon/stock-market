part of 'generated.dart';

class BuyStockVariablesBuilder {
  String portfolioId;
  String symbol;
  double quantity;
  double price;
  double cost;
  double newHoldingQuantity;
  double newAveragePrice;

  final FirebaseDataConnect _dataConnect;
  BuyStockVariablesBuilder(this._dataConnect, {required  this.portfolioId,required  this.symbol,required  this.quantity,required  this.price,required  this.cost,required  this.newHoldingQuantity,required  this.newAveragePrice,});
  Deserializer<BuyStockData> dataDeserializer = (dynamic json)  => BuyStockData.fromJson(jsonDecode(json));
  Serializer<BuyStockVariables> varsSerializer = (BuyStockVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<BuyStockData, BuyStockVariables>> execute() {
    return ref().execute();
  }

  MutationRef<BuyStockData, BuyStockVariables> ref() {
    BuyStockVariables vars= BuyStockVariables(portfolioId: portfolioId,symbol: symbol,quantity: quantity,price: price,cost: cost,newHoldingQuantity: newHoldingQuantity,newAveragePrice: newAveragePrice,);
    return _dataConnect.mutation("BuyStock", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class BuyStockUserUpdate {
  final String uid;
  BuyStockUserUpdate.fromJson(dynamic json):
  
  uid = nativeFromJson<String>(json['uid']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final BuyStockUserUpdate otherTyped = other as BuyStockUserUpdate;
    return uid == otherTyped.uid;
    
  }
  @override
  int get hashCode => uid.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['uid'] = nativeToJson<String>(uid);
    return json;
  }

  BuyStockUserUpdate({
    required this.uid,
  });
}

@immutable
class BuyStockHoldingUpsert {
  final String portfolioId;
  final String symbol;
  BuyStockHoldingUpsert.fromJson(dynamic json):
  
  portfolioId = nativeFromJson<String>(json['portfolioId']),
  symbol = nativeFromJson<String>(json['symbol']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final BuyStockHoldingUpsert otherTyped = other as BuyStockHoldingUpsert;
    return portfolioId == otherTyped.portfolioId && 
    symbol == otherTyped.symbol;
    
  }
  @override
  int get hashCode => Object.hashAll([portfolioId.hashCode, symbol.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['portfolioId'] = nativeToJson<String>(portfolioId);
    json['symbol'] = nativeToJson<String>(symbol);
    return json;
  }

  BuyStockHoldingUpsert({
    required this.portfolioId,
    required this.symbol,
  });
}

@immutable
class BuyStockTransactionInsert {
  final String id;
  BuyStockTransactionInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final BuyStockTransactionInsert otherTyped = other as BuyStockTransactionInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  BuyStockTransactionInsert({
    required this.id,
  });
}

@immutable
class BuyStockData {
  final BuyStockUserUpdate? user_update;
  final BuyStockHoldingUpsert holding_upsert;
  final BuyStockTransactionInsert transaction_insert;
  BuyStockData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : BuyStockUserUpdate.fromJson(json['user_update']),
  holding_upsert = BuyStockHoldingUpsert.fromJson(json['holding_upsert']),
  transaction_insert = BuyStockTransactionInsert.fromJson(json['transaction_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final BuyStockData otherTyped = other as BuyStockData;
    return user_update == otherTyped.user_update && 
    holding_upsert == otherTyped.holding_upsert && 
    transaction_insert == otherTyped.transaction_insert;
    
  }
  @override
  int get hashCode => Object.hashAll([user_update.hashCode, holding_upsert.hashCode, transaction_insert.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user_update != null) {
      json['user_update'] = user_update!.toJson();
    }
    json['holding_upsert'] = holding_upsert.toJson();
    json['transaction_insert'] = transaction_insert.toJson();
    return json;
  }

  BuyStockData({
    this.user_update,
    required this.holding_upsert,
    required this.transaction_insert,
  });
}

@immutable
class BuyStockVariables {
  final String portfolioId;
  final String symbol;
  final double quantity;
  final double price;
  final double cost;
  final double newHoldingQuantity;
  final double newAveragePrice;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  BuyStockVariables.fromJson(Map<String, dynamic> json):
  
  portfolioId = nativeFromJson<String>(json['portfolioId']),
  symbol = nativeFromJson<String>(json['symbol']),
  quantity = nativeFromJson<double>(json['quantity']),
  price = nativeFromJson<double>(json['price']),
  cost = nativeFromJson<double>(json['cost']),
  newHoldingQuantity = nativeFromJson<double>(json['newHoldingQuantity']),
  newAveragePrice = nativeFromJson<double>(json['newAveragePrice']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final BuyStockVariables otherTyped = other as BuyStockVariables;
    return portfolioId == otherTyped.portfolioId && 
    symbol == otherTyped.symbol && 
    quantity == otherTyped.quantity && 
    price == otherTyped.price && 
    cost == otherTyped.cost && 
    newHoldingQuantity == otherTyped.newHoldingQuantity && 
    newAveragePrice == otherTyped.newAveragePrice;
    
  }
  @override
  int get hashCode => Object.hashAll([portfolioId.hashCode, symbol.hashCode, quantity.hashCode, price.hashCode, cost.hashCode, newHoldingQuantity.hashCode, newAveragePrice.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['portfolioId'] = nativeToJson<String>(portfolioId);
    json['symbol'] = nativeToJson<String>(symbol);
    json['quantity'] = nativeToJson<double>(quantity);
    json['price'] = nativeToJson<double>(price);
    json['cost'] = nativeToJson<double>(cost);
    json['newHoldingQuantity'] = nativeToJson<double>(newHoldingQuantity);
    json['newAveragePrice'] = nativeToJson<double>(newAveragePrice);
    return json;
  }

  BuyStockVariables({
    required this.portfolioId,
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.cost,
    required this.newHoldingQuantity,
    required this.newAveragePrice,
  });
}

