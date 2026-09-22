import 'package:flutter/material.dart';
import 'package:campus_care/core/audio/voice_recorder_service.dart';

class VoiceReportWidget extends StatefulWidget {
  final void Function(String audioPath) onRecordingComplete;

  const VoiceReportWidget({super.key, required this.onRecordingComplete});

  @override
  State<VoiceReportWidget> createState() => _VoiceReportWidgetState();
}

class _VoiceReportWidgetState extends State<VoiceReportWidget> {
  bool _recording = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Voice Input (AI-Transcribed)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            IconButton(
              iconSize: 48,
              color: _recording ? Colors.red : Theme.of(context).primaryColor,
              icon: Icon(_recording ? Icons.mic : Icons.mic_none),
              onPressed: () async {
                setState(() => _recording = !_recording);
                if (!_recording) {
                  final path = await voiceRecorderService.stopRecording();
                  if (path != null) {
                    widget.onRecordingComplete(path);
                  }
                } else {
                  await voiceRecorderService.startRecording();
                }
              },
            ),
            Text(_recording ? 'Recording... Tap to Stop' : 'Tap mic to speak your issue'),
          ],
        ),
      ),
    );
  }
}
