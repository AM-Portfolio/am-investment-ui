# Google Sign-In Setup Guide

This guide will help you set up Google Sign-In for your AM Investment Flutter web app.

## Prerequisites
- A Google account
- Access to Google Cloud Console

## Step-by-Step Setup

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on the project dropdown (top-left) → "New Project"
3. Name your project (e.g., "AM Investment Auth")
4. Click "Create"

### 2. Enable Google Sign-In API

1. In your project, go to "APIs & Services" → "Library"
2. Search for "Google Identity Services"
3. Click "Enable"

### 3. Configure OAuth Consent Screen

1. Go to "APIs & Services" → "OAuth consent screen"
2. Select "External" (for testing) or "Internal" (for organization)
3. Click "Create"
4. Fill in the required fields:
   - App name: `AM Investment`
   - User support email: Your email
   - Developer contact: Your email
5. Click "Save and Continue"
6. Add scopes (optional for now, can skip)
7. Add test users if using External type
8. Click "Save and Continue"

### 4. Create Web OAuth Client ID

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth client ID"
3. Select "Web application"
4. Configure:
   - Name: `AM Investment Web Client`
   - Authorized JavaScript origins:
     - For local development: `http://localhost:5000`
     - For Replit: `https://YOUR-REPL-NAME.repl.co`
     - For production: Your production domain
   - Authorized redirect URIs (optional for now)
5. Click "Create"
6. **Copy your Client ID** - You'll need this!

### 5. Configure Your Flutter App

The app uses a configuration system with environment-specific properties files:
- `lib/assets/application.properties` - Base configuration
- `lib/assets/application-dev.properties` - Development overrides
- `lib/assets/application-prod.properties` - Production settings

#### Add Your Client ID to Configuration

**For Development:**
1. Open `lib/assets/application-dev.properties`
2. Add or update the line:
   ```properties
   google.web.clientId=YOUR-CLIENT-ID-HERE.apps.googleusercontent.com
   ```

**For Production:**
1. Open `lib/assets/application-prod.properties`
2. Add the production Client ID:
   ```properties
   google.web.clientId=YOUR-PRODUCTION-CLIENT-ID.apps.googleusercontent.com
   ```

**Important Notes:**
- ✅ The app automatically loads the correct config based on environment
- ✅ No code changes needed - just update the properties file
- ✅ Client ID is loaded from `ConfigService.config.google.webClientId`
- ❌ Never commit production Client IDs to public repositories (use Replit Secrets for production)

### 6. Test Google Sign-In

1. Rebuild and restart your Flutter app
2. Click "Continue with Google" button
3. Sign in with your Google account
4. Grant permissions
5. You should be logged in!

## Important Notes

### Security Best Practices
- ✅ **Always use environment variables** for production
- ✅ Keep your Client ID and Client Secret secure
- ✅ Only add trusted domains to authorized origins
- ❌ Never commit Client IDs to public repositories

### Testing
- If using "External" OAuth consent type, add test users in Google Cloud Console
- The app is not verified warning is normal during development
- Click "Advanced" → "Go to AM Investment (unsafe)" to proceed during testing

### Common Issues

#### "Access blocked: Authorization Error"
**Solution:** Make sure your domain is in "Authorized JavaScript origins"

#### "This app isn't verified"
**Solution:** Add yourself as a test user, or submit for verification (production only)

#### "Invalid client ID"
**Solution:** Double-check your Client ID matches exactly from Google Cloud Console

#### Sign-in popup blocked
**Solution:** Allow popups for your domain in browser settings

## Web-Specific Configuration

For Flutter web, Google Sign-In uses the **Google Identity Services (GIS)** SDK. The current implementation will automatically:
- Initialize with your Client ID
- Show the native Google Sign-In flow
- Handle authentication tokens
- Integrate with your Riverpod state management

## Verifying Setup

To verify your setup is correct:

1. Open browser DevTools (F12)
2. Go to Console tab
3. Click "Continue with Google"
4. Look for these logs:
   - ✅ "Google Sign-In initialized" 
   - ✅ "Starting Google Sign-In flow"
   - ✅ "Google Sign-In successful"

## Next Steps

After successful setup:
- [ ] Configure backend API to validate Google ID tokens
- [ ] Store user profiles in your database
- [ ] Add Google sign-out functionality
- [ ] Implement token refresh logic
- [ ] Set up production OAuth consent verification

## Support Resources

- [Google Identity Services Documentation](https://developers.google.com/identity/gsi/web)
- [Flutter google_sign_in Package](https://pub.dev/packages/google_sign_in)
- [OAuth 2.0 Scopes](https://developers.google.com/identity/protocols/oauth2/scopes)

---

**Need Help?** Check the console logs for detailed error messages and debugging information.
