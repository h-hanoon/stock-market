part of 'generated.dart';

class GetWalletOverviewVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  GetWalletOverviewVariablesBuilder(this._dataConnect, );
  Deserializer<GetWalletOverviewData> dataDeserializer = (dynamic json)  => GetWalletOverviewData.fromJson(jsonDecode(json));
  
  Future<QueryResult<GetWalletOverviewData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetWalletOverviewData, void> ref() {
    
    return _dataConnect.query("GetWalletOverview", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class GetWalletOverviewUser {
  final String uid;
  final String username;
  final String email;
  final double virtualBalance;
  final GetWalletOverviewUserPortfolio? portfolio;
  GetWalletOverviewUser.fromJson(dynamic json):
  
  uid = nativeFromJson<String>(json['uid']),
  username = nativeFromJson<String>(json['username']),
  email = nativeFromJson<String>(json['email']),
  virtualBalance = nativeFromJson<double>(json['virtualBalance']),
  portfolio = json['portfolio'] == null ? null : GetWalletOverviewUserPortfolio.fromJson(json['portfolio']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetWalletOverviewUser otherTyped = other as GetWalletOverviewUser;
    return uid == otherTyped.uid && 
    username == otherTyped.username && 
    email == otherTyped.email && 
    virtualBalance == otherTyped.virtualBalance && 
    portfolio == otherTyped.portfolio;
    
  }
  @override
  int get hashCode => Object.hashAll([uid.hashCode, username.hashCode, email.hashCode, virtualBalance.hashCode, portfolio.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['uid'] = nativeToJson<String>(uid);
    json['username'] = nativeToJson<String>(username);
    json['email'] = nativeToJson<String>(email);
    json['virtualBalance'] = nativeToJson<double>(virtualBalance);
    if (portfolio != null) {
      json['portfolio'] = portfolio!.toJson();
    }
    return json;
  }

  GetWalletOverviewUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.virtualBalance,
    this.portfolio,
  });
}

@immutable
class GetWalletOverviewUserPortfolio {
  final String id;
  final List<GetWalletOverviewUserPortfolioHoldings> holdings;
  GetWalletOverviewUserPortfolio.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  holdings = (json['holdings'] as List<dynamic>)
        .map((e) => GetWalletOverviewUserPortfolioHoldings.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetWalletOverviewUserPortfolio otherTyped = other as GetWalletOverviewUserPortfolio;
    return id == otherTyped.id && 
    holdings == otherTyped.holdings;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, holdings.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['holdings'] = holdings.map((e) => e.toJson()).toList();
    return json;
  }

  GetWalletOverviewUserPortfolio({
    required this.id,
    required this.holdings,
  });
}

@immutable
class GetWalletOverviewUserPortfolioHoldings {
  final String symbol;
  final double quantity;
  final double averagePurchasePrice;
  GetWalletOverviewUserPortfolioHoldings.fromJson(dynamic json):
  
  symbol = nativeFromJson<String>(json['symbol']),
  quantity = nativeFromJson<double>(json['quantity']),
  averagePurchasePrice = nativeFromJson<double>(json['averagePurchasePrice']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetWalletOverviewUserPortfolioHoldings otherTyped = other as GetWalletOverviewUserPortfolioHoldings;
    return symbol == otherTyped.symbol && 
    quantity == otherTyped.quantity && 
    averagePurchasePrice == otherTyped.averagePurchasePrice;
    
  }
  @override
  int get hashCode => Object.hashAll([symbol.hashCode, quantity.hashCode, averagePurchasePrice.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['symbol'] = nativeToJson<String>(symbol);
    json['quantity'] = nativeToJson<double>(quantity);
    json['averagePurchasePrice'] = nativeToJson<double>(averagePurchasePrice);
    return json;
  }

  GetWalletOverviewUserPortfolioHoldings({
    required this.symbol,
    required this.quantity,
    required this.averagePurchasePrice,
  });
}

@immutable
class GetWalletOverviewData {
  final GetWalletOverviewUser? user;
  GetWalletOverviewData.fromJson(dynamic json):
  
  user = json['user'] == null ? null : GetWalletOverviewUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetWalletOverviewData otherTyped = other as GetWalletOverviewData;
    return user == otherTyped.user;
    
  }
  @override
  int get hashCode => user.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user != null) {
      json['user'] = user!.toJson();
    }
    return json;
  }

  GetWalletOverviewData({
    this.user,
  });
}

