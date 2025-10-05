import '../dtos/portfolio_list_dto.dart';
import '../../domain/entities/portfolio_list.dart';
import '../../../../../core/utils/logger.dart';

/// Mapper class for Portfolio List operations
///
/// Handles conversion between DTO and domain entities for portfolio list operations
class PortfolioListMapper {
  /// Convert PortfolioListDto to PortfolioList domain entity
  static PortfolioList fromApiModel(PortfolioListDto dto, String userId) {
    AppLogger.debug(
      'Mapping PortfolioListDto to PortfolioList domain entity',
      tag: 'PortfolioListMapper',
    );

    try {
      // Map individual portfolio items
      final portfolioItems = dto.portfolios
          .map(
            (itemDto) => PortfolioItem(
              portfolioId: itemDto.portfolioId,
              portfolioName: itemDto.portfolioName,
            ),
          )
          .toList();

      // Create domain entity
      final portfolioList = PortfolioList(
        userId: userId,
        portfolios: portfolioItems,
        lastUpdated: DateTime.now(),
      );

      AppLogger.debug(
        'Successfully mapped ${portfolioItems.length} portfolio items to domain entity',
        tag: 'PortfolioListMapper',
      );

      return portfolioList;
    } catch (e) {
      AppLogger.error(
        'Failed to map PortfolioListDto to domain entity',
        tag: 'PortfolioListMapper',
        error: e,
      );
      throw Exception('Invalid portfolio list mapping: ${e.toString()}');
    }
  }

  /// Convert PortfolioList domain entity to PortfolioListDto
  static PortfolioListDto toApiModel(PortfolioList entity) {
    AppLogger.debug(
      'Mapping PortfolioList domain entity to PortfolioListDto',
      tag: 'PortfolioListMapper',
    );

    try {
      // Map individual portfolio items
      final portfolioItemDtos = entity.portfolios
          .map(
            (item) => PortfolioItemDto(
              portfolioId: item.portfolioId,
              portfolioName: item.portfolioName,
            ),
          )
          .toList();

      // Create DTO
      final portfolioListDto = PortfolioListDto(portfolios: portfolioItemDtos);

      AppLogger.debug(
        'Successfully mapped ${portfolioItemDtos.length} portfolio items to DTO',
        tag: 'PortfolioListMapper',
      );

      return portfolioListDto;
    } catch (e) {
      AppLogger.error(
        'Failed to map PortfolioList domain entity to DTO',
        tag: 'PortfolioListMapper',
        error: e,
      );
      throw Exception('Invalid portfolio list mapping: ${e.toString()}');
    }
  }

  /// Create empty PortfolioList for error scenarios
  static PortfolioList createEmpty(String userId) => PortfolioList(
    userId: userId,
    portfolios: [],
    lastUpdated: DateTime.now(),
  );

  /// Validate portfolio list data
  static bool isValidPortfolioList(PortfolioListDto dto) {
    try {
      // Check if the list exists and is not null
      if (dto.portfolios.isEmpty) {
        AppLogger.debug(
          'Portfolio list is empty but valid',
          tag: 'PortfolioListMapper',
        );
        return true;
      }

      // Validate each portfolio item
      for (final item in dto.portfolios) {
        if (item.portfolioId.isEmpty || item.portfolioName.isEmpty) {
          AppLogger.warning(
            'Invalid portfolio item found: ${item.toString()}',
            tag: 'PortfolioListMapper',
          );
          return false;
        }
      }

      return true;
    } catch (e) {
      AppLogger.error(
        'Failed to validate portfolio list',
        tag: 'PortfolioListMapper',
        error: e,
      );
      return false;
    }
  }
}
