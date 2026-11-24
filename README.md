# Bull & Bear Markets 📈📉

A stock trading simulator. You get **$100,000 of virtual money**, watch live (simulated) stock prices, look at charts, and buy and sell shares. No real money is involved.

The project has two parts:

| Folder | What it is |
| --- | --- |
| [`stocksapp/`](stocksapp) | The Flutter app (runs on macOS, Chrome, Android, iOS, Windows, Linux) |
| [`mock-stock-data-server/`](mock-stock-data-server) | A small Python server that serves fake stock prices from a [Kaggle dataset](https://www.kaggle.com/datasets/jacksoncrow/stock-market-dataset) |

The app needs a backend for **user accounts** and **wallets**. You can pick either one:

| Backend | Git branch | Good for |
| --- | --- | --- |
| **Supabase** | `supabase-migration` | Easiest setup, free tier, email verification codes |
| **Firebase** | `main` | If you already use Google Firebase |

You only need **one** of them. Both versions look and work the same.

---

## Contents

1. [Install the tools](#1-install-the-tools)
2. [Download the project](#2-download-the-project)
3. [Start the stock price server](#3-start-the-stock-price-server)
4. [Set up your backend](#4-set-up-your-backend): [Option A: Supabase](#option-a-supabase) or [Option B: Firebase](#option-b-firebase)
5. [Run the app](#5-run-the-app)
6. [How to use the app](#6-how-to-use-the-app)
7. [Troubleshooting](#7-troubleshooting)
8. [Keeping secrets safe](#8-keeping-secrets-safe)

---

## 1. Install the tools

You need these installed once:

| Tool | Why | Check it works |
| --- | --- | --- |
| [Git](https://git-scm.com/downloads) | Download the code | `git --version` |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.12+) | Build and run the app | `flutter doctor` |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) **or** [Python 3.10+](https://www.python.org/downloads/) | Run the stock price server | `docker --version` or `python3 --version` |

To run on a phone emulator you also need Android Studio (Android) or Xcode (iOS/macOS). Running in **Chrome** or as a **macOS** desktop app needs nothing extra.

---

## 2. Download the project

```shell
git clone https://github.com/h-hanoon/stock-market.git
cd stock-market
```

Then switch to the branch for the backend you picked:

```shell
git checkout supabase-migration   # for Supabase
# or
git checkout main                 # for Firebase
```

---

## 3. Start the stock price server

The app gets its stock prices from this server. **Leave it running** while you use the app.

Open a terminal and pick **one** of these:

**With Docker** (Docker Desktop must be open):

```shell
cd mock-stock-data-server
make run      # starts the server in the background
```

Run `make stop` when you're finished.

**Without Docker** (plain Python):

```shell
cd mock-stock-data-server
tar xf sample-stocks.zip                 # unpack the stock data (first time only)
python3 -m venv .venv                    # create a virtual environment (first time only)
source .venv/bin/activate                # on Windows: .venv\Scripts\activate
pip install -r requirements.txt          # first time only
python app.py
```

Press `Ctrl + C` to stop it.

**Check it works.** Open http://127.0.0.1:5001/stocks_list in your browser. You should see a list of stock symbols such as `["AAME", "ABM", ...]`.

<details>
<summary>The server's endpoints</summary>

| Endpoint | Returns |
| --- | --- |
| `GET /stocks_list` | All available stock symbols |
| `GET /exchange_rate/<symbol>` | The current price of a symbol |
| `GET /hist/<symbol>?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD` | Price history for a symbol |

</details>

---

## 4. Set up your backend

Follow **Option A** *or* **Option B**, not both.

### Option A: Supabase

> Branch: `supabase-migration`

#### A1. Create a Supabase project

1. Go to https://supabase.com/dashboard and sign in (GitHub login works).
2. Click **New project**.
3. Enter a name (e.g. `stocks`), choose a **database password** (save it somewhere), and pick the region closest to you.
4. Click **Create new project** and wait about a minute until the status says **Healthy**.

#### A2. Create the database tables

1. In the left sidebar, click the **`>_` SQL Editor** icon.
2. Click **New query**.
3. Open [`stocksapp/supabase/migrations/20261123000000_wallet.sql`](stocksapp/supabase/migrations/20261123000000_wallet.sql) from this project, copy **everything** in it, and paste it into the editor.
   - Shortcut on macOS: `pbcopy < stocksapp/supabase/migrations/20261123000000_wallet.sql`
4. Click **Run**. You should see **"Success. No rows returned"**.

This creates three tables (`profiles`, `holdings`, `transactions`), security rules so each user only sees their own data, and the buy/sell functions.

> Run the file only **once**. Running it again gives "already exists" errors, which are safe to ignore.

#### A3. Set up email sign-up and verification

1. Click the **padlock icon (Authentication)** in the sidebar.
2. Go to **Sign In / Providers → Email** and make sure:
   - **Enable Email provider** is **on**
   - **Confirm email** is **on**. New users must enter a code from their email.
3. Go to **Emails → Templates → Confirm signup**, replace the message body with the following, and click **Save**:

   ```html
   <h2>Confirm your signup</h2>
   <p>Your verification code is:</p>
   <h1>{{ .Token }}</h1>
   ```

   This puts a **code** in the email for the user to type into the app. The default email only has a link, which doesn't work for a desktop or mobile app.

> **Testing only:** if you don't want to deal with emails, switch **Confirm email** off. New accounts can then log in immediately.
>
> **Email limits:** Supabase's built-in email sender only sends a few emails per hour. For real users, add your own email provider (Resend, SendGrid, Mailgun…) under **Authentication → Emails → SMTP Settings**.

#### A4. Copy your project URL and key

1. Click **Connect** at the top of the dashboard, or the **gear icon → API Keys**.
2. Copy two values:
   - **Project URL**, e.g. `https://abcdefghijklmnop.supabase.co`
   - **Publishable key**, which starts with `sb_publishable_...` (the older **anon** key also works)

> ⚠️ Never put the **secret** / **service_role** key in the app. It skips all security rules.

#### A5. Add them to the app

```shell
cd stocksapp
cp supabase.example.json supabase.json
```

Open `stocksapp/supabase.json` and paste in your values:

```json
{
  "SUPABASE_URL": "https://abcdefghijklmnop.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_xxxxxxxxxxxxxxxx"
}
```

`supabase.json` is **gitignored**, so it never gets committed.

✅ Supabase is ready. Go to [step 5](#5-run-the-app).

---

### Option B: Firebase

> Branch: `main`

The Firebase version uses **Firebase Authentication** for accounts and **Firebase Data Connect** (a PostgreSQL database) for wallets.

#### B1. Install the Firebase tools

```shell
npm install -g firebase-tools            # needs Node.js: https://nodejs.org
dart pub global activate flutterfire_cli
firebase login
```

If `flutterfire` is "command not found", add `$HOME/.pub-cache/bin` to your `PATH`.

#### B2. Create a Firebase project

1. Go to https://console.firebase.google.com and click **Create a project**.
2. Enter a name and follow the steps. Google Analytics is optional.

#### B3. Turn on email/password login

1. In your project, open **Build → Authentication** and click **Get started**.
2. Under **Sign-in method**, click **Email/Password**, switch it **on**, and click **Save**.

#### B4. Connect the app to your project

```shell
cd stocksapp
flutterfire configure
```

Pick your project and the platforms you want (e.g. android, ios, macos, web). This creates these files, which are **gitignored**:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Then link the Firebase CLI to your project:

```shell
firebase use --add      # pick your project and name it "default"
```

#### B5. Set up the database (Data Connect)

1. In the Firebase console, open **Build → Data Connect** and click **Get started**.
2. Create a service with a **Cloud SQL** instance and note down the **service ID**, **region**, **instance ID** and **database name**.
   - Data Connect includes a free Cloud SQL trial. After that you need the **Blaze** (pay-as-you-go) plan.
3. Open `stocksapp/dataconnect/dataconnect.yaml` and replace the existing values with yours:

   ```yaml
   serviceId: "YOUR-SERVICE-ID"
   location: "YOUR-REGION"            # e.g. europe-west1
   schemas:
     - source: "./schema"
       datasource:
         postgresql:
           database: "YOUR-DATABASE-NAME"
           cloudSql:
             instanceId: "YOUR-INSTANCE-ID"
   ```

4. Deploy the database schema and queries:

   ```shell
   firebase deploy --only dataconnect
   ```

   Answer **Yes** if it asks to update the database schema.

The generated Dart code in `lib/dataconnect_generated/` is already in the repo. Only if you change files in `dataconnect/`, regenerate it with:

```shell
firebase dataconnect:sdk:generate
```

✅ Firebase is ready. Go to [step 5](#5-run-the-app).

---

## 5. Run the app

Make sure the **stock price server is running** (step 3). Then, in a second terminal:

```shell
cd stocksapp
flutter pub get
flutter devices          # lists where you can run the app
```

**Supabase** (branch `supabase-migration`):

```shell
flutter run --dart-define-from-file=supabase.json
```

**Firebase** (branch `main`):

```shell
flutter run
```

Pick a device when asked, or choose one directly with `-d`:

| Run on | Add this |
| --- | --- |
| macOS desktop | `-d macos` |
| Chrome | `-d chrome` |
| Android emulator | `-d emulator-5554` (the ID from `flutter devices`) |
| iOS simulator | `-d "iPhone 16"` (the name from `flutter devices`) |

While it's running, press `r` to reload after code changes and `q` to quit.

> The app finds the stock server automatically: `127.0.0.1:5001` normally, and `10.0.2.2:5001` on the Android emulator. On a **real phone**, change the address in `stocksapp/lib/services/stock_service.dart` to your computer's local IP, e.g. `http://192.168.1.20:5001`.

---

## 6. How to use the app

### Create an account

1. On the login screen, tap **Sign Up** next to "Don't have an account?".
2. Enter your **email** and a **password** (at least 6 characters), type the password again, and tap **Sign Up**.
3. **Supabase with "Confirm email" on:** a **Check your email** screen opens. Type the code from the email and tap **Verify & Continue**.
   - No email? Check spam, then tap **Didn't get it? Resend code**.
4. You're in, with a fresh wallet of **$100,000**.

### Log in and out

- **Log in:** enter your email and password and tap **Log In**.
- **Forgot password:** type your email and tap **Forgot password?** to get a reset email.
- **Log out:** tap the **exit icon** in the top-right corner of the home screen.
- If you signed up but never verified (Supabase), logging in sends a new code and opens the verify screen.

### Home: the stock list

- Shows every stock with its **current price** and **% change**. Green means up and red means down.
- Prices refresh automatically every **5 seconds**. Pull down to refresh by hand.
- The bar at the bottom shows your **cash balance**. Tap it to open your **Wallet**.

### Stock details and buying

1. Tap any stock to open its page.
2. Switch the chart between **Line**, **Candles** and **Volume**. It shows the last 90 days.
3. Tap **Buy [SYMBOL]**, enter a **Quantity** (or tap **MAX** for as many as you can afford), and tap **Confirm buy**.
4. The money comes out of your balance and the shares go into your wallet.

### Wallet: holdings, selling and history

- **Cash:** money you have left to spend.
- **Holdings:** the stocks you own, how many shares, and your average purchase price.
- **Sell:** tap **Sell** on a holding, enter a quantity (or **MAX**), and tap **Confirm sell**.
- **Recent activity:** your latest buys and sells.

Everything updates **live**. If you trade on another device with the same account, the wallet updates by itself.

---

## 7. Troubleshooting

| Problem | Fix |
| --- | --- |
| Stock list is empty or says "failed to load" | The stock server isn't running. Start it (step 3) and check http://127.0.0.1:5001/stocks_list |
| `Missing Supabase config` when the app starts | Run with `--dart-define-from-file=supabase.json` and check the file exists in `stocksapp/` (step A5) |
| "Incorrect email or password" | Check for typos. Make sure you signed up on the **same backend** you're running |
| Supabase: "Confirm your email first" / stuck on verify | Enter the code from the email, or tap **Resend code**. For testing, turn **Confirm email** off (step A3) |
| Supabase: the email has a link but no code | Update the **Confirm signup** template to include `{{ .Token }}` (step A3) |
| Supabase: "Too many emails sent" | The built-in sender's hourly limit was reached. Wait, or set up custom SMTP (step A3) |
| Supabase: `relation "profiles" does not exist` | The SQL wasn't run. Do step A2 |
| Firebase: `firebase_options.dart` not found | Run `flutterfire configure` in `stocksapp/` (step B4) |
| Firebase: wallet won't load / Data Connect errors | Check `dataconnect.yaml` has **your** IDs and run `firebase deploy --only dataconnect` (step B5) |
| macOS app can't connect to anything | Add `com.apple.security.network.client` = `true` to `macos/Runner/DebugProfile.entitlements` and `Release.entitlements` (already done on the Supabase branch) |
| Android emulator can't reach the stock server | Use `10.0.2.2:5001`, not `127.0.0.1`. The app does this automatically |
| Something is broken after switching branches | Run `flutter clean && flutter pub get`, then run again |

---

## 8. Keeping secrets safe

The [`.gitignore`](.gitignore) keeps these files **out of Git**. Never force-add them (`git add -f`):

| File | Backend |
| --- | --- |
| `stocksapp/supabase.json` | Supabase |
| `stocksapp/lib/firebase_options.dart` | Firebase |
| `stocksapp/android/app/google-services.json` | Firebase |
| `stocksapp/ios/Runner/GoogleService-Info.plist` | Firebase |
| `stocksapp/.firebaserc` | Firebase |
| `.env`, `*.pem`, `*.key`, service-account JSON files | Any |

Good to know:

- The Supabase **publishable/anon key** and the Firebase **API key** are meant to be used inside apps. Your data is protected by the database security rules, not by hiding these keys. Still, keep them out of public repos so others can't use up your free quota.
- **Never** put a Supabase `service_role`/secret key or a Firebase service-account file in the app or in Git.
- If a secret was ever committed, **rotate it** (create a new one in the dashboard and delete the old one). Deleting the file doesn't remove it from Git history.

---

## Project structure

```
stock-market/
├── mock-stock-data-server/      Flask server with fake stock prices
│   ├── app.py                   API endpoints
│   ├── utils.py
│   └── sample-stocks.zip        Historical prices (unzipped to sample-stocks/)
└── stocksapp/                   Flutter app
    ├── lib/
    │   ├── main.dart            App start + login check
    │   ├── screens/             login, sign up, verify email, home, stock details, wallet
    │   ├── services/            stock_service.dart (prices), wallet_service.dart (accounts & trades)
    │   └── widgets/
    ├── supabase/migrations/     Database setup SQL          (Supabase branch)
    ├── supabase.example.json    Template for supabase.json  (Supabase branch)
    └── dataconnect/             Database schema & queries   (Firebase branch)
```

---

## License

This project is licensed under the [MIT License](LICENSE). You're free to use, copy, modify and share it, as long as you keep the copyright notice.

The sample stock data comes from the [Kaggle Stock Market Dataset](https://www.kaggle.com/datasets/jacksoncrow/stock-market-dataset) and is covered by that dataset's own license.
