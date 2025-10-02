import 'import_data_option.dart';
import 'document_type.dart';
import 'broker_type.dart';

/// Import data result
class ImportDataResult {
  final ImportDataOption option;
  final DocumentType? documentType;
  final BrokerType? brokerType;

  const ImportDataResult({
    required this.option,
    this.documentType,
    this.brokerType,
  });

  @override
  String toString() {
    return 'ImportDataResult(option: $option, documentType: $documentType, brokerType: $brokerType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImportDataResult &&
        other.option == option &&
        other.documentType == documentType &&
        other.brokerType == brokerType;
  }

  @override
  int get hashCode {
    return Object.hash(option, documentType, brokerType);
  }
}