import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/document_upload_service.dart';
import '../../../core/domain/entities/document/document_upload.dart';

/// Example of how to use the refactored document upload service
/// This demonstrates the proper usage of the repository pattern and providers
class DocumentUploadExample extends ConsumerWidget {
  const DocumentUploadExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Upload Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Document Upload Service Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Upload Document Example
            ElevatedButton(
              onPressed: () => _uploadDocument(ref),
              child: const Text('Upload Document'),
            ),
            const SizedBox(height: 10),
            
            // Get Document History Example
            ElevatedButton(
              onPressed: () => _getDocumentHistory(ref, 'user123'),
              child: const Text('Get Document History'),
            ),
            const SizedBox(height: 10),
            
            // Get Document Status Example
            ElevatedButton(
              onPressed: () => _getDocumentStatus(ref, 'process123'),
              child: const Text('Get Document Status'),
            ),
            const SizedBox(height: 20),
            
            // Document History Widget
            Expanded(
              child: _buildDocumentHistoryWidget(ref, 'user123'),
            ),
          ],
        ),
      ),
    );
  }

  /// Example: Upload a document
  Future<void> _uploadDocument(WidgetRef ref) async {
    try {
      final documentService = ref.read(documentUploadServiceProvider);
      
      // For this example, we'll create a mock file
      // In real usage, you'd get this from file picker
      final mockFile = Uint8List.fromList([1, 2, 3, 4, 5]); // Mock file data
      
      final result = await documentService.uploadDocument(
        file: mockFile,
        fileName: 'portfolio_statement.pdf',
        category: DocumentCategory.stockPortfolio,
        portfolioId: 'portfolio_123',
        userId: 'user_123',
        description: 'Monthly portfolio statement',
      );
      
      debugPrint('Document uploaded successfully: ${result.identity.processId}');
    } catch (e) {
      debugPrint('Error uploading document: $e');
    }
  }

  /// Example: Get document history
  Future<void> _getDocumentHistory(WidgetRef ref, String userId) async {
    try {
      final documentService = ref.read(documentUploadServiceProvider);
      
      final history = await documentService.getDocumentHistory(
        userId: userId,
        category: DocumentCategory.stockPortfolio, // Optional filter
        limit: 10,
      );
      
      debugPrint('Found ${history.totalUploads} documents');
      for (final doc in history.uploads) {
        debugPrint('Document: ${doc.identity.fileName} - Status: ${doc.status.current}');
      }
    } catch (e) {
      debugPrint('Error getting document history: $e');
    }
  }

  /// Example: Get document status
  Future<void> _getDocumentStatus(WidgetRef ref, String processId) async {
    try {
      final documentService = ref.read(documentUploadServiceProvider);
      
      final document = await documentService.getDocumentStatus(processId);
      
      debugPrint('Document status: ${document.status.current}');
      if (document.isCompleted && document.result != null) {
        debugPrint('Processing result: ${document.result!.extractedData}');
      }
    } catch (e) {
      debugPrint('Error getting document status: $e');
    }
  }

  /// Example: Build a widget that shows document history using providers
  Widget _buildDocumentHistoryWidget(WidgetRef ref, String userId) {
    // Watch the document history provider
    final documentHistoryAsync = ref.watch(documentHistoryProvider(userId));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: documentHistoryAsync.when(
                data: (history) => _buildHistoryList(history),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the history list widget
  Widget _buildHistoryList(DocumentUploadCollection history) {
    if (history.isEmpty) {
      return const Center(child: Text('No documents found'));
    }

    return ListView.builder(
      itemCount: history.uploads.length,
      itemBuilder: (context, index) {
        final document = history.uploads[index];
        return _buildDocumentTile(document);
      },
    );
  }

  /// Build individual document tile
  Widget _buildDocumentTile(DocumentUpload document) {
    return ListTile(
      leading: _getStatusIcon(document.status.current),
      title: Text(document.identity.fileName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category: ${document.identity.category.name}'),
          Text('Status: ${document.status.current.name}'),
          if (document.status.message != null)
            Text(document.status.message!, style: const TextStyle(fontSize: 12)),
        ],
      ),
      trailing: Text(
        _formatDate(document.metadata.uploadedAt),
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  /// Get status icon based on processing status
  Widget _getStatusIcon(DocumentProcessingStatus status) {
    switch (status) {
      case DocumentProcessingStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case DocumentProcessingStatus.processing:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case DocumentProcessingStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case DocumentProcessingStatus.queued:
        return const Icon(Icons.queue, color: Colors.blue);
      case DocumentProcessingStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.grey);
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Example: Using streams for real-time updates
class DocumentStatusStreamExample extends ConsumerWidget {
  final String processId;
  
  const DocumentStatusStreamExample({
    required this.processId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the document status stream
    final statusStream = ref.watch(documentStatusStreamProvider(processId));
    
    return StreamBuilder<DocumentUpload>(
      stream: statusStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        
        final document = snapshot.data!;
        return Card(
          child: ListTile(
            title: Text(document.identity.fileName),
            subtitle: Text('Status: ${document.status.current.name}'),
            trailing: _getStatusIcon(document.status.current),
          ),
        );
      },
    );
  }

  Widget _getStatusIcon(DocumentProcessingStatus status) {
    switch (status) {
      case DocumentProcessingStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case DocumentProcessingStatus.processing:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case DocumentProcessingStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case DocumentProcessingStatus.queued:
        return const Icon(Icons.queue, color: Colors.blue);
      case DocumentProcessingStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.grey);
    }
  }
}

/// Example: Cache management
class DocumentCacheManagementExample extends ConsumerWidget {
  const DocumentCacheManagementExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _clearUserCache(ref, 'user123'),
          child: const Text('Clear User Cache'),
        ),
        ElevatedButton(
          onPressed: () => _refreshUserData(ref, 'user123'),
          child: const Text('Refresh User Data'),
        ),
        ElevatedButton(
          onPressed: () => _checkCacheStatus(ref, 'user123'),
          child: const Text('Check Cache Status'),
        ),
      ],
    );
  }

  Future<void> _clearUserCache(WidgetRef ref, String userId) async {
    final cacheManager = await ref.read(cacheManagerProvider.future);
    await cacheManager.clearUserCache(userId);
    debugPrint('User cache cleared for: $userId');
  }

  Future<void> _refreshUserData(WidgetRef ref, String userId) async {
    final cacheManager = await ref.read(cacheManagerProvider.future);
    await cacheManager.refreshUserData(userId);
    debugPrint('User data refreshed for: $userId');
  }

  Future<void> _checkCacheStatus(WidgetRef ref, String userId) async {
    final cacheManager = await ref.read(cacheManagerProvider.future);
    
    final isDocumentHistoryFresh = cacheManager.isDocumentHistoryDataFresh(userId);
    final isPortfolioFresh = cacheManager.isPortfolioHoldingsDataFresh(userId);
    
    debugPrint('Document history cache fresh: $isDocumentHistoryFresh');
    debugPrint('Portfolio holdings cache fresh: $isPortfolioFresh');
  }
}