enum ChurchProfileTab {
  members,
  posts,
  campaigns,
  groups,
}

extension ChurchProfileTabX on ChurchProfileTab {
  String get label {
    switch (this) {
      case ChurchProfileTab.members:
        return 'Members';
      case ChurchProfileTab.posts:
        return 'Posts';
      case ChurchProfileTab.campaigns:
        return 'Campaigns';
      case ChurchProfileTab.groups:
        return 'Groups';
    }
  }

  static List<ChurchProfileTab> get valuesOrdered => ChurchProfileTab.values;
}
