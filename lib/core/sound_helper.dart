import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isSoundEnabled = true; // Default: sound is enabled

  static bool get isSoundEnabled => _isSoundEnabled;

  static void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  static void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
  }

  static Future<void> playCorrect() async {
    if (!_isSoundEnabled) return;
    await _player.play(AssetSource('sounds/correct.mp3'));
  }

  static Future<void> playWrong() async {
    if (!_isSoundEnabled) return;
    await _player.play(AssetSource('sounds/wrong.mp3'));
  }
}