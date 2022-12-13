import 'dart:async';
import 'dart:developer';

import 'package:chitchat/widgets/chat/sound_recorder.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class VoiceMessage extends StatefulWidget {
  const VoiceMessage({super.key});

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  static const maxSeconds = 120;
  int seconds = maxSeconds;
  Timer? timer;
  final recorder = SoundRecorder();

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        stopTimer();
      }
    });
  }

  void stopTimer() {
    timer!.cancel();
  }

  void resetTimer() {
    setState(() {
      seconds = maxSeconds;
    });
  }

  @override
  void initState() {
    recorder.init();
    startTimer();
    recorder.toggleRercording();
    super.initState();
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  String formatTime(int seconds) {
    int sec = seconds % 60;
    int min = (seconds / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute:$second";
  }

  @override
  Widget build(BuildContext context) {
    final bool isRecording = recorder.isRecording;
    final isTimerRunning = timer == null ? false : timer!.isActive;
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: recordInfo(isRecording)),
            if (!isRecording) playButton(isRecording),
            stopOrSendButton(isRecording, isTimerRunning),
          ],
        ),
      ),
    );
  }

  Widget recordInfo(bool isRecording) {
    final info = isRecording ? 'Recording started' : 'Recording stopped';
    final color = isRecording ? Colors.red : Colors.amber;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(30.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(
              Iconsax.microphone_25,
              color: Colors.white,
              size: 25,
            ),
            const SizedBox(width: 5.0),
            Text(
              formatTime(seconds),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10.0),
            Text(
              info,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget playButton(bool isRecording) => IconButton(
        onPressed: () {},
        icon: Icon(Icons.play_arrow_rounded),
        iconSize: 30,
        splashRadius: 20.0,
      );

  Widget stopOrSendButton(bool isRecording, bool isTimerRunning) {
    final icon = isTimerRunning ? Icons.stop_rounded : Iconsax.send_1;
    return FloatingActionButton(
      onPressed: () {
        log('is timer running = $isTimerRunning');
        if (isTimerRunning) {
          stopTimer();
          recorder.toggleRercording();
        }
        setState(() {});
      },
      mini: true,
      child: Icon(icon),
    );
  }
}
