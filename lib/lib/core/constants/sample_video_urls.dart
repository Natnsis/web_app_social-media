/// Public sample MP4 clips (~15s) for mock short-form playback.
abstract final class SampleVideoUrls {
  SampleVideoUrls._();

  /// ~10s — reliable on mobile and desktop dev builds.
  static const String shortClipA =
      'https://www.w3schools.com/html/mov_bbb.mp4';

  static const String shortClipB =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';

  static const String shortClipC =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4';

  static String forIndex(int index) {
    switch (index % 3) {
      case 1:
        return shortClipB;
      case 2:
        return shortClipC;
      default:
        return shortClipA;
    }
  }
}
