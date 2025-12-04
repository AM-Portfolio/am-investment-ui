import '../../../../../config/app_config.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/logger.dart';
import '../dtos/journal_entry_dto.dart';
import '../dtos/journal_template_dto.dart';

/// Abstract interface for journal template remote data source
abstract class JournalTemplateRemoteDataSource {
  Future<JournalTemplateResponseDto> createTemplate(JournalTemplateRequestDto request);
  
  Future<List<JournalTemplateResponseDto>> getTemplates({
    required String userId,
    String? category,
    String? search,
  });
  
  Future<JournalTemplateResponseDto> getTemplate(String templateId, String userId);
  
  Future<JournalTemplateResponseDto> updateTemplate(
    String templateId,
    JournalTemplateRequestDto request,
  );
  
  Future<void> deleteTemplate(String templateId, String userId);
  
  Future<List<JournalTemplateResponseDto>> getFavoriteTemplates(String userId);
  
  Future<List<JournalTemplateResponseDto>> getRecommendedTemplates(String userId);
  
  Future<List<JournalTemplateResponseDto>> getMyTemplates(String userId);
  
  Future<JournalTemplateResponseDto> toggleFavorite(String templateId, String userId);
  
  Future<TradeJournalEntryResponseDto> useTemplate(
    String templateId,
    UseTemplateRequestDto request,
  );
}

/// Implementation of journal template remote data source
class JournalTemplateRemoteDataSourceImpl implements JournalTemplateRemoteDataSource {
  JournalTemplateRemoteDataSourceImpl({
    required ApiClient apiClient,
    required AppConfig config,
  })  : _apiClient = apiClient,
        _config = config;

  final ApiClient _apiClient;
  final AppConfig _config;

  String get _baseUrl => '${_config.baseUrl}/api/v1/journal-templates';

  @override
  Future<JournalTemplateResponseDto> createTemplate(
    JournalTemplateRequestDto request,
  ) async {
    AppLogger.methodEntry(
      'createTemplate',
      tag: 'JournalTemplateRemoteDataSource',
      params: {'name': request.name},
    );

    try {
      final response = await _apiClient.post(
        _baseUrl,
        data: request.toJson(),
      );

      AppLogger.info(
        'Template created successfully',
        tag: 'JournalTemplateRemoteDataSource',
      );
      AppLogger.methodExit(
        'createTemplate',
        tag: 'JournalTemplateRemoteDataSource',
        result: 'success',
      );

      return JournalTemplateResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to create template',
        tag: 'JournalTemplateRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<List<JournalTemplateResponseDto>> getTemplates({
    required String userId,
    String? category,
    String? search,
  }) async {
    AppLogger.methodEntry(
      'getTemplates',
      tag: 'JournalTemplateRemoteDataSource',
      params: {'userId': userId, 'category': category, 'search': search},
    );

    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
        if (category != null) 'category': category,
        if (search != null) 'search': search,
      };

      final response = await _apiClient.get(
        _baseUrl,
        queryParameters: queryParams,
      );

      AppLogger.info(
        'Templates fetched successfully',
        tag: 'JournalTemplateRemoteDataSource',
      );
      AppLogger.methodExit(
        'getTemplates',
        tag: 'JournalTemplateRemoteDataSource',
        result: 'success',
      );

      final list = response.data as List<dynamic>;
      return list
          .map((item) => JournalTemplateResponseDto.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      AppLogger.error(
        'Failed to fetch templates',
        tag: 'JournalTemplateRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<JournalTemplateResponseDto> getTemplate(
    String templateId,
    String userId,
  ) async {
    AppLogger.methodEntry(
      'getTemplate',
      tag: 'JournalTemplateRemoteDataSource',
      params: {'templateId': templateId},
    );

    try {
      final response = await _apiClient.get(
        '$_baseUrl/$templateId',
        queryParameters: {'userId': userId},
      );

      AppLogger.info(
        'Template fetched successfully',
        tag: 'JournalTemplateRemoteDataSource',
      );
      AppLogger.methodExit(
        'getTemplate',
        tag: 'JournalTemplateRemoteDataSource',
        result: 'success',
      );

      return JournalTemplateResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to fetch template',
        tag: 'JournalTemplateRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<JournalTemplateResponseDto> updateTemplate(
    String templateId,
    JournalTemplateRequestDto request,
  ) async {
    AppLogger.methodEntry(
      'updateTemplate',
      tag: 'JournalTemplateRemoteDataSource',
      params: {'templateId': templateId},
    );

    try {
      final response = await _apiClient.put(
        '$_baseUrl/$templateId',
        data: request.toJson(),
      );

      AppLogger.info(
        'Template updated successfully',
        tag: 'JournalTemplateRemoteDataSource',
      );
      AppLogger.methodExit(
        'updateTemplate',
        tag: 'JournalTemplateRemoteDataSource',
        result: 'success',
      );

      return JournalTemplateResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to update template',
        tag: 'JournalTemplateRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteTemplate(String templateId, String userId) async {
    AppLogger.methodEntry(
      'deleteTemplate',
      tag: 'JournalTemplateRemoteDataSource',
      params: {'templateId': templateId},
    );

    try {
      await _apiClient.delete(
        '$_baseUrl/$templateId',
        queryParameters: {'userId': userId},
      );

      AppLogger.info(
        'Template deleted successfully',
        tag: 'JournalTemplateRemoteDataSource',
      );
      AppLogger.methodExit(
        'deleteTemplate',
        tag: 'JournalTemplateRemoteDataSource',
        result: 'success',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to delete template',
        tag: 'JournalTemplateRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<List<JournalTemplateResponseDto>> getFavoriteTemplates(
    String userId,
  ) async {
    AppLogger.methodEntry(
      'getFavoriteTemplates',
      tag: 'JournalTemplateRemoteDataSource',
      params: {'userId': userId},
    );

    try {
      final response = await _apiClient.get(
        '$_baseUrl/favorites',
        queryParameters: {'userId': userId},
      );

      AppLogger.info(
        'Favorite templates fetched successfully',
        tag: 'JournalTemplateRemoteDataSource',
      );
      AppLogger.methodExit(
        'getFavoriteTemplates',
        tag: 'JournalTemplateRemoteDataSource',
        result: 'success',
      );

      final list = response.data as List<dynamic>;
      return list
          .map((item) => JournalTemplateResponseDto.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      AppLogger.error(
        'Failed to fetch favorite templates',
        tag: 'JournalTemplateRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<List<JournalTemplateResponseDto>> getRecommendedTemplates(
    String userId,
  ) async {
    AppLogger.methodEntry(
      'getRecommendedTemplates',
      tag: 'JournalTemplateRemoteDataSource',
      params: {'userId': userId},
    );

    try {
      final response = await _apiClient.get(
        '$_baseUrl/recommended',
        queryParameters: {'userId': userId},
      );

      AppLogger.info(
        'Recommended templates fetched successfully',
        tag: 'JournalTemplateRemoteDataSource',
      );
      AppLogger.methodExit(
        'getRecommendedTemplates',
        tag: 'JournalTemplateRemoteDataSource',
        result: 'success',
      );

      final list = response.data as List<dynamic>;
      return list
          .map((item) => JournalTemplateResponseDto.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      AppLogger.error(
        'Failed to fetch recommended templates',
        tag: 'JournalTemplateRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<List<JournalTemplateResponseDto>> getMyTemplates(String userId) async {
    AppLogger.methodEntry(
      'getMyTemplates',
      tag: 'JournalTemplateRemoteDataSource',
      params: {'userId': userId},
    );

    try {
      final response = await _apiClient.get(
        '$_baseUrl/my-templates',
        queryParameters: {'userId': userId},
      );

      AppLogger.info(
        'My templates fetched successfully',
        tag: 'JournalTemplateRemoteDataSource',
      );
      AppLogger.methodExit(
        'getMyTemplates',
        tag: 'JournalTemplateRemoteDataSource',
        result: 'success',
      );

      final list = response.data as List<dynamic>;
      return list
          .map((item) => JournalTemplateResponseDto.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      AppLogger.error(
        'Failed to fetch my templates',
        tag: 'JournalTemplateRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<JournalTemplateResponseDto> toggleFavorite(
    String templateId,
    String userId,
  ) async {
    AppLogger.methodEntry(
      'toggleFavorite',
      tag: 'JournalTemplateRemoteDataSource',
      params: {'templateId': templateId},
    );

    try {
      final response = await _apiClient.post(
        '$_baseUrl/$templateId/favorite',
        queryParameters: {'userId': userId},
      );

      AppLogger.info(
        'Template favorite toggled successfully',
        tag: 'JournalTemplateRemoteDataSource',
      );
      AppLogger.methodExit(
        'toggleFavorite',
        tag: 'JournalTemplateRemoteDataSource',
        result: 'success',
      );

      return JournalTemplateResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to toggle template favorite',
        tag: 'JournalTemplateRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  @override
  Future<TradeJournalEntryResponseDto> useTemplate(
    String templateId,
    UseTemplateRequestDto request,
  ) async {
    AppLogger.methodEntry(
      'useTemplate',
      tag: 'JournalTemplateRemoteDataSource',
      params: {'templateId': templateId},
    );

    try {
      final response = await _apiClient.post(
        '$_baseUrl/$templateId/use',
        data: request.toJson(),
      );

      AppLogger.info(
        'Template used successfully',
        tag: 'JournalTemplateRemoteDataSource',
      );
      AppLogger.methodExit(
        'useTemplate',
        tag: 'JournalTemplateRemoteDataSource',
        result: 'success',
      );

      return TradeJournalEntryResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to use template',
        tag: 'JournalTemplateRemoteDataSource',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }
}
