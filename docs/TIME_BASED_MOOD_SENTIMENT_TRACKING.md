# Time-Based Mood & Sentiment Tracking

## Overview
Enhanced the journal entry system to track mood and market sentiment at three different times during the trading day (Start, Mid, End), allowing traders to see how their emotional state and market outlook evolve throughout the session.

## Problem Solved
Previously, mood and sentiment were captured as single values, which didn't reflect the reality that a trader's emotional state and market perception change throughout the day. A trader might start confident, become anxious mid-day, and end frustrated - capturing just one mood missed important psychological patterns.

## Solution
Split mood and sentiment tracking into three time periods:
- **Start**: Market open / beginning of trading session
- **Mid**: During active trading hours
- **End**: Market close / end of trading session

## Features

### 1. Time-Based Mood Tracking
Three separate mood selectors for different times of day:
- **Start Mood**: How you felt at market open (🌞)
- **Mid Mood**: How you felt during trading (⏰)
- **End Mood**: How you felt at market close (🌙)

Each period can independently track:
- 😊 Confident
- 😐 Neutral
- 😰 Anxious
- 😤 Frustrated
- 🎯 Focused
- 😴 Tired

### 2. Time-Based Sentiment Tracking
Three separate sentiment selectors for different times of day:
- **Start Sentiment**: Market outlook at open
- **Mid Sentiment**: Market outlook during trading
- **End Sentiment**: Market outlook at close

Each period can independently track:
- 📉 Very Bearish
- 📊 Bearish
- ➖ Neutral
- 📈 Bullish
- 🚀 Very Bullish

### 3. Smart Visibility
- **Edit Mode**: All three periods visible for both mood and sentiment
- **View Mode**: Only shows periods that have data (hides empty periods)
- **Empty State**: If no mood/sentiment data exists, entire sections hidden in view mode

### 4. Visual Design
**Mood Container**:
- Secondary color theme (distinct from behavior tracking)
- Light background with subtle border
- Header: "Mood" with satisfaction icon
- Compact 12px padding

**Sentiment Container**:
- Tertiary color theme (distinct from both mood and behavior)
- Light background with subtle border
- Header: "Market Sentiment" with trending icon
- Compact 12px padding

**Period Labels**:
- Small icons (12px) for time period
- Subtle label styling
- Minimal spacing (6px) between label and selector

### 5. Data Storage
Stored in `JournalEntry.customFields` map with keys:
- `startMood`, `midMood`, `endMood`
- `startSentiment`, `midSentiment`, `endSentiment`

**Backward Compatibility**:
- Legacy `mood` field stores most recent mood (end → mid → start priority)
- Legacy `marketSentiment` field stores most recent sentiment (end → mid → start priority)
- On load, if new fields don't exist, falls back to legacy fields for end period

## UI Layout

### Right Column Order
1. Optional Fields (Date, Trade ID, URL)
2. Behavior Tracking (Start/Mid/End)
3. **Mood Tracking** (Start/Mid/End) ← NEW LAYOUT
4. **Market Sentiment** (Start/Mid/End) ← NEW LAYOUT
5. Tags
6. Trade Overview
7. Attachments

### Compact Design
- Reduced section spacing to 12px
- Each period within mood/sentiment: 8px spacing
- Minimal padding throughout (10-12px)
- Dense form controls

## Technical Implementation

### State Management
```dart
// Time-based mood tracking
String? _startMood;
String? _midMood;
String? _endMood;

// Time-based sentiment tracking
String? _startSentiment;
String? _midSentiment;
String? _endSentiment;
```

### Initialization
```dart
// Load from customFields, fallback to legacy for end period
_startMood = widget.entry?.customFields['startMood'];
_midMood = widget.entry?.customFields['midMood'];
_endMood = widget.entry?.customFields['endMood'] ?? 
          JournalHelpers.mapMoodFromEntry(widget.entry?.mood);

_startSentiment = widget.entry?.customFields['startSentiment'];
_midSentiment = widget.entry?.customFields['midSentiment'];
_endSentiment = widget.entry?.customFields['endSentiment'] ?? 
                JournalHelpers.mapSentimentFromValue(widget.entry?.marketSentiment);
```

### Saving Data
```dart
customFields: {
  // Behavior tracking
  if (_startBehaviorController.text.trim().isNotEmpty) 
    'startBehavior': _startBehaviorController.text.trim(),
  if (_midBehaviorController.text.trim().isNotEmpty) 
    'midBehavior': _midBehaviorController.text.trim(),
  if (_endBehaviorController.text.trim().isNotEmpty) 
    'endBehavior': _endBehaviorController.text.trim(),
  
  // Mood tracking
  if (_startMood != null) 'startMood': _startMood!,
  if (_midMood != null) 'midMood': _midMood!,
  if (_endMood != null) 'endMood': _endMood!,
  
  // Sentiment tracking
  if (_startSentiment != null) 'startSentiment': _startSentiment!,
  if (_midSentiment != null) 'midSentiment': _midSentiment!,
  if (_endSentiment != null) 'endSentiment': _endSentiment!,
}

// Backward compatibility - store most recent in legacy fields
mood: JournalHelpers.getMoodString(_endMood ?? _midMood ?? _startMood),
marketSentiment: JournalHelpers.getSentimentValue(_endSentiment ?? _midSentiment ?? _startSentiment),
```

### Widget Structure
```dart
Widget _buildMoodSentimentTracking() {
  return Column(
    children: [
      // Mood Container
      Container(
        child: Column(
          children: [
            _buildMoodPeriod('Start', Icons.wb_sunny_outlined, _startMood, ...),
            _buildMoodPeriod('Mid', Icons.access_time, _midMood, ...),
            _buildMoodPeriod('End', Icons.nightlight_outlined, _endMood, ...),
          ],
        ),
      ),
      
      // Sentiment Container
      Container(
        child: Column(
          children: [
            _buildSentimentPeriod('Start', Icons.wb_sunny_outlined, _startSentiment, ...),
            _buildSentimentPeriod('Mid', Icons.access_time, _midSentiment, ...),
            _buildSentimentPeriod('End', Icons.nightlight_outlined, _endSentiment, ...),
          ],
        ),
      ),
    ],
  );
}
```

## Usage Examples

### Example 1: Volatile Day
**Morning (Start)**:
- Mood: 😊 Confident
- Sentiment: 📈 Bullish

**Midday (Mid)**:
- Mood: 😰 Anxious (market dropped unexpectedly)
- Sentiment: 📊 Bearish (reversing outlook)

**Evening (End)**:
- Mood: 🎯 Focused (regained composure)
- Sentiment: ➖ Neutral (waiting for clarity)

### Example 2: Disciplined Day
**Morning (Start)**:
- Mood: 🎯 Focused
- Sentiment: 📈 Bullish

**Midday (Mid)**:
- Mood: 🎯 Focused (staying disciplined)
- Sentiment: 📈 Bullish (conviction holding)

**Evening (End)**:
- Mood: 😊 Confident (plan worked)
- Sentiment: 📈 Bullish (confirmed thesis)

### Example 3: Partial Tracking
**Morning (Start)**:
- Mood: 😴 Tired
- Sentiment: (not set - wasn't sure yet)

**Midday (Mid)**:
- Mood: (not set - didn't track)
- Sentiment: 📊 Bearish (signs appeared)

**Evening (End)**:
- Mood: 😤 Frustrated (missed opportunities due to fatigue)
- Sentiment: 📊 Bearish (confirmed bearish bias)

## Benefits

### For Traders
1. **Pattern Recognition**: See how moods evolve during winning vs losing days
2. **Early Warning System**: Identify when mood deteriorates mid-day
3. **Sentiment Shifts**: Track how market perception changes through the session
4. **Discipline Tracking**: Monitor emotional stability throughout the day
5. **Correlation Analysis**: Connect emotional shifts to specific trades or market events

### For Trading Psychology
1. **Emotional Awareness**: Better understanding of intraday emotional cycles
2. **Trigger Identification**: Pinpoint when emotional shifts occur
3. **Recovery Patterns**: Track how quickly you recover from setbacks
4. **Optimal Trading Times**: Identify periods when you're most/least effective
5. **Fatigue Monitoring**: Detect patterns of end-of-day decision-making deterioration

### For Performance Analysis
1. **Granular Data**: More detailed emotional context for trades
2. **Time-of-Day Performance**: Correlate mood/sentiment with trade timing
3. **Market Condition Response**: See how you react to different market phases
4. **Behavioral Trends**: Identify long-term patterns in emotional responses
5. **Coaching Insights**: Provide detailed data for trading coaches/mentors

## Future Enhancements
- Visual timeline showing mood/sentiment progression throughout day
- Automated alerts when mood deteriorates significantly mid-day
- Correlation charts between mood shifts and trade performance
- Suggested actions based on historical mood patterns
- Export mood/sentiment data for external analysis
- AI-powered insights on emotional patterns
- Mood/sentiment heatmaps over weeks/months
- Peer comparison (anonymized aggregate data)

## Migration Notes
- Existing entries maintain their single mood/sentiment values
- On first edit, legacy values populate the "End" period
- Start and Mid periods start empty
- No data loss - legacy fields still populated for backward compatibility
- Journal cards continue to work with legacy mood field
