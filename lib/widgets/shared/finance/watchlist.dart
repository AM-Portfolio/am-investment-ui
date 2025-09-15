import 'package:flutter/material.dart';

/// A widget that displays watchlist information
class Watchlist extends StatelessWidget {
  /// Constructor
  const Watchlist({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy watchlist data
    final watchlist = [
      {
        'symbol': 'RELIANCE',
        'price': '₹2,890.45',
        'change': '+1.8%',
        'isPositive': true,
      },
      {
        'symbol': 'TATASTEEL',
        'price': '₹145.75',
        'change': '-0.5%',
        'isPositive': false,
      },
      {
        'symbol': 'ICICIBANK',
        'price': '₹978.30',
        'change': '+0.7%',
        'isPositive': true,
      },
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (final item in watchlist)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['symbol'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          item['price'] as String,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (item['isPositive'] as bool)
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['change'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: (item['isPositive'] as bool)
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showFullWatchlist(context),
                child: const Text('View All Stocks'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show full watchlist dialog
  static void showFullWatchlist(BuildContext context) {
    final theme = Theme.of(context);

    // Extended watchlist data for full view
    final extendedWatchlist = [
      {
        'symbol': 'RELIANCE',
        'price': '₹2,890.45',
        'change': '+1.8%',
        'isPositive': true,
      },
      {
        'symbol': 'TATASTEEL',
        'price': '₹145.75',
        'change': '-0.5%',
        'isPositive': false,
      },
      {
        'symbol': 'ICICIBANK',
        'price': '₹978.30',
        'change': '+0.7%',
        'isPositive': true,
      },
      {
        'symbol': 'HDFCBANK',
        'price': '₹1,675.20',
        'change': '+0.3%',
        'isPositive': true,
      },
      {
        'symbol': 'INFY',
        'price': '₹1,850.60',
        'change': '+2.1%',
        'isPositive': true,
      },
      {
        'symbol': 'TCS',
        'price': '₹3,450.75',
        'change': '-0.2%',
        'isPositive': false,
      },
      {
        'symbol': 'WIPRO',
        'price': '₹425.30',
        'change': '+1.5%',
        'isPositive': true,
      },
      {
        'symbol': 'SBIN',
        'price': '₹567.80',
        'change': '+0.8%',
        'isPositive': true,
      },
      {
        'symbol': 'AXISBANK',
        'price': '₹890.45',
        'change': '-0.7%',
        'isPositive': false,
      },
      {
        'symbol': 'MARUTI',
        'price': '₹9,875.60',
        'change': '+1.2%',
        'isPositive': true,
      },
    ];

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
                    'Your Watchlist',
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
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Search box
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search stocks',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Column headers
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Symbol',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    'Price',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    'Change',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Watchlist items
                      for (final item in extendedWatchlist)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['symbol'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      item['price'] as String,
                                      style: theme.textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (item['isPositive'] as bool)
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['change'] as String,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  (item['isPositive'] as bool)
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add Stock feature coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Stock'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
