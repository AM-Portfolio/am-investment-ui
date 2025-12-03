import '../enums/notebook_item_type.dart';

class NotebookItem {
  final String? id;
  final String userId;
  final NotebookItemType type;
  final String? parentId;
  final String title;
  final String? content;
  final List<String>? tagIds;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? goalDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotebookItem({
    this.id,
    required this.userId,
    required this.type,
    this.parentId,
    required this.title,
    this.content,
    this.tagIds,
    this.metadata,
    this.goalDetails,
    this.createdAt,
    this.updatedAt,
  });
}
