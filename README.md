# 📈 Stocklio

> Track your stock portfolio across multiple brokers. View daily, monthly, and yearly profit trends in one place.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.27.2-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.6.1-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

## ✨ Features

- 🎯 **Multi-Broker Support**: Track stocks from different brokerage accounts in one place
- 📊 **Profit Tracking**: View daily, monthly, and yearly profit trends
- 💰 **Real-time Valuation**: Automatic portfolio valuation with current stock prices
- 📱 **Cross-Platform**: Works on iOS, Android, macOS, and Web
- 🔍 **Smart Search**: Quick search for Korean and US stocks
- 📈 **Visual Analytics**: Beautiful charts showing your investment performance

## 🚀 Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Local Database**: SQLite (sqflite)
- **Charts**: fl_chart
- **Stock Data API**: Yahoo Finance
- **Background Tasks**: workmanager

## 📱 Screenshots

_Coming soon_

## 🛠️ Installation

### Prerequisites

- Flutter SDK 3.27.2 or higher
- Dart SDK 3.6.1 or higher

### Setup

1. Clone the repository
```bash
git clone https://github.com/bgc8214/Stocklio.git
cd Stocklio
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
# iOS Simulator
flutter run -d "iPhone 16 Pro"

# Android
flutter run

# macOS
flutter run -d macos

# Web
flutter run -d chrome
```

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── portfolio.dart                 # Portfolio model
│   └── stock_info.dart               # Stock information model
├── providers/
│   └── portfolio_provider.dart       # Portfolio state management
├── screens/
│   ├── dashboard_screen.dart         # Main dashboard
│   ├── portfolio_list_screen.dart    # Portfolio list
│   ├── stock_search_screen.dart      # Stock search
│   └── add_portfolio_screen.dart     # Add/Edit stock
├── services/
│   ├── database_service.dart         # Database service
│   └── yahoo_finance_service.dart    # Stock data API
├── utils/
│   └── currency_formatter.dart       # Currency formatting
└── widgets/
    ├── portfolio_summary_card.dart   # Summary card widget
    └── profit_chart.dart             # Profit chart widget
```

## 📊 Database Schema

### Tables

- **stock_master**: Master data for stocks (ticker, name, market)
- **portfolios**: User's stock holdings (ticker, quantity, average price)
- **daily_snapshots**: Daily portfolio snapshots for profit tracking
- **profit_series**: Time-series data for charts

## 🎯 Roadmap

### Phase 1: MVP ✅
- [x] Stock search and portfolio management
- [x] Basic dashboard with profit/loss
- [x] Daily/Monthly/Yearly profit charts
- [x] Email authentication

### Phase 2: Cloud Integration
- [ ] Firebase Authentication
- [ ] Cloud Firestore integration
- [ ] Cross-device sync
- [ ] Dividend tracking

### Phase 3: Advanced Features
- [ ] Dark mode
- [ ] Brokerage API integration
- [ ] Push notifications
- [ ] Portfolio comparison (year-over-year)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**bgc8214**

- GitHub: [@bgc8214](https://github.com/bgc8214)

## 🙏 Acknowledgments

- Stock data provided by [Yahoo Finance](https://finance.yahoo.com/)
- Korean stock data from KRX (Korea Exchange)
- Icons from [Flutter Icons](https://api.flutter.dev/flutter/material/Icons-class.html)

## 📮 Contact

If you have any questions or suggestions, please open an issue or contact me directly.

---

<p align="center">Made with ❤️ and Flutter</p>
