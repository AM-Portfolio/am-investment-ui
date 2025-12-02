import 'package:flutter/material.dart';

import '../../../../../../attachment/presentation/widgets/attachment_picker.dart';

class JournalAttachmentSection extends StatelessWidget {
  const JournalAttachmentSection({
    required this.imageUrls,
    required this.onAttachmentsChanged,
    required this.featureName,
    required this.userId,
    required this.isEditMode,
    super.key,
  });

  final List<String> imageUrls;
  final ValueChanged<List<String>> onAttachmentsChanged;
  final String featureName;
  final String userId;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) => AttachmentPicker(
    initialUrls: imageUrls,
    onAttachmentsChanged: onAttachmentsChanged,
    featureName: featureName,
    userId: userId,
    readOnly: !isEditMode,
  );
}
