/// Route / request keys for church profile navigation.
abstract final class ChurchProfileIds {
  ChurchProfileIds._();

  /// Opens [ChurchesApiEndpoint.myChurch] (`GET /v1/churches/me/church`).
  static const String me = 'me';

  static bool isMyChurch(String profileId) =>
      profileId.trim().toLowerCase() == me;
}
