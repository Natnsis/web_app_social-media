/// Active persona in the home shell (sidebar + create actions).
enum HomeShellAccountMode {
  church,
  user;

  bool get isChurch => this == HomeShellAccountMode.church;

  bool get showCreateActions => isChurch;

  String get roleLabel => switch (this) {
        HomeShellAccountMode.church => 'Church Administrator',
        HomeShellAccountMode.user => 'Community Member',
      };

  /// Short label for account-type selectors (drawer, sheets).
  String get selectLabel => switch (this) {
        HomeShellAccountMode.church => 'Church',
        HomeShellAccountMode.user => 'User',
      };

  static HomeShellAccountMode fromStorage(String? value) {
    if (value == HomeShellAccountMode.user.name) {
      return HomeShellAccountMode.user;
    }
    return HomeShellAccountMode.church;
  }
}
