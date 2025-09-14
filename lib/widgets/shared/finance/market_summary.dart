import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A widget that displays market summary information with modern UI/UX
class MarketSummary extends StatefulWidget {
  /// Whether to show the full market summary with additional indices
  final bool showFull;
  
  /// Callback when the "View Full Market Summary" button is pressed
  final VoidCallback? onViewFullSummary;
  
  /// Constructor
  const MarketSummary({
    Key? key,
    this.showFull = false,
    this.onViewFullSummary,
  }) : super(key: key);
  
  @override
  State<MarketSummary> createState() => _MarketSummaryState();
}

class _MarketSummaryState extends State<MarketSummary> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isHovering = false;
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Dummy market data - basic indices with historical data for trends
    final basicMarketData = [
      {
        'name': 'NIFTY 50', 
        'value': '22,456.30', 
        'change': '+1.2%', 
        'isPositive': true,
        'trend': [22100.45, 22250.30, 22180.75, 22300.20, 22456.30],
        'dayChange': '+356.30',
        'icon': Icons.trending_up,
      },
      {
        'name': 'SENSEX', 
        'value': '73,890.45', 
        'change': '+0.9%', 
        'isPositive': true,
        'trend': [73200.10, 73450.25, 73380.60, 73700.30, 73890.45],
        'dayChange': '+690.45',
        'icon': Icons.trending_up,
      },
      {
        'name': 'NIFTY BANK', 
        'value': '48,123.75', 
        'change': '-0.3%', 
        'isPositive': false,
        'trend': [48300.20, 48250.10, 48180.30, 48150.25, 48123.75],
        'dayChange': '-176.45',
        'icon': Icons.trending_down,
      },
    ];
    
    // Additional indices for full view
    final additionalMarketData = [
      {
        'name': 'NIFTY IT', 
        'value': '35,678.20', 
        'change': '+2.1%', 
        'isPositive': true,
        'trend': [34900.10, 35100.30, 35300.50, 35500.80, 35678.20],
        'dayChange': '+778.10',
        'icon': Icons.trending_up,
      },
      {
        'name': 'MIDCAP', 
        'value': '12,345.60', 
        'change': '+0.7%', 
        'isPositive': true,
        'trend': [12250.30, 12280.45, 12300.20, 12320.10, 12345.60],
        'dayChange': '+95.30',
        'icon': Icons.trending_up,
      },
      {
        'name': 'NIFTY AUTO', 
        'value': '18,765.30', 
        'change': '-0.5%', 
        'isPositive': false,
        'trend': [18850.20, 18830.10, 18800.30, 18780.40, 18765.30],
        'dayChange': '-84.90',
        'icon': Icons.trending_down,
      },
      {
        'name': 'NIFTY PHARMA', 
        'value': '14,523.80', 
        'change': '+1.3%', 
        'isPositive': true,
        'trend': [14350.20, 14380.45, 14420.30, 14480.60, 14523.80],
        'dayChange': '+173.60',
        'icon': Icons.trending_up,
      },
      {
        'name': 'NIFTY METAL', 
        'value': '7,890.45', 
        'change': '-1.2%', 
        'isPositive': false,
        'trend': [7985.30, 7960.20, 7940.10, 7910.30, 7890.45],
        'dayChange': '-94.85',
        'icon': Icons.trending_down,
      },
    ];
    
    // Combine data based on showFull parameter
    final unsortedMarketData = widget.showFull 
        ? [...basicMarketData, ...additionalMarketData]
        : basicMarketData;
        
    // Sort data by positive first, then negative
    final marketData = List.from(unsortedMarketData);
    marketData.sort((a, b) {
      final aPositive = a['isPositive'] as bool;
      final bPositive = b['isPositive'] as bool;
      
      if (aPositive && !bPositive) return -1; // a is positive, b is negative
      if (!aPositive && bPositive) return 1;  // a is negative, b is positive
      
      // Both are positive or both are negative, sort by change percentage magnitude
      final aChange = double.parse((a['change'] as String).replaceAll('%', '').replaceAll('+', ''));
      final bChange = double.parse((b['change'] as String).replaceAll('%', '').replaceAll('+', ''));
      
      // For positive values, higher is better (descending)
      // For negative values, lower is worse (ascending)
      return aPositive ? -aChange.compareTo(bChange) : aChange.compareTo(bChange);
    });
        
    // Market categories for tab view
    final marketCategories = [
      {'name': 'Indices', 'data': marketData},
      {'name': 'Global Markets', 'data': [
        {
          'name': 'DOW JONES', 
          'value': '38,789.60', 
          'change': '+0.8%', 
          'isPositive': true,
          'trend': [38500.30, 38600.45, 38650.20, 38700.10, 38789.60],
          'dayChange': '+289.30',
          'icon': Icons.trending_up,
        },
        {
          'name': 'NASDAQ', 
          'value': '16,245.30', 
          'change': '+1.1%', 
          'isPositive': true,
          'trend': [16050.20, 16100.10, 16150.30, 16200.40, 16245.30],
          'dayChange': '+195.10',
          'icon': Icons.trending_up,
        },
        {
          'name': 'FTSE 100', 
          'value': '8,145.20', 
          'change': '-0.4%', 
          'isPositive': false,
          'trend': [8180.30, 8170.20, 8160.10, 8150.30, 8145.20],
          'dayChange': '-35.10',
          'icon': Icons.trending_down,
        },
      ]},
    ];
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Card(
        elevation: _isHovering ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with tabs
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: marketCategories[0]['name'] as String),
                  Tab(text: marketCategories[1]['name'] as String),
                ],
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
              ),
              const SizedBox(height: 16),
              
              // Tab content
              widget.showFull
              ? Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Indices tab
                      _buildMarketList(theme, marketCategories[0]['data'] as List),
                      
                      // Global Markets tab
                      _buildMarketList(theme, marketCategories[1]['data'] as List),
                    ],
                  ),
                )
              : SizedBox(
                  height: 220,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Indices tab
                      _buildMarketList(theme, marketCategories[0]['data'] as List),
                      
                      // Global Markets tab
                      _buildMarketList(theme, marketCategories[1]['data'] as List),
                    ],
                  ),
                ),
              
              // Action buttons
              if (!widget.showFull)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Market status indicator
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Markets Open',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      
                      // View full summary button
                      if (widget.onViewFullSummary != null)
                        TextButton.icon(
                          onPressed: widget.onViewFullSummary,
                          icon: const Icon(Icons.analytics, size: 16),
                          label: const Text('View Full Summary'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build the market list with trend visualization
  Widget _buildMarketList(ThemeData theme, List marketData) {
    return ListView.separated(
      itemCount: marketData.length,
      padding: EdgeInsets.zero,
      // Allow scrolling when in full view mode
      physics: widget.showFull ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(height: 1, indent: 8, endIndent: 8),
      itemBuilder: (context, index) {
        final item = marketData[index];
        final isPositive = item['isPositive'] as bool;
        final trendData = item['trend'] as List<double>;
        
        return InkWell(
          onTap: () => _showDetailedView(context, item),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Row(
              children: [
                // Index name and icon
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['name'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Trend visualization
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 24,
                    child: CustomPaint(
                      painter: TrendLinePainter(
                        points: trendData,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
                
                // Value and change
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['value'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['dayChange'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPositive
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['change'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isPositive ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Show detailed view of a specific market index
  void _showDetailedView(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final isPositive = item['isPositive'] as bool;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'] as String,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              // Current value and change
              Row(
                children: [
                  Text(
                    item['value'] as String,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isPositive ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['change'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Placeholder for detailed chart
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Detailed chart coming soon',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Market statistics
              Text(
                'Market Statistics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem(theme, 'Open', '${(double.parse(item['value'].toString().replaceAll(',', '')) - 100).toStringAsFixed(2)}'),
                  _buildStatItem(theme, 'High', '${(double.parse(item['value'].toString().replaceAll(',', '')) + 50).toStringAsFixed(2)}'),
                  _buildStatItem(theme, 'Low', '${(double.parse(item['value'].toString().replaceAll(',', '')) - 150).toStringAsFixed(2)}'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.history),
                    label: const Text('Historical Data'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.add_alert),
                    label: const Text('Set Alert'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a market statistic item
  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing trend lines
class TrendLinePainter extends CustomPainter {
  /// List of data points for the trend line
  final List<double> points;
  
  /// Color of the trend line
  final Color color;
  
  /// Constructor
  const TrendLinePainter({
    required this.points,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    
    // Find min and max values for scaling
    double minValue = points.reduce(math.min);
    double maxValue = points.reduce(math.max);
    double range = maxValue - minValue;
    
    // If all values are the same, create a flat line
    if (range == 0) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      final path = Path();
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
      
      canvas.drawPath(path, paint);
      return;
    }
    
    // Create path for the line
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    // Calculate step size for X-axis
    double stepX = size.width / (points.length - 1);
    
    // Start point
    double x = 0;
    double y = size.height - ((points[0] - minValue) / range * size.height);
    path.moveTo(x, y);
    
    // Draw line segments
    for (int i = 1; i < points.length; i++) {
      x = stepX * i;
      y = size.height - ((points[i] - minValue) / range * size.height);
      path.lineTo(x, y);
    }
    
    // Draw the path
    canvas.drawPath(path, paint);
    
    // Draw a small dot at the end point
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), 3, dotPaint);
  }
  
  @override
  bool shouldRepaint(TrendLinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

/// Show full market summary dialog
void showFullMarketSummary(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Market Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 450, maxWidth: 800),
              child: const MarketSummary(showFull: true),
            ),
          ],
        ),
      ),
    ),
  );
}
