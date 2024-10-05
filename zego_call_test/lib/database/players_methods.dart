import 'package:audioplayers/audioplayers.dart';

class AudioPlayerMethods {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playAudio(String url, bool looping) async {
    looping
        ? _player.setReleaseMode(ReleaseMode.loop)
        : _player.setReleaseMode(ReleaseMode.release);
    return await _player.play(
      UrlSource(
        url,
      ),
    );
  }

  Future<void> stopPlayer() {
    return _player.stop();
  }
}
