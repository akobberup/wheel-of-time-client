# Wheel of Time App

Flutter mobile application for the Wheel of Time server with Riverpod state management.

## Setup

1. Install Flutter: https://flutter.dev/docs/get-started/install

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   # For mobile
   flutter run

   # For web
   flutter run -d chrome
   ```

## Project Structure

```
lib/
├── models/          # Data models
├── providers/       # Riverpod state management
├── services/        # API and storage services
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── main.dart        # App entry point
```

## Features

- Email/password authentication
- JWT token management
- Secure token storage
- Login and registration
- Riverpod state management
- Material Design 3

## Backend Configuration

By default, the app connects to `http://localhost:8080`. To change this:

1. Open `lib/services/api_service.dart`
2. Update the `baseUrl` constant

For production:
```dart
static const String baseUrl = 'https://your-production-api.com';
```

## Testing

Make sure your Spring Boot server is running on port 8080 before testing the app.

Test credentials after registration:
- Email: test@example.com
- Password: password123
# wheel-of-time-client
