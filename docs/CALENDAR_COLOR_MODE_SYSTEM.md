# Calendar Color Mode System

## Overview
The Year Calendar now supports two color visualization modes to help analyze trading performance at a glance. The color logic is separated from UI components using a service pattern for maintainability.

## Color Modes

### 1. Win/Loss Mode
**Simple status-based coloring:**
- ✅ **Green** - Winning trades (profit > $0)
- ❌ **Red** - Losing trades (loss < $0)
- ➖ **Gray** - Breakeven trades (profit = $0)
- ⬜ **Transparent** - No trades

**Use case:** Quick visual identification of winning vs losing days.

### 2. Profit Intensity Mode
**Amount-based gradient coloring:**
- **Darker Green** - Higher profits (intensity based on P&L amount)
- **Lighter Green** - Lower profits
- **Darker Red** - Higher losses
- **Lighter Red** - Lower losses
- **Gray** - Breakeven
- **Transparent** - No trades

**Algorithm:** Uses logarithmic scale for better visual distribution
- Range: $10 to $1,000
- Intensity: 0.3 to 1.0 (30% to 100% saturation)
- HSL adjustments: lightness 0.3-0.5, saturation 0.4-0.8

**Use case:** Identify high-impact trading days by color intensity.

## Architecture

### Models
- **`CalendarColorMode`** - Enum with two values:
  - `winLoss` - Simple status-based
  - `profitIntensity` - Gradient intensity-based
  - Extensions: `displayName`, `description`

### Services
- **`CalendarColorService`** - Centralized color calculation logic
  - `getDayColor()` - Calculate day cell color
  - `getMonthBackgroundColor()` - Subtle month card backgrounds
  - `getMonthBorderColor()` - Month card border colors
  - `getTextColor()` - Contrast text colors (white/dark based on intensity)
  - `getBorderColor()` - Day cell border colors

### Components
- **`ColorModeSelector`** - UI widget for mode selection
  - Compact variant: Dropdown only (for headers)
  - Full variant: With icon and descriptions (for settings)

## Data Flow

```
YearCalendarWidget (manages state)
  ↓ (creates CalendarColorService based on selected mode)
  ↓
MonthsGrid (receives colorService)
  ↓
MonthCalendarCard (applies background/border colors)
  ↓
CalendarDayCell (applies day colors)
```

## Usage

### Basic Usage
```dart
YearCalendarWidget(
  year: 2024,
  monthsData: monthsData,
  initialColorMode: CalendarColorMode.profitIntensity, // Default mode
)
```

### Switching Modes
The color mode selector appears in the calendar header:
- **Desktop:** Between stats and legend
- **Mobile:** Next to legend in top right

Users can switch between modes in real-time using the dropdown selector.

## Color Calculations

### Win/Loss Mode
```dart
if (profit > 0) return Colors.green;
if (profit < 0) return Colors.red;
return Colors.grey; // breakeven
```

### Profit Intensity Mode
```dart
// Calculate intensity using logarithmic scale
final intensity = _calculateIntensity(amount);

// Adjust HSL color based on intensity
final hslColor = HSLColor.fromColor(baseColor);
final adjustedColor = hslColor.withLightness(lightness).withSaturation(saturation);
```

**Logarithmic Intensity Formula:**
```dart
intensity = (log(amount) - log(minAmount)) / (log(maxAmount) - log(minAmount))
intensity = clamp(intensity, 0.3, 1.0) // 30% to 100%
```

## Month Card Backgrounds

Month cards receive subtle background colors based on total P&L:
- **Win/Loss Mode:** Based on win rate (50%+ = green)
- **Profit Intensity Mode:** Based on total P&L with logarithmic intensity
- Opacity: 0.03 (very subtle, doesn't overwhelm)

## Text Contrast

Text colors automatically adjust based on background intensity:
- **High intensity backgrounds** (dark colors): White text
- **Low intensity backgrounds** (light colors): Dark text

Ensures readability across all color modes and intensities.

## Key Features

✅ **Modular Architecture** - Color logic separated from UI components  
✅ **Service Pattern** - Single source of truth for color calculations  
✅ **Responsive Design** - Works on mobile, tablet, desktop  
✅ **Real-time Switching** - No page reload needed  
✅ **Accessible** - High contrast text, clear visual hierarchy  
✅ **Logarithmic Scale** - Better visual distribution of amounts  
✅ **Month-level Insights** - Card backgrounds reflect month performance  

## Files Created

1. **Models:**
   - `models/calendar_color_mode.dart` - Enum definition

2. **Services:**
   - `services/calendar_color_service.dart` - Color calculation logic

3. **Components:**
   - `components/color_mode_selector.dart` - UI selector widget

4. **Updated Components:**
   - `calendar_day_cell.dart` - Uses color service
   - `month_calendar_card.dart` - Applies background/border colors
   - `months_grid.dart` - Passes color service down
   - `year_calendar_widget.dart` - Manages color mode state
   - `year_calendar_header.dart` - Integrates color mode selector

5. **Exports:**
   - `year_calendar_exports.dart` - Updated barrel exports

## Testing Checklist

- [ ] Win/Loss mode shows correct colors (green/red/gray)
- [ ] Profit Intensity mode shows gradient effect
- [ ] Month backgrounds change based on P&L
- [ ] Text remains readable on all backgrounds
- [ ] Switching modes updates calendar in real-time
- [ ] Compact selector fits in header (desktop)
- [ ] Mobile layout shows selector correctly
- [ ] No performance issues with color recalculation
- [ ] Responsive design maintained across breakpoints

## Future Enhancements

- Custom color themes (user-defined colors)
- Heatmap mode (different color scales)
- Volatility mode (color by volatility/risk)
- Time-of-day intensity (morning/afternoon performance)
- Configurable intensity ranges
- Export color-coded calendar as image
