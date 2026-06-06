enum BodyPart {
  head,
  foot,
  torso,
  udder;

  String toManifestString() {
    switch (this) {
      case BodyPart.head:
        return 'Head';
      case BodyPart.foot:
        return 'Foot';
      case BodyPart.torso:
        return 'Torso';
      case BodyPart.udder:
        return 'Udder';
    }
  }

  String get displayName {
    switch (this) {
      case BodyPart.head:
        return 'Head';
      case BodyPart.foot:
        return 'Foot';
      case BodyPart.torso:
        return 'Torso';
      case BodyPart.udder:
        return 'Udder';
    }
  }

  static BodyPart fromManifestString(String val) {
    switch (val.toLowerCase()) {
      case 'head':
        return BodyPart.head;
      case 'foot':
        return BodyPart.foot;
      case 'torso':
        return BodyPart.torso;
      case 'udder':
        return BodyPart.udder;
      default:
        throw ArgumentError('Unknown body part string: $val');
    }
  }
}
