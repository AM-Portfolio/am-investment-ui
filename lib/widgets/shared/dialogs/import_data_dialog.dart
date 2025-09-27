import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// Import data options
enum ImportDataOption {
  excel('Upload Excel/CSV file', Icons.file_upload),
  broker('Connect broker account', Icons.link),
  manual('Manual entry', Icons.edit);

  const ImportDataOption(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Document types for import
enum DocumentType {
  brokerPortfolio('Broker Portfolio', Icons.account_balance, 'Import your complete portfolio from broker statements'),
  mutualFund('Mutual Fund', Icons.trending_up, 'Import mutual fund holdings and transactions'),
  npsStatement('NPS Statement', Icons.savings, 'Import National Pension System statements'),
  companyFinancialReport('Company Financial Report', Icons.business, 'Import company financial reports and analysis'),
  stockPortfolio('Stock Portfolio', Icons.show_chart, 'Import individual stock holdings and transactions'),
  nseIndices('NSE Indices', Icons.bar_chart, 'Import NSE index data and performance'),
  tradeFno('F&O Trades', Icons.swap_horiz, 'Import Futures & Options trading data'),
  tradeEq('Equity Trades', Icons.monetization_on, 'Import equity trading transactions');

  const DocumentType(this.label, this.icon, this.description);
  final String label;
  final IconData icon;
  final String description;
}

/// Broker options
enum BrokerType {
  zerodha('Zerodha', 'images/brokers/zerodha.svg', const Color(0xFF387ADF)),
  angelBroking('Angel Broking', 'images/brokers/angel.svg', const Color(0xFFE31E24)),
  upstox('Upstox', 'images/brokers/upstox.svg', const Color(0xFF6C63FF)),
  iciciDirect('ICICI Direct', 'images/brokers/icici.svg', const Color(0xFFFF6900)),
  hdfcSecurities('HDFC Securities', 'images/brokers/hdfc.svg', const Color(0xFF004C8F)),
  kotakSecurities('Kotak Securities', 'images/brokers/kotak.svg', const Color(0xFFED1C24)),
  sbicap('SBI Cap Securities', 'images/brokers/sbi.svg', const Color(0xFF1C4B9C)),
  sharekhan('Sharekhan', 'images/brokers/sharekhan.svg', const Color(0xFF0066CC)),
  motilalOswal('Motilal Oswal', 'images/brokers/motilal.svg', const Color(0xFFE31E24)),
  edelweiss('Edelweiss', 'images/brokers/edelweiss.svg', const Color(0xFF1B5E20)),
  fyers('Fyers', 'images/brokers/fyers.svg', const Color(0xFF2196F3)),
  aliceBlue('Alice Blue', 'images/brokers/alice.svg', const Color(0xFF4CAF50)),
  other('Other', null, const Color(0xFF9E9E9E));

  const BrokerType(this.label, this.logoPath, this.color);
  final String label;
  final String? logoPath;
  final Color color;
}

/// Import data result
class ImportDataResult {
  final ImportDataOption option;
  final DocumentType? documentType;
  final BrokerType? brokerType;

  const ImportDataResult({
    required this.option,
    this.documentType,
    this.brokerType,
  });
}

/// Dialog for importing data into portfolio
class ImportDataDialog extends StatefulWidget {
  const ImportDataDialog({super.key});

  @override
  State<ImportDataDialog> createState() => _ImportDataDialogState();

  /// Show the import data dialog
  static Future<ImportDataResult?> show(BuildContext context) {
    return showDialog<ImportDataResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ImportDataDialog(),
    );
  }
}

class _ImportDataDialogState extends State<ImportDataDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  ImportDataOption? _selectedOption;
  DocumentType? _selectedDocumentType;
  BrokerType? _selectedBroker;
  int _currentStep = 0;
  
  // File upload states
  List<PlatformFile>? _selectedFiles;
  bool _isDragOver = false;
  bool _isUploading = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildBrokerFallbackIcon(BrokerType broker) {
    // Map broker types to appropriate icons
    IconData getIconForBroker(BrokerType broker) {
      switch (broker.label.toLowerCase()) {
        case 'zerodha':
          return Icons.trending_up;
        case 'angel one':
        case 'angel':
          return Icons.star;
        case 'upstox':
          return Icons.show_chart;
        case 'icici direct':
        case 'icici':
          return Icons.account_balance;
        case 'hdfc securities':
        case 'hdfc':
          return Icons.business;
        case 'kotak securities':
        case 'kotak':
          return Icons.monetization_on;
        case 'sbi securities':
        case 'sbi':
          return Icons.corporate_fare;
        case 'sharekhan':
          return Icons.pie_chart;
        case 'motilal oswal':
        case 'motilal':
          return Icons.analytics;
        case 'edelweiss':
          return Icons.diamond;
        case 'fyers':
          return Icons.rocket_launch;
        case 'alice blue':
        case 'alice':
          return Icons.insights;
        default:
          return Icons.business;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: broker.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        getIconForBroker(broker),
        size: 18,
        color: broker.color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final screenWidth = MediaQuery.of(context).size.width;
                  
                  return Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.9, // 90% of screen width
                      minWidth: 300,
                      maxHeight: screenHeight * 0.85, // 85% of screen height
                      minHeight: 400,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Fixed header section
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          child: Column(
                            children: [
                              _buildHeader(),
                              SizedBox(height: screenHeight * 0.02),
                              _buildStepIndicator(),
                            ],
                          ),
                        ),
                        
                        // Scrollable content section
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: screenHeight * 0.01),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: screenHeight * 0.3, // Minimum content height
                                  ),
                                  child: _buildStepContent(),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                              ],
                            ),
                          ),
                        ),
                        
                        // Fixed actions section
                        Padding(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          child: _buildActions(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final iconSize = screenWidth * 0.08; // 8% of screen width, min 40, max 60
        final titleFontSize = screenWidth * 0.04; // 4% of screen width, min 18, max 28
        final subtitleFontSize = screenWidth * 0.025; // 2.5% of screen width, min 12, max 16
        
        return Row(
          children: [
            Container(
              width: iconSize.clamp(40.0, 60.0),
              height: iconSize.clamp(40.0, 60.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF9800),
                    const Color(0xFFFF9800).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(iconSize.clamp(40.0, 60.0) * 0.33),
              ),
              child: Icon(
                Icons.upload_file,
                color: Colors.white,
                size: (iconSize * 0.5).clamp(20.0, 30.0),
              ),
            ),
            SizedBox(width: screenWidth * 0.03), // 3% of screen width
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import Data',
                    style: TextStyle(
                      fontSize: titleFontSize.clamp(18.0, 28.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getStepTitle(),
                    style: TextStyle(
                      fontSize: subtitleFontSize.clamp(12.0, 16.0),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context, null),
              icon: const Icon(Icons.close),
              iconSize: (iconSize * 0.5).clamp(20.0, 28.0),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(0, 'Method'),
        _buildStepLine(0),
        _buildStepDot(1, 'Document'),
        _buildStepLine(1),
        _buildStepDot(2, 'Broker'),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = step <= _currentStep;
    final isCurrent = step == _currentStep;
    
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final dotSize = (screenWidth * 0.06).clamp(28.0, 40.0); // 6% of screen width
          final fontSize = (screenWidth * 0.022).clamp(10.0, 14.0); // 2.2% of screen width
          final iconSize = (dotSize * 0.5).clamp(14.0, 20.0);
          
          return Column(
            children: [
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: isActive 
                      ? const Color(0xFFFF9800) 
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(dotSize / 2),
                  border: isCurrent 
                      ? Border.all(color: const Color(0xFFFF9800), width: 2)
                      : null,
                ),
                child: Center(
                  child: isActive && step < _currentStep
                      ? Icon(Icons.check, color: Colors.white, size: iconSize)
                      : Text(
                          '${step + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: (fontSize * 0.9).clamp(8.0, 12.0),
                          ),
                        ),
                ),
              ),
              SizedBox(height: screenWidth * 0.015), // 1.5% of screen width
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: isActive ? const Color(0xFFFF9800) : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = step < _currentStep;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final lineWidth = (screenWidth * 0.04).clamp(16.0, 32.0); // 4% of screen width
        final bottomMargin = (screenWidth * 0.035).clamp(15.0, 25.0); // 3.5% of screen width
        
        return Container(
          height: 2,
          width: lineWidth,
          color: isActive ? const Color(0xFFFF9800) : Colors.grey.withOpacity(0.3),
          margin: EdgeInsets.only(bottom: bottomMargin),
        );
      },
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildMethodSelection();
      case 1:
        return _buildDocumentTypeSelection();
      case 2:
        return _buildBrokerSelection();
      default:
        return _buildMethodSelection();
    }
  }

  Widget _buildMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your import method:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Column(
            children: [
              // Import options
              ...ImportDataOption.values
                  .map((option) => _buildImportOption(option))
                  .toList(),
              
              // Show file upload area if Excel/CSV is selected
              if (_selectedOption == ImportDataOption.excel) ...[
                const SizedBox(height: 20),
                _buildFileUploadArea(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select document type:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: DocumentType.values
                .map((docType) => _buildDocumentTypeOption(docType))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBrokerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your broker:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              
              // Determine cross axis count based on screen width
              int crossAxisCount = 2;
              if (screenWidth > 600) {
                crossAxisCount = 3;
              } else if (screenWidth < 400) {
                crossAxisCount = 1;
              }
              
              // Calculate responsive spacing
              final spacing = (screenWidth * 0.02).clamp(8.0, 16.0);
              
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: screenWidth > 400 ? 2.2 : 3.0,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: BrokerType.values.length,
                itemBuilder: (context, index) {
                  final broker = BrokerType.values[index];
                  return _buildBrokerOption(broker);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImportOption(ImportDataOption option) {
    final isSelected = _selectedOption == option;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? const Color(0xFFFF9800) 
              : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected 
            ? const Color(0xFFFF9800).withOpacity(0.05)
            : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedOption = option;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option.icon,
                    size: 24,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? const Color(0xFFFF9800)
                          : Colors.grey[800],
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTypeOption(DocumentType docType) {
    final isSelected = _selectedDocumentType == docType;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? const Color(0xFFFF9800) 
              : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected 
            ? const Color(0xFFFF9800).withOpacity(0.05)
            : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDocumentType = docType;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    docType.icon,
                    size: 24,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docType.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected 
                              ? const Color(0xFFFF9800)
                              : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        docType.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrokerOption(BrokerType broker) {
    final isSelected = _selectedBroker == broker;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? broker.color 
              : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected 
            ? broker.color.withOpacity(0.05)
            : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedBroker = broker;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: broker.logoPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            broker.logoPath!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildBrokerFallbackIcon(broker);
                            },
                          ),
                        )
                      : _buildBrokerFallbackIcon(broker),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    broker.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? broker.color
                          : Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: broker.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _currentStep--;
              });
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          )
        else
          const SizedBox.shrink(),
        
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _canProceed() ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                _currentStep == 2 && _selectedBroker != null ? 'Import' : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Select import method';
      case 1:
        return 'Choose document type';
      case 2:
        return 'Select your broker';
      default:
        return 'Import your data';
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        if (_selectedOption == ImportDataOption.excel) {
          // For Excel/CSV option, files must be selected and uploaded
          return _selectedOption != null && 
                 _selectedFiles != null && 
                 _selectedFiles!.isNotEmpty;
        }
        return _selectedOption != null;
      case 1:
        return _selectedDocumentType != null;
      case 2:
        return _selectedBroker != null;
      default:
        return false;
    }
  }

  Widget _buildFileUploadArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: _isDragOver 
              ? const Color(0xFFFF9800) 
              : Colors.grey.withOpacity(0.3),
          width: _isDragOver ? 2 : 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
        color: _isDragOver 
            ? const Color(0xFFFF9800).withOpacity(0.05)
            : Colors.grey.withOpacity(0.02),
      ),
      child: Column(
        children: [
          if (_selectedFiles == null || _selectedFiles!.isEmpty) ...[
            // Drag and drop area
            _buildDragDropArea(),
          ] else ...[
            // Selected files display
            _buildSelectedFiles(),
            const SizedBox(height: 16),
            _buildUploadActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildDragDropArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        final iconSize = (screenWidth * 0.1).clamp(48.0, 80.0); // 10% of screen width
        final titleFontSize = (screenWidth * 0.032).clamp(16.0, 22.0); // 3.2% of screen width
        final subtitleFontSize = (screenWidth * 0.025).clamp(12.0, 16.0); // 2.5% of screen width
        final verticalPadding = (screenHeight * 0.05).clamp(20.0, 50.0); // 5% of screen height
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(iconSize / 2),
                ),
                child: Icon(
                  Icons.cloud_upload,
                  size: iconSize * 0.5,
                  color: const Color(0xFFFF9800),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // 2% of screen height
              Text(
                'Click to select your files',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01), // 1% of screen height
              Text(
                'Support for Excel (.xlsx, .xls) and CSV files',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
              ElevatedButton.icon(
                onPressed: _pickFiles,
                icon: Icon(Icons.folder_open, size: titleFontSize * 0.8),
                label: Text(
                  'Choose Files',
                  style: TextStyle(fontSize: titleFontSize * 0.8),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05, // 5% of screen width
                    vertical: screenHeight * 0.015, // 1.5% of screen height
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${_selectedFiles!.length} file(s) selected',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._selectedFiles!.map((file) => _buildFileItem(file)).toList(),
      ],
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    final sizeInKB = (file.size / 1024).round();
    final extension = file.extension?.toUpperCase() ?? '';
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final iconSize = (screenWidth * 0.06).clamp(28.0, 40.0); // 6% of screen width
        final fontSize = (screenWidth * 0.025).clamp(12.0, 16.0); // 2.5% of screen width
        final smallFontSize = (screenWidth * 0.02).clamp(10.0, 14.0); // 2% of screen width
        final padding = (screenWidth * 0.02).clamp(8.0, 16.0); // 2% of screen width
        
        return Container(
          margin: EdgeInsets.only(bottom: screenWidth * 0.015), // 1.5% of screen width
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: _getFileTypeColor(extension),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    extension,
                    style: TextStyle(
                      fontSize: (iconSize * 0.25).clamp(8.0, 12.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.025), // 2.5% of screen width
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${sizeInKB} KB',
                      style: TextStyle(
                        fontSize: smallFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeFile(file),
                icon: const Icon(Icons.close),
                iconSize: (iconSize * 0.6).clamp(16.0, 22.0),
                color: Colors.grey[600],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadActions() {
    return Row(
      children: [
        TextButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.add),
          label: const Text('Add More Files'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFF9800),
          ),
        ),
        const Spacer(),
        if (_isUploading)
          const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                ),
              ),
              SizedBox(width: 8),
              Text('Uploading...'),
            ],
          )
        else
          ElevatedButton.icon(
            onPressed: _uploadFiles,
            icon: const Icon(Icons.upload),
            label: const Text('Upload Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  Color _getFileTypeColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'xlsx':
      case 'xls':
        return Colors.green;
      case 'csv':
        return Colors.blue;
      case 'pdf':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.files;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking files: ${e.toString()}');
    }
  }



  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles?.removeWhere((f) => f.name == file.name);
      if (_selectedFiles?.isEmpty == true) {
        _selectedFiles = null;
      }
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles == null || _selectedFiles!.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Call document service to upload files
      await _uploadToDocumentService(_selectedFiles!);
      
      // Show success message
      _showSuccessSnackBar('Files uploaded successfully!');
      
      // Move to next step or close dialog
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
      } else {
        final result = ImportDataResult(
          option: _selectedOption!,
          documentType: _selectedDocumentType,
          brokerType: _selectedBroker,
        );
        Navigator.pop(context, result);
      }
    } catch (e) {
      _showErrorSnackBar('Upload failed: ${e.toString()}');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadToDocumentService(List<PlatformFile> files) async {
    try {
      // For now, we'll just simulate the upload process
      // In a real app, you would use proper dependency injection
      // and call the actual document upload service
      
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate file processing
      for (final file in files) {
        print('Processing file: ${file.name}, Size: ${file.size} bytes');
        
        // Simulate processing time
        await Future.delayed(const Duration(milliseconds: 500));
        
        print('Successfully processed: ${file.name}');
      }
      
      print('All files processed successfully. Total: ${files.length} files');
      
    } catch (e) {
      print('Error uploading files: $e');
      rethrow; // Re-throw to let the caller handle the error
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Final step - return result
      final result = ImportDataResult(
        option: _selectedOption!,
        documentType: _selectedDocumentType,
        brokerType: _selectedBroker,
      );
      Navigator.pop(context, result);
    }
  }
}