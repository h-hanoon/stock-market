part of 'generated.dart';

class SellStockPartialVariablesBuilder {
  String portfolioId;
  String symbol;
  double quantity;
  double price;
  double proceeds;
  double newHoldingQuantity;

  final FirebaseDataConnect _dataConnect;
  SellStockPartialVariablesBuilder(this._dataConnect, {required  this.portfolioId,required  this.symbol,required  this.quantity,required  this.price,required  this.proceeds,required  this.newHoldingQuantity,});
  Deserializer<SellStockPartialData> dataDeserializer = (dynamic json)  => SellStockPartialData.fromJson(jsonDecode(json));
  Serializer<SellStockPartialVariables> varsSerializer = (SellStockPartialVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<SellStockPartialData, SellStockPartialVariables>> execute() {
    return ref().execute();
  }

  MutationRef<SellStockPartialData, SellStockPartialVariables> ref() {
    SellStockPartialVariables vars= SellStockPartialVariables(portfolioId: portfolioId,symbol: symbol,quantity: quantity,price: price,proceeds: proceeds,newHoldingQuantity: newHoldingQuantity,);
    return _dataConnect.mutation("SellStockPartial", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class SellStockPartialUserUpdate {
  final String uid;
  SellStockPartialUserUpdate.fromJson(dynamic json):
  
  uid = nativeFromJson<String>(json['uid']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SellStockPartialUserUpdate otherTyped = other as SellStockPartialUserUpdate;
    return uid == otherTyped.uid;
    
  }
  @override
  int get hashCode => uid.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['uid'] = nativeToJson<String>(uid);
    return json;
  }

  SellStockPartialUserUpdate({
    required this.uid,
  });
}

@immutable
class SellStockPartialHoldingUpdate {
  final String portfolioId;
  final String symbol;
  SellStockPartialHoldingUpdate.fromJson(dynamic json):
  
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

    final SellStockPartialHoldingUpdate otherTyped = other as SellStockPartialHoldingUpdate;
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

  SellStockPartialHoldingUpdate({
    required this.portfolioId,
    required this.symbol,
  });
}

@immutable
class SellStockPartialTransactionInsert {
  final String id;
  SellStockPartialTransactionInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SellStockPartialTransactionInsert otherTyped = other as SellStockPartialTransactionInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SellStockPartialTransactionInsert({
    required this.id,
  });
}

@immutable
class SellStockPartialData {
  final SellStockPartialUserUpdate? user_update;
  final SellStockPartialHoldingUpdate? holding_update;
  final SellStockPartialTransactionInsert transaction_insert;
  SellStockPartialData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : SellStockPartialUserUpdate.fromJson(json['user_update']),
  holding_update = json['holding_update'] == null ? null : SellStockPartialHoldingUpdate.fromJson(json['holding_update']),
  transaction_insert = SellStockPartialTransactionInsert.fromJson(json['transaction_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SellStockPartialData otherTyped = other as SellStockPartialData;
    return user_update == otherTyped.user_update && 
    holding_update == otherTyped.holding_update && 
    transaction_insert == otherTyped.transaction_insert;
    
  }
  @override
  int get hashCode => Object.hashAll([user_update.hashCode, holding_update.hashCode, transaction_insert.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user_update != null) {
      json['user_update'] = user_update!.toJson();
    }
    if (holding_update != null) {
      json['holding_update'] = holding_update!.toJson();
    }
    json['transaction_insert'] = transaction_insert.toJson();
    return json;
  }

  SellStockPartialData({
    this.user_update,
    this.holding_update,
    required this.transaction_insert,
  });
}

@immutable
class SellStockPartialVariables {
  final String portfolioId;
  final String symbol;
  final double quantity;
  final double price;
  final double proceeds;
  final double newHoldingQuantity;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  SellStockPartialVariables.fromJson(Map<String, dynamic> json):
  
  portfolioId = nativeFromJson<String>(json['portfolioId']),
  symbol = nativeFromJson<String>(json['symbol']),
  quantity = nativeFromJson<double>(json['quantity']),
  price = nativeFromJson<double>(json['price']),
  proceeds = nativeFromJson<double>(json['proceeds']),
  newHoldingQuantity = nativeFromJson<double>(json['newHoldingQuantity']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SellStockPartialVariables otherTyped = other as SellStockPartialVariables;
    return portfolioId == otherTyped.portfolioId && 
    symbol == otherTyped.symbol && 
    quantity == otherTyped.quantity && 
    price == otherTyped.price && 
    proceeds == otherTyped.proceeds && 
    newHoldingQuantity == otherTyped.newHoldingQuantity;
    
  }
  @override
  int get hashCode => Object.hashAll([portfolioId.hashCode, symbol.hashCode, quantity.hashCode, price.hashCode, proceeds.hashCode, newHoldingQuantity.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['portfolioId'] = nativeToJson<String>(portfolioId);
    json['symbol'] = nativeToJson<String>(symbol);
    json['quantity'] = nativeToJson<double>(quantity);
    json['price'] = nativeToJson<double>(price);
    json['proceeds'] = nativeToJson<double>(proceeds);
    json['newHoldingQuantity'] = nativeToJson<double>(newHoldingQuantity);
    return json;
  }

  SellStockPartialVariables({
    required this.portfolioId,
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.proceeds,
    required this.newHoldingQuantity,
  });
}

