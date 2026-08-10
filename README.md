# Stock Market

A stock trading simulator made of two pieces:

- **[`stocksapp/`](stocksapp)** — a Flutter app (Android/iOS/web/desktop) with login/signup, a stock monitor with candlestick charts, and a wallet for buying/selling stocks. Backed by Firebase (Auth + Data Connect).
- **[`mock-stock-data-server/`](mock-stock-data-server)** — a small Flask API that serves fake real-time and historical exchange rate data, sampled from a [Kaggle stock market dataset](https://www.kaggle.com/datasets/jacksoncrow/stock-market-dataset).

## Project structure

```
stock-market/
├── stocksapp/               Flutter client
│   └── lib/
│       ├── screens/         login, signup, home, stock monitor, wallet
│       ├── services/        stock_service.dart, wallet_service.dart
│       ├── widgets/         candlestick_background.dart
│       └── dataconnect_generated/  generated Firebase Data Connect queries/mutations
└── mock-stock-data-server/  Flask mock data API
    ├── app.py
    ├── utils.py
    └── sample-stocks/       per-symbol historical CSVs
```

## Getting started

### 1. Run the mock data server

```shell
cd mock-stock-data-server
make run
```

This starts the API on `localhost:5001`. Key endpoints:

- `GET /stocks_list` — list available stock symbols
- `GET /exchange_rate/<symbol>` — current rate for a symbol
- `GET /hist/<symbol>?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD` — historical data for a symbol

Stop it with `make stop`. See [`mock-stock-data-server/README.md`](mock-stock-data-server/README.md) for details.

### 2. Run the Flutter app

```shell
cd stocksapp
flutter pub get
flutter run
```

The app uses Firebase (Auth + Cloud Firestore + Data Connect) — configuration lives in `lib/firebase_options.dart` and `.firebaserc`/`firebase.json`. Point `stock_service.dart` at the mock server's URL if running it locally.

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.12.2)
- Python 3 and `make` for the mock data server
- A configured Firebase project for auth/data
