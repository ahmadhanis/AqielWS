import 'package:audioplayers/audioplayers.dart';

/// A simple utility for playing one-shot sound effects throughout the app.
class AudioService {
  AudioService._(); // private constructor to prevent instantiation

  /// Play a short sound effect from assets and automatically release resources when done.
  ///
  /// [assetPath] should be relative to the `assets/` directory declared in pubspec.yaml,
  /// e.g. "sounds/coin.wav".
  static Future<void> playSfx(String assetPath) async {
    final player = AudioPlayer();

    // Ensure the player releases itself when playback completes
    await player.setReleaseMode(ReleaseMode.release);
    player.onPlayerComplete.listen((_) {
      player.dispose();
    });

    // Play the sound from assets
    await player.play(AssetSource(assetPath));
  }
}
