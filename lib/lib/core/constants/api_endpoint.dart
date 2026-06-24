/// REST path constants (append to [EnvConfig.apiBaseUrl]).
abstract final class ApiEndpoint {
  ApiEndpoint._();

  static const String v1 = '/v1';
  static const String churchAnalytics = '/v1/analytics/churches/{churchId}';
}

/// Authentication endpoints (`POST /v1/auth/*`).
abstract final class AuthApiEndpoint {
  AuthApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/auth';

  /// Register a new account (public).
  static const String register = '$_base/register';

  /// Login with email or phone number + password.
  static const String login = '$_base/login';

  /// Resend OTP to the same phone number.
  static const String otpResend = '$_base/otp/resend';

  /// Verify OTP and receive JWT tokens.
  static const String otpVerify = '$_base/otp/verify';

  /// Login or register with a Google ID token.
  static const String loginGoogle = '$_base/login/google';

  /// Refresh access token.
  static const String refresh = '$_base/refresh';

  /// Logout and invalidate the refresh token (authenticated).
  static const String logout = '$_base/logout';

  /// Change current user password (authenticated).
  static const String passwordChange = '$_base/password/change';

  /// Request a password-reset link via email (public).
  static const String passwordForgot = '$_base/password/forgot';

  /// Reset password using the token received by email (public).
  static const String passwordReset = '$_base/password/reset';

  /// Add a phone number and request OTP (authenticated).
  static const String phoneAdd = '$_base/phone/add';
}

/// Authenticated users — own profile, avatar upload, location sharing.
abstract final class UsersApiEndpoint {
  UsersApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/users';

  /// Get or update own profile (`GET` / `PATCH`).
  static const String me = '$_base/me';

  /// Update location / toggle location sharing.
  static const String meLocation = '$me/location';

  /// Search users by name or phone (`GET`, query: `q`, `page`, `limit`).
  static const String search = '$_base/search';
}

/// Church discovery, profiles, members, and dashboard.
abstract final class ChurchesApiEndpoint {
  ChurchesApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/churches';

  /// Browse churches.
  static const String list = _base;

  /// Register a new church.
  static const String register = _base;

  /// Find churches near my location.
  static const String nearby = '$_base/nearby';

  /// Get my church.
  static const String myChurch = '$_base/me/church';

  /// Churches the authenticated user follows (`GET`).
  static const String myFollowing = '$_base/me/following';

  /// Church by id — detail (`GET`), update (`PATCH`), or delete (`DELETE`).
  static String detail(String id) => '$_base/$id';

  /// List (`GET`) or assign (`POST`) church moderators.
  static String members(String id) => '${detail(id)}/members';

  /// Follower count, follower list, and follow status.
  static String followInfo(String id) => '${detail(id)}/follow-info';

  /// Church dashboard summary.
  static String dashboard(String id) => '${detail(id)}/dashboard';

  /// Dashboard — gift transactions received by the church.
  static String dashboardGifts(String id) => '${dashboard(id)}/gifts';

  /// Dashboard — all payment transactions received by the church.
  static String dashboardTransactions(String id) =>
      '${dashboard(id)}/transactions';

  /// Dashboard — church withdrawal history with commission breakdown.
  static String dashboardWithdrawals(String id) =>
      '${dashboard(id)}/withdrawals';

  /// Dashboard — full donor list for a church campaign.
  static String dashboardCampaignDonors(
    String churchId,
    String campaignId,
  ) =>
      '${dashboard(churchId)}/campaigns/$campaignId/donors';

  /// Submit church for verification (KYC).
  static String verificationSubmit(String id) =>
      '${detail(id)}/verification/submit';

  /// View my verification submission history.
  static String verificationApplications(String id) =>
      '${detail(id)}/verification/applications';

  /// Revoke a moderator.
  static String memberRevoke(String churchId, String userId) =>
      '${members(churchId)}/$userId';

  /// Follow or unfollow a church (`POST` / `DELETE`).
  static String follow(String id) => '${detail(id)}/follow';

  /// Browse scrypers across churches (`GET /v1/churches/scrypers`).
  static const String scrypersAll = '$_base/scrypers';

  /// Get (`GET`) or publish (`POST`) the active scryper for a church.
  static String scryper(String id) => '${detail(id)}/scryper';

  /// List all scrypers for a church.
  static String scrypers(String id) => '${detail(id)}/scrypers';

  /// Delete a scryper.
  static String scryperDelete(String churchId, String scryperId) =>
      '${scryper(churchId)}/$scryperId';

  /// List (`GET`) or register (`POST`) church payment accounts.
  static String paymentAccounts(String id) => '${detail(id)}/payment-accounts';

  /// Update (`PATCH`) or deactivate (`DELETE`) a church payment account.
  static String paymentAccount(String churchId, String accountId) =>
      '${paymentAccounts(churchId)}/$accountId';

  static const String churchAnalytics = '/v1/analytics/churches/{churchId}';
}

/// Campaign creation, listing, updates, and contributions.
abstract final class CampaignsApiEndpoint {
  CampaignsApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/campaigns';

  /// Create (`POST`) or list (`GET`) campaigns.
  static const String list = _base;

  /// List campaigns from churches the user follows (`GET`).
  static const String following = '$_base/following';

  /// List campaigns for a specific church.
  static String byChurch(String churchId) => '$_base/church/$churchId';

  /// Get (`GET`), update (`PATCH`), or soft-delete (`DELETE`) a campaign.
  static String detail(String id) => '$_base/$id';

  /// List donors / contributions for a campaign.
  static String contributions(String id) => '${detail(id)}/contributions';

  /// List (`GET`) or post (`POST`) progress updates for a campaign.
  static String updates(String id) => '${detail(id)}/updates';
}

/// Church events — public browse; church owners create and manage their events.
abstract final class EventsApiEndpoint {
  EventsApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/events';

  /// Create (`POST`) or list active events (`GET`).
  static const String list = _base;

  /// List events for the authenticated user's church.
  static const String mine = '$_base/mine';

  /// List active events for a specific church.
  static String byChurch(String churchId) => '$_base/church/$churchId';

  /// Get (`GET`), update (`PATCH`), or soft-delete (`DELETE`) an event.
  static String detail(String id) => '$_base/$id';
}

/// 1-to-1 direct messaging (`GET /v1/messaging/messages`, socket `/messaging`).
abstract final class MessagingApiEndpoint {
  MessagingApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/messaging';

  /// Recent direct messages across conversations (`GET`).
  static const String messages = '$_base/messages';

  /// Upload media for direct messaging (`POST` multipart, field: media).
  static const String media = '$_base/media';

  /// Messages for one conversation (`GET ?conversationId=`).
  static Map<String, String> messagesQuery({required String conversationId}) =>
      {'conversationId': conversationId};

  /// List blocked users (`GET`).
  static const String blocks = '$_base/blocks';

  /// Block (`POST`) or unblock (`DELETE`) a user.
  static String blockUser(String userId) => '$blocks/$userId';
}

/// Church / community groups (`POST` create uses multipart: name, description, isPrivate, image).
abstract final class GroupsApiEndpoint {
  GroupsApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/groups';

  /// Create (`POST`) or list (`GET`) groups.
  static const String list = _base;

  /// Get (`GET`), update (`PATCH`), or delete (`DELETE`) a group.
  static String detail(String id) => '$_base/$id';

  /// Request to join (`POST`) or list pending requests (`GET`) for a private group.
  static String joinRequests(String groupId) => '${detail(groupId)}/join-requests';

  /// Approve a pending join request.
  static String approveJoinRequest(String groupId, String userId) =>
      '${joinRequests(groupId)}/$userId/approve';

  /// Reject a pending join request.
  static String rejectJoinRequest(String groupId, String userId) =>
      '${joinRequests(groupId)}/$userId/reject';

  /// Upload media for a group (`POST` multipart, field: media).
  static const String media = '$_base/media';

  /// List group members (`GET`).
  static String members(String groupId) => '${detail(groupId)}/members';

  /// Remove a member from the group (`DELETE`).
  static String removeMember(String groupId, String userId) =>
      '${members(groupId)}/$userId';

  /// Ban a user from the group (`POST` or `PUT`).
  static String banMember(String groupId, String userId) =>
      '${detail(groupId)}/bans/$userId';

  /// Leave the group (`POST`).
  static String leave(String groupId) => '${detail(groupId)}/leave';

  /// Invite a user directly into the group.
  static String inviteMember(String groupId, String userId) =>
      '${members(groupId)}/invite/$userId';

  /// List top-level group messages
  static String comments(String id) => '${detail(id)}/comments';

  /// List top-level group messages
  static String groupMessages(String id) => '${detail(id)}/groupmessages';

  /// Delete a group message (church owner or group moderator)
  static String deleteComment(String id, String commentId) =>
      '${comments(id)}/$commentId';
}

/// Group messages endpoints.
abstract final class GroupMessagesApiEndpoint {
  GroupMessagesApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/groupmessages';

  /// List replies to a group message
  static String replies(String id) => '$_base/$id/replies';
}

/// Upload file to Nova storage then attach returned `id` to posts.
abstract final class NovaFilesApiEndpoint {
  NovaFilesApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/nova-files';

  /// Upload one file (`POST multipart/form-data` with `file`).
  static const String upload = _base;
}

/// Short-form vertical videos (`POST` upload, then `POST` publish).
abstract final class ShortsApiEndpoint {
  ShortsApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/shorts';

  /// Upload a new short in draft state (`POST multipart/form-data`).
  static const String list = _base;

  /// Get (`GET`), update (`PATCH`), or delete (`DELETE`) a short.
  static String detail(String id) => '$_base/$id';

  /// Make a draft short public.
  static String publish(String id) => '${detail(id)}/publish';

  static String comments(String id) => '${detail(id)}/comments';

  static String deleteComment(String id, String commentId) =>
      '${comments(id)}/$commentId';
}

/// Posts, likes, saves, and comments.
abstract final class PostsApiEndpoint {
  PostsApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/posts';

  /// Create (`POST`) or list (`GET`) posts.
  static const String list = _base;

  /// List posts for a specific church.
  static String byChurch(String churchId) => '$_base/church/$churchId';

  /// List posts saved for read later.
  static const String saved = '$_base/saved';

  /// Get (`GET`), update (`PATCH`), or soft-delete (`DELETE`) a post.
  static String detail(String id) => '$_base/$id';

  /// Like or unlike a post (`POST` / `DELETE`).
  static String like(String id) => '${detail(id)}/like';

  /// Save or remove from saved list (`POST` / `DELETE`).
  static String save(String id) => '${detail(id)}/save';

  /// List (`GET`) or create (`POST`) comments on a post.
  static String comments(String id) => '${detail(id)}/comments';
}

/// Cross-resource comments (posts, shorts, groups).
abstract final class CommentsApiEndpoint {
  CommentsApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/comments';

  /// Get (`GET`), update (`PATCH`), or soft-delete (`DELETE`) a comment.
  static String detail(String commentId) => '$_base/$commentId';

  /// List (`GET`) or create (`POST multipart`: `body`, optional `media`) replies.
  static String replies(String commentId) => '${detail(commentId)}/replies';

  /// Like or unlike a comment (`POST` / `DELETE`).
  static String like(String commentId) => '${detail(commentId)}/like';
}

abstract final class NotificationsApiEndpoint {
  NotificationsApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/notifications';

  static const String registerDevice = '$_base/devices';

  /// Unregister or manage a specific device (`DELETE /v1/notifications/devices/{deviceId}`).
  static String device(String deviceId) => '$_base/devices/$deviceId';

  static const String base = _base;

  static const String unreadCount = '$_base/unread-count';

  static const String preferences = '$_base/preferences';

  static const String readAll = '$_base/read-all';

  static String read(String id) => '$_base/$id/read';
}

/// Billing endpoints for gifts and campaigns.
abstract final class BillingApiEndpoint {
  BillingApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/billing';

  /// Request a withdrawal.
  static const String withdrawals = '$_base/withdrawals';

  /// Buy and send a gift.
  static const String gifts = '$_base/gifts';

  /// Donate to a specific campaign.
  static String campaignDonate(String campaignId) =>
      '$_base/campaigns/$campaignId/donate';

  /// Check payment transaction status after payment approval.
  static String transactionStatus(String txRef) =>
      '$_base/transactions/$txRef/status';
}

/// Live Stream endpoints.
abstract final class LiveStreamApiEndpoint {
  LiveStreamApiEndpoint._();

  static const String _base = '${ApiEndpoint.v1}/livestream';

  static const String list = _base;

  static String detail(String id) => '$_base/$id';

  static String publish(String id) => '${detail(id)}/publish';
}
