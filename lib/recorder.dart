import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/sound_player.dart';
import 'package:chitchat/widgets/chat/sound_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'logic/cubit/internet_cubit.dart';

class Recorder extends StatefulWidget {
  const Recorder({super.key});

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  bool isVoiceRecording = true;
  final recorder = SoundRecorder();
  final audioPlayer = AudioPlayer();
  final stopWatch = Stopwatch();
  bool isPlaying = false;
  bool isPaused = false;
  int recordingTime = 0;
  Duration duraiton = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    recorder.init();
    //listen to player state change
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        setState(() {
          position = Duration.zero;
        });
      }
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    //listen to audio duration change
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duraiton = newDuration;
      });
    });

    //listen to audio position change
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    recorder.dispose();
    audioPlayer.dispose();
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildRecorder(),
            // soundPlayer(),
          ],
        ),
      ),
    );
  }

  Widget buildRecorder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isVoiceRecording
              ? Expanded(
                  child: Material(
                    color: Colors.grey.withOpacity(.4),
                    borderRadius: BorderRadius.circular(80.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Iconsax.microphone,
                            color: AppColors().redColor,
                          ),
                          Text(formatTime(recordingTime)),
                          Text('recording voice'),
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: IconButton(
                              padding: const EdgeInsets.all(0.0),
                              onPressed: () {
                                setState(() {
                                  isVoiceRecording = false;
                                });
                              },
                              iconSize: 20,
                              icon: const Icon(Icons.close),
                              splashRadius: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Text('Record Audio'),
          voicSendButton()
        ],
      ),
    );
  }

  // Widget soundPlayer() {
  //   final icon = isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded;
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5.0),
  //     child: Material(
  //       borderRadius: BorderRadius.circular(8.0),
  //       color: AppColors().primaryColor,
  //       child: Column(
  //         children: [
  //           //play controller
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Expanded(
  //                 child: Slider(
  //                   min: 0,
  //                   max: duraiton.inSeconds.toDouble(),
  //                   value: position.inSeconds.toDouble(),
  //                   activeColor: Colors.white,
  //                   inactiveColor: Colors.grey,
  //                   onChanged: (value) async {
  //                     final position = Duration(seconds: value.toInt());
  //                     await audioPlayer.seek(position);

  //                     // await audioPlayer.resume();
  //                   },
  //                 ),
  //               ),
  //               IconButton(
  //                 onPressed: () async {
  //                   if (isPlaying) {
  //                     await audioPlayer.pause();
  //                   } else {
  //                     String url =
  //                         'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  //                     await audioPlayer.play(DeviceFileSource(
  //                         '/data/user/0/com.example.chitchat/cache/audio.aac'));
  //                   }
  //                 },
  //                 icon: Icon(
  //                   icon,
  //                   color: Colors.white,
  //                 ),
  //                 iconSize: 30,
  //                 splashRadius: 20.0,
  //               ),
  //             ],
  //           ),

  //           //time
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 15.0),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(formatTime(position.inSeconds)),
  //                 Text(formatTime((duraiton - position).inSeconds)),
  //               ],
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget voicSendButton() => BlocBuilder<InternetCubit, InternetState>(
        builder: (context, cubitState) {
          final isRecording = recorder.isRecording;
          final text = isRecording ? 'Recording' : 'Stopped';
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text),
              FloatingActionButton(
                backgroundColor: AppColors().primaryColor,
                foregroundColor: Colors.white,
                mini: true,
                onPressed: () async {
                  // if (cubitState is InternetEnabled) {
                  //   await recorder.toggleRercording();
                  //   setState(() {});
                  // }
                  stopWatch.start();
                },
                child: const Icon(
                  Iconsax.send_1,
                  size: 22,
                ),
              ),
            ],
          );
        },
      );
}
