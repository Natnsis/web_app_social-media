class RoutesConstant {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String forgotPassword = '/forgot-password';
  static const String language = '/language';
  static const String home = '/home';
  static const String chatList = '/chat';
  static const String shorts = '/shorts';
  static const String account = '/account';
  static const String accountSettings = '/account/settings';
  static const String editProfile = '/account/edit-profile';
  static const String editChurchProfile = '/church/:id/edit-profile';
  static const String monthlyGifts = '/account/gifts';
  static const String subscribers = '/account/subscribers';
  static const String following = '/account/following';
  static const String churchModerators = '/account/moderators';
  static const String analytics = '/account/analytics';
  static const String liveViewers = '/account/live-viewers';
  static const String chatDetail = '/chat/:id';
  static const String newGroup = '/chat/new-group';
  static const String chatAddUser = '/chat/add-user';
  static const String liveStreams = '/live';
  static const String liveStreamDetail = '/live/:id';
  static const String goLive = '/live/go';
  static const String churchProfile = '/profile/:id';

  /// Logged-in user's church — loads `GET /v1/churches/me/church`.
  static const String myChurchProfile = '/profile/me';
  static const String newPost = '/post/new';
  static const String scriptureNewPost = '/scripture/new-post';
  static const String postDetail = '/post/:id';
  static const String editPost = '/post/:id/edit';
  static const String campaigns = '/campaigns';
  static const String newCampaign = '/campaigns/new';
  static const String campaignDetail = '/campaigns/:id';
  static const String editCampaign = '/campaigns/:id/edit';
  static const String discovery = '/discovery';
  static const String discoveryNearby = '/discovery/nearby';
  static const String events = '/events';
  static const String editEvent = '/events/:id/edit';
  static const String giftChurchSearch = '/gift-church-search';
  static const String gift = '/gift';
  static const String notifications = '/notifications';
  static const String wallet = '/wallet';
}
