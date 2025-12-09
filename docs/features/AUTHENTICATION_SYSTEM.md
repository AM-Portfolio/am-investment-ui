# Authentication System Documentation

## Overview

Comprehensive authentication system for AM Investment UI with API integration, developer mode, and responsive template design for web and mobile platforms.

**API Base URL:** `https://api.munish.org`

---

## Project Structure

Authentication system organized into features with clean architecture separation including data sources, domain logic, presentation layers, core templates, and developer tools.

---

## Development Phases

### Phase 1: Core Authentication
User registration with email and password validation, standard login flow with JWT token management, and comprehensive error handling for all authentication scenarios.

### Phase 2: Google OAuth Integration
OAuth flow implementation with Google account linking, platform-specific handling for web and mobile environments, and secure credential exchange.

### Phase 3: Developer Mode System
JWT scope validation for test-user access control, conditional developer widget display based on token permissions, and debugging tools for authorized developers.

### Phase 4: Template System
Responsive base templates and reusable component library, web and mobile adaptive layouts with consistent theme integration across platforms.

### Phase 5: Advanced Features
Password reset functionality with email-based tokens, session management with refresh capabilities, and multi-platform performance optimizations.

---

## Authentication Endpoints

### User Registration
Endpoint for new user signup requiring email, password, and phone number with validation and account status tracking.
**API Reference:** `lib/assets/register.txt`

### User Login 
Standard email and password authentication returning user details, permissions scope, and JWT access token for session management.
**API Reference:** `lib/assets/login.txt`

### Google OAuth Login
Social login integration with Google OAuth requiring Google ID and email, supporting new user creation and account linking.
**API Reference:** `lib/assets/google-login.txt`

### User Registration (UI Complete, Integration Pending)
New user signup with email, password, and phone validation. Registration screen is fully implemented with comprehensive form validation.
**API Reference:** `lib/assets/mock_data/user/register.txt`
**UI Location:** `lib/features/authentication/presentation/pages/register_page.dart`
**Status:** UI complete, awaiting use case integration with AuthCubit

### Forgot Password (UI Complete, Integration Pending)
Password reset initiation endpoint sending secure reset tokens via email for account recovery workflows. Forgot password screen is fully implemented.
**API Reference:** `lib/assets/mock_data/user/forgot-password.txt`
**UI Location:** `lib/features/authentication/presentation/pages/forgot_password_page.dart`
**Status:** UI complete, awaiting use case integration with AuthCubit

### Reset Password (UI Complete, Integration Pending)
Password reset completion endpoint accepting reset tokens and new password for secure account recovery. Reset password screen is fully implemented.
**API Reference:** `lib/assets/mock_data/user/reset-password.txt`
**UI Location:** `lib/features/authentication/presentation/pages/reset_password_page.dart`
**Status:** UI complete, awaiting use case integration with AuthCubit

**⚠️ Important Note:** Registration and password reset features have complete UI screens and business logic use cases, but are not yet integrated with the AuthCubit due to dual auth system architecture. See `AUTHENTICATION_IMPLEMENTATION_STATUS.md` for details and next steps.

---

## Data Models

### User Status Types
Account status tracking including active verified accounts, pending verification for new registrations, suspended accounts for policy violations, and inactive deactivated accounts.

### User Permissions and Scopes
Permission system with read access for user data and portfolios, write access for creating and updating content, profile access for extended information, test-user scope for developer mode access, and admin privileges for system management.

---

## Developer Mode

### Overview
Conditional developer widget system that displays advanced debugging and testing tools only when users have appropriate developer permissions in their JWT token scope.

### Core Features
API testing interface for endpoint validation, debug information display showing token scopes and user details, application cache management tools, and responsive design adapting to web and mobile layouts.

### Security Implementation
Zero-trust scope validation ensuring widgets only appear for authorized users, production environment detection automatically disabling developer tools, read-only debugging capabilities without data modification access, and token expiration handling for session security.

### Usage Workflow
Developer widget automatically appears on authenticated pages when user tokens contain test-user scope. Account setup instructions and verification procedures available in external reference files.

---

## Security Architecture

### Token Storage Strategy
Web implementation using HTTP-only cookies for enhanced security, mobile implementation with Flutter Secure Storage for encrypted local storage, and current temporary LocalStorage solution requiring future upgrade.

### API Security Measures
HTTPS enforcement across all endpoints, JWT token expiration handling with configurable timeouts, and planned refresh token mechanism for seamless session renewal.

### OAuth Security Implementation
Google Client ID validation with domain authorization controls, secure credential validation on backend systems, and protection against token manipulation attacks.

---

## Template Design System

### Design Philosophy
Comprehensive template system ensuring consistent design patterns across web and mobile platforms with responsive-first approach, consistent branding and spacing standards, modular reusable components, platform-specific optimizations, and built-in accessibility features.

### Template Categories
Base page templates providing foundation with navigation and loading states, authentication form templates with validation and social login integration, standardized form field templates with platform-specific keyboards, and consistent button templates with loading states and feedback.

### Platform Adaptations
Web optimization with centered card layouts and hover effects for desktop interactions, mobile optimization with full-width layouts and touch-friendly components for mobile devices.

### Responsive System
Breakpoint system at 600px for mobile, 900px for tablet, and 1200px for desktop with automatic layout adaptation and component scaling.

---

## API Reference System

### File Organization
External reference files organized by authentication endpoints, developer mode setup and examples, and platform-specific request collections including Postman automation scripts.

### Usage Guidelines
Reference external files for complete curl commands and response examples rather than embedding lengthy code in documentation, maintaining separation of concerns between documentation and implementation details.

---

## Testing Strategy

### Coverage Requirements
Unit testing targeting 80% coverage for core authentication logic, integration testing for end-to-end authentication flows, widget testing for UI components and templates, and performance testing for response times and resource usage optimization.

### Key Testing Scenarios
Token validation and scope checking for security verification, API integration success and error handling for reliability, developer mode conditional display for access control, and responsive template rendering across device types.

---

## Error Management

### Common Error Categories
Invalid credentials for wrong login information, user not found for unregistered accounts, invalid tokens for expired or malformed JWT, insufficient scope for missing developer permissions, and network errors for connection issues.

### Error Handling Strategy
Comprehensive error response system with user-friendly messages, graceful degradation for network issues, and detailed logging for debugging and monitoring purposes.

---

## Future Development

### Planned Enhancements
Email verification system with automated workflows, comprehensive password reset flow with security tokens, refresh token mechanism for seamless session management, multi-factor authentication with SMS and authenticator support, additional social login providers for user convenience, and enhanced developer tools for improved debugging capabilities.

### Scalability Considerations
Performance optimizations for high user loads, security enhancements for evolving threat landscape, and user experience improvements based on feedback and analytics.

---

## Troubleshooting Guide

### Common Resolution Paths
Google OAuth issues requiring domain authorization in Google Console, API connection problems needing base URL accessibility verification, developer mode visibility requiring test-user scope validation in JWT tokens, and token-related issues needing expiration and format validation.

### Support Resources
Comprehensive troubleshooting documentation with step-by-step resolution guides, external reference files for technical details, and escalation procedures for complex issues.

---

*Last Updated: October 11, 2025*
*Version: 2.0.0 - Documentation Rewritten Without Code Examples*
