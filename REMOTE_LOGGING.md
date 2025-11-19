# Remote Logging Setup

Dette dokument beskriver remote logging systemet og backend API requirements.

## Overview

Flutter appen sender logs til backend API for:
- Error tracking (uncaught exceptions, Flutter errors)
- User tracking (login, logout, registrering)
- Custom events og analytics
- Performance monitoring

## Backend API Endpoint

### POST /api/logs

Modtager log entries fra client.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "level": "ERROR",           // "DEBUG" | "INFO" | "WARNING" | "ERROR"
  "message": "Error besked",
  "timestamp": "2025-11-19T12:00:00.000Z",
  "version": "95b800f",       // Git commit SHA (first 8 chars)
  "userId": "123",            // Optional - kun når bruger er logget ind
  "category": "auth",         // Optional - gruppering af logs
  "metadata": {               // Optional - custom data
    "key": "value"
  },
  "stackTrace": "...",        // Optional - kun ved errors
  "errorType": "Exception"    // Optional - kun ved errors
}
```

**Response:**
- `200 OK` - Log modtaget successfully
- `400 Bad Request` - Invalid request body
- `500 Internal Server Error` - Server fejl

### Eksempel Requests

**User Login Event:**
```json
{
  "level": "INFO",
  "message": "user_login",
  "timestamp": "2025-11-19T12:00:00.000Z",
  "version": "95b800f",
  "userId": "42",
  "category": "user_tracking",
  "metadata": {
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

**Uncaught Error:**
```json
{
  "level": "ERROR",
  "message": "Uncaught async error",
  "timestamp": "2025-11-19T12:00:00.000Z",
  "version": "95b800f",
  "userId": "42",
  "category": "async_error",
  "stackTrace": "Error: Something went wrong\n  at ...",
  "errorType": "StateError"
}
```

**Login Failure:**
```json
{
  "level": "WARNING",
  "message": "Login failed",
  "timestamp": "2025-11-19T12:00:00.000Z",
  "version": "95b800f",
  "category": "auth",
  "metadata": {
    "email": "user@example.com",
    "error": "Invalid credentials"
  }
}
```

## Backend Implementation Forslag

### Database Schema

```sql
CREATE TABLE client_logs (
    id BIGSERIAL PRIMARY KEY,
    level VARCHAR(10) NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    version VARCHAR(50) NOT NULL,
    user_id INTEGER,
    category VARCHAR(100),
    metadata JSONB,
    stack_trace TEXT,
    error_type VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_client_logs_timestamp ON client_logs(timestamp DESC);
CREATE INDEX idx_client_logs_user_id ON client_logs(user_id);
CREATE INDEX idx_client_logs_level ON client_logs(level);
CREATE INDEX idx_client_logs_category ON client_logs(category);
CREATE INDEX idx_client_logs_version ON client_logs(version);
```

### Spring Boot Controller Eksempel

```java
@RestController
@RequestMapping("/api/logs")
public class ClientLogController {

    @Autowired
    private ClientLogService logService;

    @PostMapping
    public ResponseEntity<Void> receiveLog(@RequestBody ClientLogDTO log) {
        logService.save(log);
        return ResponseEntity.ok().build();
    }
}
```

## Log Levels og Brug

- **DEBUG**: Development debugging (kun sendt i debug mode)
- **INFO**: User tracking, feature usage, normal events
- **WARNING**: Non-critical fejl, failed validations
- **ERROR**: Exceptions, crashes, critical fejl

## Event Categories

- `flutter_error` - Flutter framework errors
- `async_error` - Uncaught async errors
- `auth` - Authentication related events/errors
- `user_tracking` - User actions (login, logout, feature usage)
- `api` - API call errors
- `performance` - Performance metrics

## User Tracking Events

Appen tracker følgende user events:
- `user_login` - Successful login
- `user_register` - Successful registration
- `user_logout` - User logout

Du kan tilføje flere custom events ved at kalde:
```dart
final logger = ref.read(remoteLoggerProvider);
logger.trackEvent('feature_used', properties: {
  'feature': 'task_completion',
  'task_id': '123',
});
```

## Rate Limiting

Backend bør implementere rate limiting for at undgå spam:
- Max 100 requests per minut per IP
- Max 1000 requests per minut globalt

## Privacy og GDPR

- Logs indeholder potentielt personlige data (email, navn, user ID)
- Implementer data retention policy (fx slet logs efter 90 dage)
- Giv brugere mulighed for at anmode om sletning af deres logs
- Undgå at logge passwords eller følsomme data
