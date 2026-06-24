import 'package:flutter/material.dart';

/// Bookmark icons for save / saved state across feed and profile.
IconData saveBookmarkIcon({required bool isSaved}) {
  return isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded;
}
