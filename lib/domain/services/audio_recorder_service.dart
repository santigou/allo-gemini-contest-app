import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder {
  FlutterSoundRecorder _recorder;
  bool _isRecording = false;

  AudioRecorder() {
    _recorder = FlutterSoundRecorder();
  }

  Future<void> startRecording() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _recorder.startRecorder(toFile: 'audio.aac');
      _isRecording = true;
    }
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      await _recorder.stopRecorder();
      _isRecording = false;
    }
  }
}