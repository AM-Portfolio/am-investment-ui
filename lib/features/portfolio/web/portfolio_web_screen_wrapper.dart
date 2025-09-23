import 'package:flutter/material.dart';
import '../../../core/config/config_service.dart';
import 'portfolio_web_screen.dart';

/// Wrapper widget that ensures configuration is loaded before showing portfolio screen
class PortfolioWebScreenWrapper extends StatefulWidget {
  final String userId;
  final Future<void> Function() refreshPortfolio;

  const PortfolioWebScreenWrapper({
    super.key,
    required this.userId,
    required this.refreshPortfolio,
  });

  @override
  State<PortfolioWebScreenWrapper> createState() => _PortfolioWebScreenWrapperState();
}

class _PortfolioWebScreenWrapperState extends State<PortfolioWebScreenWrapper> {
  bool _configLoaded = false;
  bool _configError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeConfig();
  }

  Future<void> _initializeConfig() async {
    try {
      // Check if config is already loaded
      try {
        ConfigService.config; // This will throw if not loaded
        setState(() {
          _configLoaded = true;
        });
        return;
      } catch (e) {
        // Config not loaded, initialize it
      }

      await ConfigService.initialize(environment: 'development');
      setState(() {
        _configLoaded = true;
      });
    } catch (e) {
      setState(() {
        _configError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_configError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configuration Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load application configuration'),
              const SizedBox(height: 8),
              Text(_errorMessage ?? 'Unknown error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _configError = false;
                    _configLoaded = false;
                  });
                  _initializeConfig();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_configLoaded) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading configuration...'),
            ],
          ),
        ),
      );
    }

    return PortfolioWebScreen(
      userId: widget.userId,
      refreshPortfolio: widget.refreshPortfolio,
    );
  }
}