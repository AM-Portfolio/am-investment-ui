# Daily Behavior Tracking Feature

## Overview
Added a new behavior tracking system to journal entries that allows traders to record their emotional and mental state at three key points during the trading day: Start (market open), Mid (during trading), and End (market close).

## Features

### 1. Behavior Tracking Fields
- **Start Behavior**: Captures how the trader felt at market open
- **Mid Behavior**: Captures how the trader felt during active trading
- **End Behavior**: Captures how the trader felt at market close

### 2. Field Characteristics
- **Compact Design**: Small text fields (1-2 lines) with minimal spacing
- **Contextual Icons**: 
  - 🌞 Start: `wb_sunny_outlined` (morning/market open)
  - ⏰ Mid: `access_time` (during trading hours)
  - 🌙 End: `nightlight_outlined` (evening/market close)
- **Smart Visibility**: Fields only show in view mode if they contain data
- **Edit Mode**: All three fields visible and editable when in edit mode

### 3. Visual Design
- Primary-colored container with light background
- Distinct border styling
- "Daily Behavior Tracking" header with psychology icon
- Compact padding (12px) for space efficiency
- Individual field borders with subtle styling

### 4. Data Storage
- Stored in `JournalEntry.customFields` map
- Keys: `startBehavior`, `midBehavior`, `endBehavior`
- Values: String text entered by user
- Only saves fields with non-empty content

### 5. Journal Card Indicator
- Shows psychology icon (🧠) in card header when behavior tracking data exists
- No label/count - just the icon to indicate presence
- Positioned after trade count and attachment count chips

## UI Layout Changes

### More Compact Design
- Reduced spacing from 16px to 12px between sections in right column
- More efficient use of vertical space
- Better content density

### Right Column Order (Top to Bottom)
1. Optional Fields (Entry Date, Trade ID, URL)
2. **Behavior Tracking** ← NEW
3. Mood/Sentiment/Tags
4. Trade Overview
5. Attachments

## Technical Implementation

### Files Modified
1. **journal_entry_form.dart**
   - Added 3 TextEditingControllers for behavior tracking
   - Added initialization from `customFields`
   - Added disposal of controllers
   - Created `_buildBehaviorTracking()` widget
   - Created `_buildBehaviorField()` helper widget
   - Updated save logic to store in `customFields`
   - Reduced spacing from 16px to 12px

2. **journal_card.dart**
   - Added behavior tracking indicator check
   - Added psychology icon chip to header
   - Updated spacing between chips

### State Management
```dart
// Controllers
late TextEditingController _startBehaviorController;
late TextEditingController _midBehaviorController;
late TextEditingController _endBehaviorController;

// Initialization
_startBehaviorController = TextEditingController(
  text: widget.entry?.customFields['startBehavior'] ?? ''
);

// Saving
customFields: {
  if (_startBehaviorController.text.trim().isNotEmpty) 
    'startBehavior': _startBehaviorController.text.trim(),
  if (_midBehaviorController.text.trim().isNotEmpty) 
    'midBehavior': _midBehaviorController.text.trim(),
  if (_endBehaviorController.text.trim().isNotEmpty) 
    'endBehavior': _endBehaviorController.text.trim(),
}
```

## Usage Guidelines

### For Traders
1. **In Edit Mode**: All three behavior fields are visible
2. **Fill Optional Fields**: Only complete the fields that feel relevant
3. **Track Patterns**: Over time, review how your behavior correlates with trade performance
4. **View Mode**: Only filled fields are displayed (empty fields are hidden)

### Example Use Cases
- **Start**: "Confident, well-rested, followed morning routine"
- **Mid**: "Felt FOMO on TSLA breakout, resisted overtrading"
- **End**: "Disciplined, stuck to plan, closed positions as planned"

## Benefits
- **Self-Awareness**: Track emotional patterns throughout trading days
- **Pattern Recognition**: Identify which mental states correlate with good/bad trades
- **Discipline Tracking**: Monitor adherence to trading psychology practices
- **Historical Review**: Look back at emotional context of past trades
- **Compact UI**: Doesn't clutter the form, only shows when relevant

## Future Enhancements
- Analytics dashboard showing behavior patterns
- Correlation analysis between behavior and trade outcomes
- Suggested prompts/templates for common behaviors
- Emoji quick-select for common emotional states
- Behavior trend charts over time
