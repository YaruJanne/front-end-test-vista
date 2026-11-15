# Vista Technical Test – Flutter Frontend

Flutter app for managing companies and their services, connected to the
[Vista backend API](https://github.com/YaruJanne/back-end-test-vista).

![Company list](docs/screenshot.png)

**Tech stack:** Flutter, Dart, `http` (API calls), `provider` (state management)

## Features

- **Company list:** all companies with registration number and their services (name, description, price)
- **Create company:** form with validation (name and registration number required)
- **Create service:** form with company dropdown, validation (required fields, numeric price)
- Loading states, error messages with retry, pull-to-refresh
- API errors (e.g. duplicate registration number) shown to the user
- Responsive layout: 1, 2 or 3 columns depending on screen width; forms centered on wide screens

## Requirements

- Flutter SDK 3.50+ (Dart 3.14+)
- The backend API running (see the backend README)

## Setup & Run

```bash
git clone https://github.com/YaruJanne/front-end-test-vista.git
cd front-end-test-vista
flutter pub get
```

Start the backend first (default `http://localhost:3000`), then:

| Target | Command | API address used |
|---|---|---|
| Chrome (web) | `flutter run -d chrome` | `http://localhost:3000` |
| Android emulator | `flutter run` | `http://10.0.2.2:3000` (emulator's alias for your PC) |
| Real device / custom URL | `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3000` | Your value |

The base URL logic lives in `lib/config/api_config.dart`.

## Tests

```bash
flutter test
```

## Project Structure

```
lib/
├── main.dart                     # App entry, Provider setup, theme
├── config/api_config.dart        # API base URL per platform
├── models/                       # Company, Service (fromJson)
├── services/
│   ├── api_service.dart          # All HTTP calls + error handling
│   └── api_exception.dart        # Readable API error type
├── providers/company_provider.dart  # State: companies, loading, error
├── screens/
│   ├── company_list_screen.dart
│   ├── create_company_screen.dart
│   └── create_service_screen.dart
├── widgets/form_container.dart   # Responsive form wrapper
└── utils/format.dart             # Price formatting (RM 1,500.00)
```

## State Management

`CompanyProvider` (a `ChangeNotifier`) holds the company list, loading flag and error message.
Screens read it with `context.watch` and call `addCompany` / `addService`, which
call the API and then refresh the list. Form submission state is kept locally in each form screen.