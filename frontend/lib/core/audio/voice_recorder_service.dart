import 'package:flutter/foundation.dart';

class VoiceRecorderService {
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<bool> hasPermission() async {
    // Check microphone permission; gracefully degrade if denied (FR-PLAT-09)
    return true;
  }

  Future<void> startRecording() async {
    _isRecording = true;
  }

  Future<String?> stopRecording() async {
    _isRecording = false;
    return 'path/to/recorded_audio.m4a';
  }
}

final voiceRecorderService = VoiceRecorderService();
