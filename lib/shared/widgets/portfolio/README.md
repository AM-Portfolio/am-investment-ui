# Portfolio Quick Actions Widget

A comprehensive Flutter widget for handling portfolio operations through document uploads. This widget provides quick actions for creating portfolios and managing trade details using Excel documents.

## Features

- **Create Portfolio from Current Holdings**: Upload an XLS/XLSX file containing current holdings to create a new portfolio
- **Create Portfolio from Trade History**: Upload trade history documents to analyze and create portfolios
- **Add Trade Details**: Upload trade details to existing portfolios
- **Cross-platform Support**: Works on Web, Mobile, and Desktop platforms
- **File Validation**: Validates file types and extensions
- **Progress Indicators**: Shows upload and processing progress
- **Error Handling**: Comprehensive error handling with user feedback

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:am_investment_ui/widgets/shared/ui/portfolio_quick_actions.dart';

class MyPortfolioPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          PortfolioQuickActions(
            userId: 'your-user-id',
            portfolioId: 'optional-portfolio-id', // For adding trade details
            onActionCompleted: (actionType, result) {
              // Handle successful upload
              print('Action completed: $actionType');
            },
            onActionFailed: (actionType, error) {
              // Handle upload error
              print('Action failed: $actionType - $error');
            },
          ),
        ],
      ),
    );
  }
}
```

### Enhanced Usage with Portfolio Creation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:am_investment_ui/widgets/shared/ui/enhanced_portfolio_quick_actions.dart';

class MyEnhancedPortfolioPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          EnhancedPortfolioQuickActions(
            userId: 'your-user-id',
            portfolioId: 'optional-portfolio-id',
            onPortfolioCreated: (result) {
              if (result.isSuccess) {
                // Navigate to new portfolio or update UI
                print('Portfolio created: ${result.portfolioId}');
              }
            },
            onTradeDetailsAdded: (result) {
              if (result.isSuccess) {
                // Update portfolio display
                print('Added ${result.tradesAdded} trades');
              }
            },
            onError: (error) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## Widget Types

### 1. PortfolioQuickActions

The basic widget that handles document uploads and provides callbacks for success/failure.

**Properties:**
- `userId` (required): Current user identifier
- `portfolioId` (optional): Portfolio ID for adding trade details
- `onActionCompleted`: Callback when upload succeeds
- `onActionFailed`: Callback when upload fails

### 2. EnhancedPortfolioQuickActions

An enhanced version that includes portfolio creation and trade processing logic.

**Properties:**
- `userId` (required): Current user identifier
- `portfolioId` (optional): Portfolio ID for adding trade details
- `onPortfolioCreated`: Callback when portfolio is created
- `onTradeDetailsAdded`: Callback when trade details are added
- `onError`: General error callback

## Action Types

### PortfolioActionType.createFromHoldings
- **Purpose**: Create a new portfolio from current holdings document
- **Document Type**: Stock Portfolio
- **File Formats**: XLS, XLSX
- **Use Case**: Users have a spreadsheet with their current stock holdings

### PortfolioActionType.createFromTradeHistory
- **Purpose**: Create a portfolio by analyzing trade history
- **Document Type**: Trade Equity
- **File Formats**: XLS, XLSX
- **Use Case**: Users want to create a portfolio based on their historical trades

### PortfolioActionType.addTradeDetails
- **Purpose**: Add new trade details to an existing portfolio
- **Document Type**: Trade Equity
- **File Formats**: XLS, XLSX
- **Use Case**: Users want to update their portfolio with new trades

## File Requirements

### Supported Formats
- Excel files (.xls, .xlsx)
- File size validation is handled by the document service

### Document Categories
The widget uses the following document categories from your domain model:
- `DocumentCategory.stockPortfolio` - For holdings documents
- `DocumentCategory.tradeEq` - For trade-related documents

## Integration with Document Service

The widget integrates with your existing `DocumentUploadService` through Riverpod providers:

```dart
// The widget automatically uses this provider
final documentService = ref.read(documentUploadServiceProvider);
```

## Error Handling

The widget provides comprehensive error handling:

1. **File Validation Errors**: Invalid file types, missing files
2. **Upload Errors**: Network issues, service failures
3. **Processing Errors**: Document processing failures

Errors are displayed via SnackBar messages and callbacks.

## Customization

### Styling
The widget uses your app's theme automatically but you can customize:

```dart
// Custom colors are defined in the action configurations
static const Map<PortfolioActionType, PortfolioActionConfig> _actionConfigs = {
  PortfolioActionType.createFromHoldings: PortfolioActionConfig(
    color: Colors.blue, // Customize this
    icon: Icons.folder_open, // Customize this
    // ... other properties
  ),
};
```

### Custom Processing
Extend the `PortfolioCreationService` to implement your own portfolio creation logic:

```dart
class CustomPortfolioCreationService extends PortfolioCreationService {
  @override
  static Future<PortfolioCreationResult> createPortfolioFromDocument({
    // Your custom implementation
  }) async {
    // Custom logic here
  }
}
```

## Demo

Run the demo page to see the widget in action:

```dart
import 'package:am_investment_ui/features/portfolio/demo/portfolio_quick_actions_demo.dart';

// Navigate to demo
Navigator.of(context).push(PortfolioQuickActionsDemo.route());
```

## Dependencies

The widget requires these dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  file_picker: ^8.1.2
  # Your existing dependencies...
```

## Platform Support

- ✅ **Web**: Uses `Uint8List` for file handling
- ✅ **iOS**: Uses `File` objects
- ✅ **Android**: Uses `File` objects
- ✅ **Windows**: Uses `File` objects
- ✅ **macOS**: Uses `File` objects
- ✅ **Linux**: Uses `File` objects

## Best Practices

1. **Always provide a userId**: Required for document tracking
2. **Handle callbacks**: Implement success and error callbacks for better UX
3. **Validate file types**: The widget handles validation but verify your backend accepts the formats
4. **Show progress**: The widget includes progress indicators but consider additional loading states
5. **Error recovery**: Provide clear error messages and retry options

## Troubleshooting

### Common Issues

1. **MockDocumentClient not found**: Run `flutter packages pub run build_runner build`
2. **File picker not working**: Ensure file_picker dependency is properly added
3. **Upload failures**: Check your document service configuration and network connectivity

### Debug Mode

Enable debug prints in your document service to troubleshoot upload issues:

```dart
debugPrint('Upload parameters: fileName=$fileName, category=$category');
```