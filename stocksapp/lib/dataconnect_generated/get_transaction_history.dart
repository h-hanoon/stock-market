part of 'generated.dart';

class GetTransactionHistoryVariablesBuilder {
  Optional<int> _limit = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;
  GetTransactionHistoryVariablesBuilder limit(int? t) {
   _limit.value = t;
   return this;
  }

  GetTransactionHistoryVariablesBuilder(this._dataConnect, );
  Deserializer<GetTransactionHistoryData> dataDeserializer = (dynamic json)  => GetTransactionHistoryData.fromJson(jsonDecode(json));
  Serializer<GetTransactionHistoryVariables> varsSerializer = (GetTransactionHistoryVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetTransactionHistoryData, GetTransactionHistoryVariables>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetTransactionHistoryData, GetTransactionHistoryVariables> ref() {
    GetTransactionHistoryVariables vars= GetTransactionHistoryVariables(limit: _limit,);
    return _dataConnect.query("GetTransactionHistory", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetTransactionHistoryTransactions {
  final String id;
  final String symbol;
  final String type;
  final double quantity;
  final double priceAtExecution;
  final Timestamp timestamp;
  GetTransactionHistoryTransactions.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  symbol = nativeFromJson<String>(json['symbol']),
  type = nativeFromJson<String>(json['type']),
  quantity = nativeFromJson<double>(json['quantity']),
  priceAtExecution = nativeFromJson<double>(json['priceAtExecution']),
  timestamp = Timestamp.fromJson(json['timestamp']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetTransactionHistoryTransactions otherTyped = other as GetTransactionHistoryTransactions;
    return id == otherTyped.id && 
    symbol == otherTyped.symbol && 
    type == otherTyped.type && 
    quantity == otherTyped.quantity && 
    priceAtExecution == otherTyped.priceAtExecution && 
    timestamp == otherTyped.timestamp;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, symbol.hashCode, type.hashCode, quantity.hashCode, priceAtExecution.hashCode, timestamp.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['symbol'] = nativeToJson<String>(symbol);
    json['type'] = nativeToJson<String>(type);
    json['quantity'] = nativeToJson<double>(quantity);
    json['priceAtExecution'] = nativeToJson<double>(priceAtExecution);
    json['timestamp'] = timestamp.toJson();
    return json;
  }

  GetTransactionHistoryTransactions({
    required this.id,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.priceAtExecution,
    required this.timestamp,
  });
}

@immutable
class GetTransactionHistoryData {
  final List<GetTransactionHistoryTransactions> transactions;
  GetTransactionHistoryData.fromJson(dynamic json):
  
  transactions = (json['transactions'] as List<dynamic>)
        .map((e) => GetTransactionHistoryTransactions.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetTransactionHistoryData otherTyped = other as GetTransactionHistoryData;
    return transactions == otherTyped.transactions;
    
  }
  @override
  int get hashCode => transactions.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['transactions'] = transactions.map((e) => e.toJson()).toList();
    return json;
  }

  GetTransactionHistoryData({
    required this.transactions,
  });
}

@immutable
class GetTransactionHistoryVariables {
  late final Optional<int>limit;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetTransactionHistoryVariables.fromJson(Map<String, dynamic> json) {
  
  
    limit = Optional.optional(nativeFromJson, nativeToJson);
    limit.value = json['limit'] == null ? null : nativeFromJson<int>(json['limit']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetTransactionHistoryVariables otherTyped = other as GetTransactionHistoryVariables;
    return limit == otherTyped.limit;
    
  }
  @override
  int get hashCode => limit.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if(limit.state == OptionalState.set) {
      json['limit'] = limit.toJson();
    }
    return json;
  }

  GetTransactionHistoryVariables({
    required this.limit,
  });
}

