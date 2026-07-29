# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ExampleConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### GetWalletOverview
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.getWalletOverview().execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetWalletOverviewData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getWalletOverview();
GetWalletOverviewData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.getWalletOverview().ref();
ref.execute();

ref.subscribe(...);
```


### GetTransactionHistory
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.getTransactionHistory().execute();
```

#### Optional Arguments
We return a builder for each query. For GetTransactionHistory, we created `GetTransactionHistoryBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class GetTransactionHistoryVariablesBuilder {
  ...
 
  GetTransactionHistoryVariablesBuilder limit(int? t) {
   _limit.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.getTransactionHistory()
.limit(limit)
.execute();
```

#### Return Type
`execute()` returns a `QueryResult<GetTransactionHistoryData, GetTransactionHistoryVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getTransactionHistory();
GetTransactionHistoryData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.getTransactionHistory().ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### CreateWalletProfile
#### Required Arguments
```dart
String username = ...;
String email = ...;
double startingBalance = ...;
ExampleConnector.instance.createWalletProfile(
  username: username,
  email: email,
  startingBalance: startingBalance,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateWalletProfileData, CreateWalletProfileVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createWalletProfile(
  username: username,
  email: email,
  startingBalance: startingBalance,
);
CreateWalletProfileData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String username = ...;
String email = ...;
double startingBalance = ...;

final ref = ExampleConnector.instance.createWalletProfile(
  username: username,
  email: email,
  startingBalance: startingBalance,
).ref();
ref.execute();
```


### BuyStock
#### Required Arguments
```dart
String portfolioId = ...;
String symbol = ...;
double quantity = ...;
double price = ...;
double cost = ...;
double newHoldingQuantity = ...;
double newAveragePrice = ...;
ExampleConnector.instance.buyStock(
  portfolioId: portfolioId,
  symbol: symbol,
  quantity: quantity,
  price: price,
  cost: cost,
  newHoldingQuantity: newHoldingQuantity,
  newAveragePrice: newAveragePrice,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<BuyStockData, BuyStockVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.buyStock(
  portfolioId: portfolioId,
  symbol: symbol,
  quantity: quantity,
  price: price,
  cost: cost,
  newHoldingQuantity: newHoldingQuantity,
  newAveragePrice: newAveragePrice,
);
BuyStockData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String portfolioId = ...;
String symbol = ...;
double quantity = ...;
double price = ...;
double cost = ...;
double newHoldingQuantity = ...;
double newAveragePrice = ...;

final ref = ExampleConnector.instance.buyStock(
  portfolioId: portfolioId,
  symbol: symbol,
  quantity: quantity,
  price: price,
  cost: cost,
  newHoldingQuantity: newHoldingQuantity,
  newAveragePrice: newAveragePrice,
).ref();
ref.execute();
```


### SellStockPartial
#### Required Arguments
```dart
String portfolioId = ...;
String symbol = ...;
double quantity = ...;
double price = ...;
double proceeds = ...;
double newHoldingQuantity = ...;
ExampleConnector.instance.sellStockPartial(
  portfolioId: portfolioId,
  symbol: symbol,
  quantity: quantity,
  price: price,
  proceeds: proceeds,
  newHoldingQuantity: newHoldingQuantity,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<SellStockPartialData, SellStockPartialVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.sellStockPartial(
  portfolioId: portfolioId,
  symbol: symbol,
  quantity: quantity,
  price: price,
  proceeds: proceeds,
  newHoldingQuantity: newHoldingQuantity,
);
SellStockPartialData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String portfolioId = ...;
String symbol = ...;
double quantity = ...;
double price = ...;
double proceeds = ...;
double newHoldingQuantity = ...;

final ref = ExampleConnector.instance.sellStockPartial(
  portfolioId: portfolioId,
  symbol: symbol,
  quantity: quantity,
  price: price,
  proceeds: proceeds,
  newHoldingQuantity: newHoldingQuantity,
).ref();
ref.execute();
```


### SellStockAll
#### Required Arguments
```dart
String portfolioId = ...;
String symbol = ...;
double quantity = ...;
double price = ...;
double proceeds = ...;
ExampleConnector.instance.sellStockAll(
  portfolioId: portfolioId,
  symbol: symbol,
  quantity: quantity,
  price: price,
  proceeds: proceeds,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<SellStockAllData, SellStockAllVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.sellStockAll(
  portfolioId: portfolioId,
  symbol: symbol,
  quantity: quantity,
  price: price,
  proceeds: proceeds,
);
SellStockAllData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String portfolioId = ...;
String symbol = ...;
double quantity = ...;
double price = ...;
double proceeds = ...;

final ref = ExampleConnector.instance.sellStockAll(
  portfolioId: portfolioId,
  symbol: symbol,
  quantity: quantity,
  price: price,
  proceeds: proceeds,
).ref();
ref.execute();
```

