# Add Trade - Quick Reference

## 🚀 Quick Start

### Navigate to Add Trade Page
```dart
Navigator.pushNamed(
  context,
  '/trade/add',
  arguments: {
    'portfolioId': 'your-portfolio-id',
    'portfolioName': 'Portfolio Name', // Optional
  },
);
```

### Add FAB to Your Page
```dart
import '../widgets/add_trade_fab.dart';

// In your build method:
body: Stack(
  children: [
    YourContent(),
    PositionedAddTradeFAB(
      portfolioId: portfolioId,
      portfolioName: portfolioName,
    ),
  ],
)
```

## 📋 Form Steps

| Step | Purpose | Key Fields |
|------|---------|------------|
| 1. Instrument | Identify security | Symbol*, Exchange*, Segment, Derivative Info |
| 2. Entry | Trade execution | Direction*, Price*, Quantity*, Date* |
| 3. Exit | Close position | Exit Price, Exit Quantity, Exit Date |
| 4. Psychology | Mental state | Entry/Exit Psychology, Behavior Patterns |
| 5. Reasoning | Why traded | Technical Reasons, Fundamental Reasons |
| 6. Review | Final check | Summary + Additional Notes |

*Required fields

## 🎯 Field Types Reference

### Text Inputs
- Symbol, ISIN, Description
- Strike Price, Strategy, Notes
- Psychology Notes

### Dropdowns (Single Select)
- Exchange, Segment, Series
- Direction, Status, Broker
- Derivative Type, Option Type, Order Type

### Date Pickers
- Entry Date, Exit Date, Expiry Date

### Multi-Select Chips
- Entry Psychology Factors (11 options)
- Exit Psychology Factors (11 options)
- Behavior Patterns (8 options)
- Technical Reasons (16 options)
- Fundamental Reasons (9 options)

### Number Inputs
- Entry Price, Entry Quantity
- Exit Price, Exit Quantity
- Strike Price

## 📱 Responsive Breakpoints

```
Desktop   (≥1200px): 2-col grid, 900px max, extended FAB
Tablet    (800-1199): 2-col grid, compact layout, extended FAB  
Mobile    (<800px):   1-col stack, drawer menu, compact FAB
```

## 🎨 UI Components

### Progress Stepper
- Shows current step (1-6)
- Highlights completed steps
- Desktop: Shows labels
- Mobile: Numbers only

### Navigation Buttons
- **Previous**: Go back (disabled on step 1)
- **Next**: Continue (steps 1-5)
- **Save Trade**: Submit (step 6)
- **Cancel**: Exit with confirmation

### Conditional Fields
- Derivative details: Show when Derivative Type selected
- Exit details: Show when Status = Closed
- Option fields: Show when Derivative Type = Options

## ⚡ Key Features

### Smart Defaults
- Entry Date: Current date
- Direction: Long
- Status: Open

### Auto-Calculations (Future)
- Total Value = Price × Quantity
- P&L = Exit Total - Entry Total
- Holding Period = Exit Date - Entry Date

### Validation
- Required fields marked with *
- Inline error messages
- Final validation before save
- Prevents invalid submissions

## 🔗 Integration Points

### BLoC Methods
```dart
// Save trade
context.read<TradeControllerCubit>().addTrade(tradeDetails);

// Listen to state
BlocListener<TradeControllerCubit, TradeControllerState>(
  listener: (context, state) {
    if (state is TradeControllerSuccess) { /* Success */ }
    if (state is TradeControllerError) { /* Error */ }
  },
)
```

### Route Arguments
```dart
// Required
portfolioId: String

// Optional
portfolioName: String?
```

## 📦 Component Files

```
lib/features/trade/presentation/
├── components/templates/
│   └── add_trade_template.dart       (1,200 lines)
├── web/pages/
│   └── add_trade_web_page.dart       (200 lines)
└── widgets/
    └── add_trade_fab.dart             (80 lines)

docs/
└── ADD_TRADE_FEATURE.md               (Full documentation)

lib/
└── app.dart                           (Route added)
```

## 🧪 Testing Checklist

### Basic Flow
- [ ] Navigate from holdings page
- [ ] Fill all required fields
- [ ] Navigate through all steps
- [ ] Review summary
- [ ] Submit successfully
- [ ] Verify in holdings list

### Validation
- [ ] Try submitting without required fields
- [ ] Enter invalid data (negative price)
- [ ] Test date picker constraints

### Responsive
- [ ] Test on desktop (1920x1080)
- [ ] Test on tablet (768x1024)
- [ ] Test on mobile (375x667)

### Edge Cases
- [ ] Cancel with confirmation
- [ ] Handle network error
- [ ] Multiple rapid submissions

## 💡 Pro Tips

### For Developers
1. Use `_buildResponsiveGrid()` for consistent layouts
2. Controllers auto-disposed in `dispose()`
3. Page state maintained during navigation
4. All enums converted to readable strings

### For Users
1. Fill required fields first (marked with *)
2. Use chips for multiple selections
3. Skip exit details for open trades
4. Add notes for better tracking

## 🔮 Coming Soon

- Auto-save drafts
- Edit existing trades
- Bulk import
- Trade templates
- P&L preview
- Smart suggestions

## 📞 Support

### Common Issues

**Q: FAB not showing**  
A: Wrap body in Stack and use PositionedAddTradeFAB

**Q: Validation not working**  
A: Ensure Form key is set and validators return null on success

**Q: Dropdowns empty**  
A: Check enum imports from trade_controller_entities.dart

**Q: Save not triggering**  
A: Verify TradeControllerCubit is provided in widget tree

### Debug Mode
Enable logging:
```dart
AppLogger.methodEntry('Your method', tag: 'YourTag');
```

## 📚 Related Docs

- [Full Feature Documentation](./ADD_TRADE_FEATURE.md)
- [Trade Controller Entities](../lib/features/trade/internal/domain/entities/trade_controller_entities.dart)
- [Project Structure](./PROJECT_STRUCTURE.md)
