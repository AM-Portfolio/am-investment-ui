import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'file_upload_models.dart';

/// Widget to display selected files
class FileList extends StatelessWidget {
  final List<PlatformFile> files;
  final Function(PlatformFile)? onRemoveFile;

  const FileList({
    super.key,
    required this.files,
    this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
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
              '${files.length} file(s) selected',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...files.map((file) => _buildFileItem(file)),
      ],
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    final sizeInKB = (file.size / 1024).round();
    final extension = file.extension?.toUpperCase() ?? '';
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final iconSize = (screenWidth * 0.06).clamp(28.0, 40.0);
        final fontSize = (screenWidth * 0.025).clamp(12.0, 16.0);
        final smallFontSize = (screenWidth * 0.02).clamp(10.0, 14.0);
        final padding = (screenWidth * 0.02).clamp(8.0, 16.0);
        
        return Container(
          margin: EdgeInsets.only(bottom: screenWidth * 0.015),
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
              SizedBox(width: screenWidth * 0.025),
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
              if (onRemoveFile != null)
                IconButton(
                  onPressed: () => onRemoveFile!(file),
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
}