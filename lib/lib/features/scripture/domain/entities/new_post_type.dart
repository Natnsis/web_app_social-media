enum NewPostType {
  event,
  scripture,
  attachment,
}

extension NewPostTypeX on NewPostType {
  String get label {
    switch (this) {
      case NewPostType.event:
        return 'Event';
      case NewPostType.scripture:
        return 'Scripture';
      case NewPostType.attachment:
        return 'Attachment';
    }
  }

  static List<NewPostType> get valuesOrdered => NewPostType.values;
}
