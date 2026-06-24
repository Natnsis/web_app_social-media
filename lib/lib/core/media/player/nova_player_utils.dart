import 'package:nova_player/nova_player.dart';

/// Safe wrapper for Nova commands before the widget attaches a data source.
void novaPlayerCall(void Function() action) {
  try {
    action();
  } on StateError {
    // Controller not yet attached to a VideoPlayer surface.
  }
}

Future<void> novaPlayerCallAsync(Future<void> Function() action) async {
  try {
    await action();
  } on StateError {
    // Controller not yet attached.
  }
}

bool isNovaLoading(PlayBackState state) {
  return state == PlayBackState.none ||
      state == PlayBackState.initalizing ||
      state == PlayBackState.initalized ||
      state == PlayBackState.buffering;
}
