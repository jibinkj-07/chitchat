import 'package:flutter/animation.dart';
import 'package:flutter_sound/flutter_sound.dart';

const audioPath = '/data/user/0/com.example.chitchat/cache/audio.aac';

class SoundPlayer {
  FlutterSoundPlayer? _audioPlayer;
  bool get isPlaying => _audioPlayer!.isPlaying;
  bool get isPaused => _audioPlayer!.isPaused;

  Future init() async {
    _audioPlayer = FlutterSoundPlayer();
    _audioPlayer!.openPlayer();
  }

  Future dispose() async {
    _audioPlayer!.closePlayer();
    _audioPlayer = null;
  }

  Future _play(VoidCallback whenFinished) async {
    await _audioPlayer!.startPlayer(
      fromURI: audioPath,
      whenFinished: whenFinished,
    );
  }

  Future _stop() async {
    await _audioPlayer!.stopPlayer();
  }

  Future pause() async {
    await _audioPlayer!.pausePlayer();
  }

  Future resume() async {
    await _audioPlayer!.resumePlayer();
  }

  Future togglePlayer({required VoidCallback whenFinished}) async {
    if (_audioPlayer!.isStopped) {
      await _play(whenFinished);
    } else {
      await _stop();
    }
  }
}
