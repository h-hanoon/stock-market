part of 'generated.dart';

class SellStockAllVariablesBuilder {
  String portfolioId;
  String symbol;
  double quantity;
  double price;
  double proceeds;

  final FirebaseDataConnect _dataConnect;
  SellStockAllVariablesBuilder(this._dataConnect, {required  this.portfolioId,required  this.symbol,required  this.quantity,required  this.price,required  this.proceeds,});
  Deserializer<SellStockAllData> dataDeserializer = (dynamic json)  => SellStockAllData.fromJson(jsonDecode(json));
  Serializer<SellStockAllVariables> varsSerializer = (SellStockAllVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<SellStockAllData, SellStockAllVariables>> execute() {
    return ref().execute();
  }

  MutationRef<SellStockAllData, SellStockAllVariables> ref() {
    SellStockAllVariables vars= SellStockAllVariables(portfolioId: portfolioId,symbol: symbol,quantity: quantity,price: price,proceeds: proceeds,);
    return _dataConnect.mutation("SellStockAll", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class SellStockAllUserUpdate {
  final String uid;
  SellStockAllUserUpdate.fromJson(dynamic json):
  
  uid = nativeFromJson<String>(json['uid']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SellStockAllUserUpdate otherTyped = other as SellStockAllUserUpdate;
    return uid == otherTyped.uid;
    
  }
  @override
  int get hashCode => uid.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['uid'] = nativeToJson<String>(uid);
    return json;
  }

  SellStockAllUserUpdate({
    required this.uid,
  });
}

@immutable
class SellStockAllHoldingDelete {
  final String portfolioId;
  final String symbol;
  SellStockAllHoldingDelete.fromJson(dynamic json):
  
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

    final SellStockAllHoldingDelete otherTyped = other as SellStockAllHoldingDelete;
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

  SellStockAllHoldingDelete({
    required this.portfolioId,
    required this.symbol,
  });
}

@immutable
class SellStockAllTransactionInsert {
  final String id;
  SellStockAllTransactionInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SellStockAllTransactionInsert otherTyped = other as SellStockAllTransactionInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  SellStockAllTransactionInsert({
    required this.id,
  });
}

@immutable
class SellStockAllData {
  final SellStockAllUserUpdate? user_update;
  final SellStockAllHoldingDelete? holding_delete;
  final SellStockAllTransactionInsert transaction_insert;
  SellStockAllData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : SellStockAllUserUpdate.fromJson(json['user_update']),
  holding_delete = json['holding_delete'] == null ? null : SellStockAllHoldingDelete.fromJson(json['holding_delete']),
  transaction_insert = SellStockAllTransactionInsert.fromJson(json['transaction_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SellStockAllData otherTyped = other as SellStockAllData;
    return user_update == otherTyped.user_update && 
    holding_delete == otherTyped.holding_delete && 
    transaction_insert == otherTyped.transaction_insert;
    
  }
  @override
  int get hashCode => Object.hashAll([user_update.hashCode, holding_delete.hashCode, transaction_insert.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user_update != null) {
      json['user_update'] = user_update!.toJson();
    }
    if (holding_delete != null) {
      json['holding_delete'] = holding_delete!.toJson();
    }
    json['transaction_insert'] = transaction_insert.toJson();
    return json;
  }

  SellStockAllData({
    this.user_update,
    this.holding_delete,
    required this.transaction_insert,
  });
}

@immutable
class SellStockAllVariables {
  final String portfolioId;
  final String symbol;
  final double quantity;
  final double price;
  final double proceeds;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  SellStockAllVariables.fromJson(Map<String, dynamic> json):
  
  portfolioId = nativeFromJson<String>(json['portfolioId']),
  symbol = nativeFromJson<String>(json['symbol']),
  quantity = nativeFromJson<double>(json['quantity']),
  price = nativeFromJson<double>(json['price']),
  proceeds = nativeFromJson<double>(json['proceeds']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SellStockAllVariables otherTyped = other as SellStockAllVariables;
    return portfolioId == otherTyped.portfolioId && 
    symbol == otherTyped.symbol && 
    quantity == otherTyped.quantity && 
    price == otherTyped.price && 
    proceeds == otherTyped.proceeds;
    
  }
  @override
  int get hashCode => Object.hashAll([portfolioId.hashCode, symbol.hashCode, quantity.hashCode, price.hashCode, proceeds.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['portfolioId'] = nativeToJson<String>(portfolioId);
    json['symbol'] = nativeToJson<String>(symbol);
    json['quantity'] = nativeToJson<double>(quantity);
    json['price'] = nativeToJson<double>(price);
    json['proceeds'] = nativeToJson<double>(proceeds);
    return json;
  }

  SellStockAllVariables({
    required this.portfolioId,
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.proceeds,
  });
}

