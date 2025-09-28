import 'package:flutter/material.dart';

/// Simple portfolio sidebar widget
class PortfolioSidebar extends StatelessWidget {
  const PortfolioSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Portfolio Navigation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Overview'),
          onTap: () {
            // TODO: Implement navigation when cubit is working
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: const Text('Holdings'),
          onTap: () {
            // TODO: Implement navigation when cubit is working
          },
        ),
        ListTile(
          leading: const Icon(Icons.analytics),
          title: const Text('Analysis'),
          onTap: () {
            // TODO: Implement navigation when cubit is working
          },
        ),
      ],
    );
  }
}