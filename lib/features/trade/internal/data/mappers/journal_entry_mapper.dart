import '../../domain/entities/journal_entry.dart';
import '../dtos/journal_entry_dto.dart';

/// Mapper for journal entry between DTO and domain entity
class JournalEntryMapper {
  /// Convert JournalAttachmentDto to JournalAttachment domain entity
  static JournalAttachment fromAttachmentDto(JournalAttachmentDto dto) => JournalAttachment(
    fileName: dto.fileName,
    fileUrl: dto.fileUrl,
    fileType: dto.fileType,
    uploadedAt: dto.uploadedAt != null ? DateTime.tryParse(dto.uploadedAt!) : null,
    description: dto.description,
  );

  /// Convert JournalAttachment entity to JournalAttachmentDto
  static JournalAttachmentDto toAttachmentDto(JournalAttachment attachment) => JournalAttachmentDto(
    fileName: attachment.fileName,
    fileUrl: attachment.fileUrl,
    fileType: attachment.fileType,
    uploadedAt: attachment.uploadedAt?.toIso8601String(),
    description: attachment.description,
  );

  /// Convert TradeJournalEntryResponseDto to JournalEntry domain entity
  static JournalEntry fromResponseDto(TradeJournalEntryResponseDto dto) => JournalEntry(
    id: dto.id,
    userId: dto.userId,
    tradeId: dto.tradeId,
    title: dto.title,
    content: dto.content,
    mood: dto.mood,
    marketSentiment: dto.marketSentiment,
    tags: dto.tags ?? [],
    customFields: dto.customFields ?? {},
    entryDate: DateTime.parse(dto.entryDate),
    imageUrls: dto.imageUrls ?? [],
    attachments: dto.attachments?.map(fromAttachmentDto).toList() ?? [],
    relatedTradeIds: dto.relatedTradeIds ?? [],
    createdAt: DateTime.parse(dto.createdAt),
    updatedAt: DateTime.parse(dto.updatedAt),
  );

  /// Convert JournalEntry entity to TradeJournalEntryRequestDto
  static TradeJournalEntryRequestDto toRequestDto(JournalEntry entry) => TradeJournalEntryRequestDto(
    userId: entry.userId,
    title: entry.title,
    content: entry.content,
    entryDate: entry.entryDate.toIso8601String(),
    tradeId: entry.tradeId,
    mood: entry.mood,
    marketSentiment: entry.marketSentiment,
    tags: entry.tags,
    customFields: entry.customFields,
    imageUrls: entry.imageUrls,
    attachments: entry.attachments.map(toAttachmentDto).toList(),
    relatedTradeIds: entry.relatedTradeIds,
  );
}
