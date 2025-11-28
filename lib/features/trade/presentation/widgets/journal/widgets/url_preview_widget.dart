import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlPreviewWidget extends StatelessWidget {
  const UrlPreviewWidget({required this.url, required this.onClose, super.key});

  final String url;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildPreviewImage(theme), _buildUrlText(theme)],
        ),
      ),
    );
  }

  Widget _buildPreviewImage(ThemeData theme) => ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
    child: Container(
      height: 200,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://api.thumbnail.ws/api/${Uri.encodeComponent(url)}/viewport/1200x800',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(theme),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingIndicator(loadingProgress);
            },
          ),
          _buildOpenIndicator(),
        ],
      ),
    ),
  );

  Widget _buildErrorPlaceholder(ThemeData theme) => Container(
    color: theme.colorScheme.surfaceContainerHighest,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.web, size: 48, color: theme.colorScheme.primary.withOpacity(0.5)),
        const SizedBox(height: 8),
        Text(
          'Link Preview',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
      ],
    ),
  );

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) => Container(
    color: Colors.black12,
    child: Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null,
      ),
    ),
  );

  Widget _buildOpenIndicator() => Positioned(
    top: 8,
    right: 8,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.open_in_new, size: 20, color: Colors.white),
    ),
  );

  Widget _buildUrlText(ThemeData theme) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            url,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 16),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onClose,
        ),
      ],
    ),
  );

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
