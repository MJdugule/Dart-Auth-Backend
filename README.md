# Dart Auth Backend

A production-ready authentication backend service built with **Dart Frog**, featuring JWT-based authentication, OTP verification, email management, and Redis caching. This monolithic service provides comprehensive user management and security features.

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Setup & Installation](#setup--installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [API Endpoints](#api-endpoints)
- [Key Features](#key-features)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)

---

## Project Overview

**Dart Auth Backend** is a comprehensive authentication and user management system that handles:

- **User Registration & Login** - Secure user account creation with email verification
- **OTP Management** - One-time password generation, verification, and delivery via email
- **Password Management** - Secure password hashing with BCrypt, password reset, and password change functionality
- **JWT Tokens** - Access tokens, refresh tokens, and reset tokens with configurable expiration
- **Rate Limiting** - OTP send cooldown to prevent abuse
- **Redis Caching** - Fast token storage and session management
- **Email Notifications** - Integration with SendGrid for OTP and notification delivery
- **MongoDB Storage** - Persistent user data with MongoDB
- **User Account Management** - Delete account and profile management

---

## Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Applications                       │
└────────────┬────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────┐
│              Dart Frog HTTP Server (Port 8080)              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Route Handler Layer                      │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │  /api/v1/auth/*                              │   │  │
│  │  │  - register, login, refresh-token            │   │  │
│  │  │  - send-otp, verify-otp                      │   │  │
│  │  │  - forgot-password, change-password          │   │  │
│  │  │  - delete-account                            │   │  │
│  │  │  - Middleware: Auth validation               │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
│                       │                                     │
│  ┌────────────────────┴──────────────────────────────────┐ │
│  │          Business Logic & Services Layer              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │ │
│  │  │ AuthService  │  │ TokenService │  │EmailService│ │ │
│  │  │              │  │              │  │            │ │ │
│  │  │ - Register   │  │ - JWT Gen    │  │- SendGrid  │ │ │
│  │  │ - Login      │  │ - Token Val  │  │- Generate  │ │ │
│  │  │ - OTP Mgmt   │  │ - Password   │  │- OTP Email │ │ │
│  │  │ - Pwd Change │  │   Hashing    │  │            │ │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘ │ │
│  │                                                       │ │
│  │              ┌─────────────────┐                    │ │
│  │              │ RedisService    │                    │ │
│  │              │                 │                    │ │
│  │              │ - OTP Storage   │                    │ │
│  │              │ - Rate Limiting │                    │ │
│  │              │ - Token Cache   │                    │ │
│  │              └─────────────────┘                    │ │
│  └──────────────────────────────────────────────────────┘ │
└──────────────────┬──────────────────┬────────────────────┘
                   │                  │
        ┌──────────▼─────┐   ┌────────▼──────────┐
        │   MongoDB      │   │      Redis        │
        │   (Persistent) │   │   (Cache/Session) │
        └────────────────┘   └───────────────────┘
```

### Layered Architecture

**1. Route Layer** (`/routes`)
- HTTP endpoint definitions
- Request handling and response formatting
- Middleware for authentication and validation

**2. Service Layer** (`/lib/src/features/auth` & `/lib/src/core/services`)
- Business logic implementation
- Service orchestration
- External integrations (email, authentication)

**3. Core/Utility Layer** (`/lib/src/core`)
- Common services (Redis, Token, Email)
- Constants and configurations
- Validators and extensions
- Exception handling

**4. Data Layer**
- MongoDB for persistent storage
- Redis for caching and session management

---

## Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Runtime** | Dart | ^3.11.0 |
| **Framework** | Dart Frog | ^1.1.0 |
| **Database (Primary)** | MongoDB | Latest |
| **Cache/Session** | Redis | Latest |
| **Password Hashing** | BCrypt | ^1.2.0 |
| **JWT** | dart_jsonwebtoken | ^3.4.1 |
| **Email Service** | SendGrid | ^7.1.0 (mailer) |
| **Environment Config** | dotenv | ^4.2.0 |
| **ID Generation** | UUID | ^4.5.3 |
| **Testing** | test + mocktail | ^1.0.0 |
| **Linting** | dart_frog_lint | ^0.1.0 |

---

## Project Structure

```
dart_auth_backend/
├── lib/
│   └── src/
│       ├── core/
│       │   ├── constant.dart           # Application constants
│       │   ├── exceptions.dart         # Custom exception classes
│       │   ├── extensions.dart         # Dart extensions
│       │   ├── validators.dart         # Input validation utilities
│       │   └── services/
│       │       ├── redis_service.dart  # Redis operations and caching
│       │       ├── token_service.dart  # JWT generation and verification
│       │       └── email_service.dart  # SendGrid email integration
│       └── features/
│           └── auth/
│               ├── auth_service.dart   # Core authentication logic
│               ├── auth_model.dart     # User model and data structures
│               └── auth_validators.dart # Auth-specific validators
├── routes/
│   ├── index.dart                      # Root endpoint
│   └── api/
│       └── v1/
│           └── auth/
│               ├── _middleware.dart    # Auth middleware
│               ├── register.dart       # User registration endpoint
│               ├── login.dart          # User login endpoint
│               ├── send-otp.dart       # OTP request endpoint
│               ├── verify-otp.dart     # OTP verification endpoint
│               ├── forgot-password.dart # Password reset request
│               ├── change-password.dart# Change password endpoint
│               ├── refresh-token.dart  # Token refresh endpoint
│               └── delete-account.dart # Account deletion endpoint
├── test/
│   └── routes/
│       └── index_test.dart             # Route tests
├── .env                                # Environment variables (local)
├── main.dart                           # Application entry point
├── pubspec.yaml                        # Dart package configuration
├── pubspec.lock                        # Dependency lock file
├── analysis_options.yaml               # Linting configuration
└── README.md                           # Documentation
```

---

## Setup & Installation

### Prerequisites

- **Dart SDK**: ^3.11.0 ([Download](https://dart.dev/get-dart))
- **MongoDB**: Running instance (local or cloud)
- **Redis**: Running instance (local or cloud)
- **SendGrid Account**: For email delivery ([Sign up](https://sendgrid.com/))

### Step 1: Clone the Repository

```bash
git clone https://github.com/MJdugule/Dart-Auth-Backend.git
cd dart_auth_backend
```

### Step 2: Install Dependencies

```bash
dart pub get
```

This installs all required packages as defined in `pubspec.yaml`.

### Step 3: Environment Configuration

Create or update a `.env` file in the project root:

```bash
# Redis Configuration
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# MongoDB Configuration
MONGO_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/?appName=<AppName>

# SendGrid Configuration
SEND_GRID_API=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
VERIFIED_EMAIL=noreply@yourdomain.com
```

**Environment Variables Explanation:**

| Variable | Description | Example |
|----------|-------------|---------|
| `REDIS_HOST` | Redis server hostname | `127.0.0.1` or `redis.example.com` |
| `REDIS_PORT` | Redis server port | `6379` |
| `MONGO_URI` | MongoDB connection string (includes auth) | `mongodb+srv://user:pass@cluster.mongodb.net/?appName=App` |
| `SEND_GRID_API` | SendGrid API key | `SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| `VERIFIED_EMAIL` | Verified sender email for SendGrid | `noreply@yourdomain.com` |

---

## 🚀 Running the Application

### Development Mode

```bash
dart_frog dev
```

Server starts on `http://localhost:8080`

**Output:**
```
--- Launching Monolith Services Startup Sequence ---
💾 Connected to MongoDB successfully.
✨ Listening on http://0.0.0.0:8080
```

### Production Build

```bash
dart_frog build
```

Creates an optimized build in `build/` directory.

### Run Production Build

```bash
./build/dart_auth_backend
```

---

##  API Endpoints

All endpoints are prefixed with `/api/v1/auth/`

## ✨ Key Features

### 1. **Secure Authentication**
- BCrypt password hashing with salt
- JWT-based token system (access + refresh tokens)
- Token expiration management (15 min access, 7 days refresh)
- Secure token storage in Redis

### 2. **OTP Verification**
- 6-digit OTP generation
- Email delivery via SendGrid
- 5-minute OTP validity window
- 60-second rate limiting between OTP requests
- Automatic OTP expiration in Redis

### 3. **Password Security**
- Password hashing with BCrypt
- Forgot password workflow with reset tokens
- Password change with old password verification
- Secure password reset via email

### 4. **Session Management**
- Redis-based caching for OTP and tokens
- Automatic TTL management
- Rate limiting for OTP requests
- Cooldown window enforcement

### 5. **Email Integration**
- SendGrid API integration
- Automated OTP email delivery
- Customizable email templates
- Verified sender email configuration

### 6. **Database Integration**
- MongoDB for persistent user storage
- User document schema with referral support
- Created date tracking
- Active status management

### 7. **Error Handling**
- Custom exception classes
- Standardized error responses
- Validation error messages
- HTTP status code mapping

### 8. **Middleware**
- Authentication validation middleware
- Token extraction and verification
- Protected route enforcement

---

## Development

### Project Standards

- **Language**: Dart 3.11+
- **Framework**: Dart Frog
- **Code Style**: Dart conventions (PascalCase for classes, camelCase for variables)
- **Documentation**: Comprehensive code comments for complex logic

### Running Tests

```bash
# Run all tests
dart test

# Run specific test file
dart test test/routes/index_test.dart

# Run with coverage (requires coverage package)
dart pub global activate coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.packages
```

### Code Quality

```bash
# Analyze code for issues
dart analyze

# Run linter
dart_frog_lint
```

### Key Service Classes

#### AuthService
Orchestrates authentication flows including registration, login, and OTP management.

#### TokenService
Handles JWT token generation, validation, and password hashing.

#### EmailService
Integrates with SendGrid for email delivery.

#### RedisService
Manages Redis operations for caching and session management.

### Docker Deployment (Example)

```dockerfile
FROM dart:3.11

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

COPY . .
RUN dart_frog build

EXPOSE 8080

CMD ["./build/dart_auth_backend"]
```

---

## Additional Resources

- [Dart Documentation](https://dart.dev/guides)
- [Dart Frog Documentation](https://dartfrog.vvv.dev/)
- [MongoDB Dart Driver](https://pub.dev/packages/mongo_dart)
- [JWT Documentation](https://tools.ietf.org/html/rfc7519)
- [BCrypt Security](https://en.wikipedia.org/wiki/Bcrypt)
- [SendGrid Email API](https://sendgrid.com/docs/)


---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💼 Support

For issues, questions, or suggestions:
- Open an issue on GitHub

---

**Last Updated**: June 28, 2024  
**Version**: 1.0.0
