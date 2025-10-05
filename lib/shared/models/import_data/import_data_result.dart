import 'import_data_option.dart';
import 'document_type.dart';
import 'broker_type.dart';

/// Import data result
class ImportDataResult {
  const ImportDataResult({
    required this.option,
    this.documentType,
    this.brokerType,
  });
  final ImportDataOption option;
  final DocumentType? documentType;
  final BrokerType? brokerType;

  @override
  String toString() =>
      'ImportDataResult(option: $option, documentType: $documentType, brokerType: $brokerType)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImportDataResult &&
        other.option == option &&
        other.documentType == documentType &&
        other.brokerType == brokerType;
  }

  @override
  int get hashCode => Object.hash(option, documentType, brokerType);
}
