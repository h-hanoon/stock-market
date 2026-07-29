part of 'generated.dart';

class CreateWalletProfileVariablesBuilder {
  String username;
  String email;
  double startingBalance;

  final FirebaseDataConnect _dataConnect;
  CreateWalletProfileVariablesBuilder(this._dataConnect, {required  this.username,required  this.email,required  this.startingBalance,});
  Deserializer<CreateWalletProfileData> dataDeserializer = (dynamic json)  => CreateWalletProfileData.fromJson(jsonDecode(json));
  Serializer<CreateWalletProfileVariables> varsSerializer = (CreateWalletProfileVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateWalletProfileData, CreateWalletProfileVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateWalletProfileData, CreateWalletProfileVariables> ref() {
    CreateWalletProfileVariables vars= CreateWalletProfileVariables(username: username,email: email,startingBalance: startingBalance,);
    return _dataConnect.mutation("CreateWalletProfile", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateWalletProfileUserInsert {
  final String uid;
  CreateWalletProfileUserInsert.fromJson(dynamic json):
  
  uid = nativeFromJson<String>(json['uid']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateWalletProfileUserInsert otherTyped = other as CreateWalletProfileUserInsert;
    return uid == otherTyped.uid;
    
  }
  @override
  int get hashCode => uid.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['uid'] = nativeToJson<String>(uid);
    return json;
  }

  CreateWalletProfileUserInsert({
    required this.uid,
  });
}

@immutable
class CreateWalletProfilePortfolioInsert {
  final String id;
  CreateWalletProfilePortfolioInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateWalletProfilePortfolioInsert otherTyped = other as CreateWalletProfilePortfolioInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  CreateWalletProfilePortfolioInsert({
    required this.id,
  });
}

@immutable
class CreateWalletProfileData {
  final CreateWalletProfileUserInsert user_insert;
  final CreateWalletProfilePortfolioInsert portfolio_insert;
  CreateWalletProfileData.fromJson(dynamic json):
  
  user_insert = CreateWalletProfileUserInsert.fromJson(json['user_insert']),
  portfolio_insert = CreateWalletProfilePortfolioInsert.fromJson(json['portfolio_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateWalletProfileData otherTyped = other as CreateWalletProfileData;
    return user_insert == otherTyped.user_insert && 
    portfolio_insert == otherTyped.portfolio_insert;
    
  }
  @override
  int get hashCode => Object.hashAll([user_insert.hashCode, portfolio_insert.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user_insert'] = user_insert.toJson();
    json['portfolio_insert'] = portfolio_insert.toJson();
    return json;
  }

  CreateWalletProfileData({
    required this.user_insert,
    required this.portfolio_insert,
  });
}

@immutable
class CreateWalletProfileVariables {
  final String username;
  final String email;
  final double startingBalance;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateWalletProfileVariables.fromJson(Map<String, dynamic> json):
  
  username = nativeFromJson<String>(json['username']),
  email = nativeFromJson<String>(json['email']),
  startingBalance = nativeFromJson<double>(json['startingBalance']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateWalletProfileVariables otherTyped = other as CreateWalletProfileVariables;
    return username == otherTyped.username && 
    email == otherTyped.email && 
    startingBalance == otherTyped.startingBalance;
    
  }
  @override
  int get hashCode => Object.hashAll([username.hashCode, email.hashCode, startingBalance.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['username'] = nativeToJson<String>(username);
    json['email'] = nativeToJson<String>(email);
    json['startingBalance'] = nativeToJson<double>(startingBalance);
    return json;
  }

  CreateWalletProfileVariables({
    required this.username,
    required this.email,
    required this.startingBalance,
  });
}

