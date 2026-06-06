enum CropType {
  rectangular,
  masked;

  static CropType fromManifestString(String val) {
    switch (val.toLowerCase()) {
      case 'rectangular':
        return CropType.rectangular;
      case 'masked':
        return CropType.masked;
      default:
        throw ArgumentError('Unknown crop type string: $val');
    }
  }

  String toManifestString() {
    switch (this) {
      case CropType.rectangular:
        return 'rectangular';
      case CropType.masked:
        return 'masked';
    }
  }
}
