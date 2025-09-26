import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/data/api/models/api_document_upload.dart';
import '../../core/services/document_upload_service.dart';

/// Example widget demonstrating document upload functionality
class DocumentUploadDemo extends ConsumerStatefulWidget {
  const DocumentUploadDemo({super.key});

  @override
  ConsumerState<DocumentUploadDemo> createState() => _DocumentUploadDemoState();
}

class _DocumentUploadDemoState extends ConsumerState<DocumentUploadDemo> {
  DocumentType _selectedDocumentType = DocumentType.stockPortfolio;
  String _portfolioId = 'zerodha';
  String _userId = 'ssd2658-ss';
  String? _description;
  bool _isUploading = false;
  DocumentUploadResponse? _lastUploadResponse;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Upload Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Configuration',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    
                    // Document Type Dropdown
                    DropdownButtonFormField<DocumentType>(
                      value: _selectedDocumentType,
                      decoration: const InputDecoration(
                        labelText: 'Document Type',
                        border: OutlineInputBorder(),
                      ),
                      items: DocumentType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getDocumentTypeDisplayName(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedDocumentType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Portfolio ID
                    TextFormField(
                      initialValue: _portfolioId,
                      decoration: const InputDecoration(
                        labelText: 'Portfolio ID',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _portfolioId = value,
                    ),
                    const SizedBox(height: 16),
                    
                    // User ID
                    TextFormField(
                      initialValue: _userId,
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _userId = value,
                    ),
                    const SizedBox(height: 16),
                    
                    // Description (Optional)
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _description = value.isEmpty ? null : value,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Upload Button
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadFile,
              icon: _isUploading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(_isUploading ? 'Uploading...' : 'Pick and Upload File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Results
            if (_lastUploadResponse != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Successful!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Process ID: ${_lastUploadResponse!.processId}'),
                      Text('File Name: ${_lastUploadResponse!.fileName}'),
                      Text('Status: ${_lastUploadResponse!.status.name.toUpperCase()}'),
                      Text('Document Type: ${_lastUploadResponse!.documentType.name}'),
                      if (_lastUploadResponse!.message != null)
                        Text('Message: ${_lastUploadResponse!.message}'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _checkProcessingStatus(_lastUploadResponse!.processId),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Check Status'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            if (_errorMessage != null) ...[
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Failed',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() {
        _isUploading = true;
        _errorMessage = null;
        _lastUploadResponse = null;
      });

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv', 'pdf', 'txt'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final file = result.files.first;
      final documentUploadService = ref.read(documentUploadServiceProvider);

      DocumentUploadResponse response;

      if (kIsWeb) {
        // Web platform - use bytes
        if (file.bytes == null) {
          throw Exception('File bytes not available on web');
        }
        response = await documentUploadService.uploadDocument(
          file: file.bytes!,
          fileName: file.name,
          documentType: _selectedDocumentType,
          portfolioId: _portfolioId,
          userId: _userId,
          description: _description,
        );
      } else {
        // Mobile/Desktop platform - use file path
        final filePath = file.path;
        if (filePath == null) {
          throw Exception('File path not available');
        }
        response = await documentUploadService.uploadDocument(
          file: File(filePath),
          fileName: file.name,
          documentType: _selectedDocumentType,
          portfolioId: _portfolioId,
          userId: _userId,
          description: _description,
        );
      }

      setState(() {
        _lastUploadResponse = response;
        _isUploading = false;
      });

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File uploaded successfully! Process ID: ${response.processId}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isUploading = false;
      });

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkProcessingStatus(String processId) async {
    try {
      final documentUploadService = ref.read(documentUploadServiceProvider);
      final status = await documentUploadService.getProcessingStatus(processId);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Processing Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Process ID: ${status.processId}'),
                Text('Status: ${status.status.name.toUpperCase()}'),
                Text('File Name: ${status.fileName}'),
                Text('Document Type: ${status.documentType.name}'),
                if (status.message != null) Text('Message: ${status.message}'),
                if (status.createdAt != null) Text('Created: ${status.createdAt}'),
                if (status.completedAt != null) Text('Completed: ${status.completedAt}'),
                if (status.errorCode != null) Text('Error Code: ${status.errorCode}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDocumentTypeDisplayName(DocumentType type) {
    switch (type) {
      case DocumentType.brokerPortfolio:
        return 'Broker Portfolio';
      case DocumentType.mutualFund:
        return 'Mutual Fund';
      case DocumentType.npsStatement:
        return 'NPS Statement';
      case DocumentType.companyFinancialReport:
        return 'Company Financial Report';
      case DocumentType.stockPortfolio:
        return 'Stock Portfolio';
      case DocumentType.nseIndices:
        return 'NSE Indices';
      case DocumentType.tradeFno:
        return 'Trade F&O';
      case DocumentType.tradeEq:
        return 'Trade Equity';
    }
  }
}