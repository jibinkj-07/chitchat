import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/message_Item.dart';
import 'package:chitchat/widgets/chat/image_message_preview.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:developer' as dev;

import '../../../utils/custom_shape.dart';

class ReceivedMessageBubble extends StatefulWidget {
  final MessageItem messageItem;

  final String messageTime;
  const ReceivedMessageBubble({
    super.key,
    required this.messageItem,
    required this.messageTime,
  });

  @override
  State<ReceivedMessageBubble> createState() => _ReceivedMessageBubbleState();
}

class _ReceivedMessageBubbleState extends State<ReceivedMessageBubble> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isPaused = false;
  Duration duraiton = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    //listen to player state change
    if (widget.messageItem.type == 'voice') {
      audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          if (!mounted) return;
          setState(() {
            position = Duration.zero;
          });
        }
        if (!mounted) return;
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      });

      //listen to audio duration change
      audioPlayer.onDurationChanged.listen((newDuration) {
        if (!mounted) return;
        setState(() {
          duraiton = newDuration;
        });
      });

      //listen to audio position change
      audioPlayer.onPositionChanged.listen((newPosition) {
        if (!mounted) return;
        setState(() {
          position = newPosition;
        });
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.messageItem.type == 'voice') {
      audioPlayer.dispose();
    }
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
    AppColors appColors = AppColors();

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(
        left: 2.0,
        right: 80,
        bottom: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 30),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: CustomPaint(
                    painter: CustomShape(appColors.textColorWhite),
                    size: const Size(8, 10),
                  ),
                ),
                Flexible(
                  child: Material(
                    color: appColors.textColorWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: messageType(
                        messageItem: widget.messageItem,
                        appColors: appColors,
                        context: context,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget messageType({
    required MessageItem messageItem,
    required AppColors appColors,
    required BuildContext context,
  }) {
    switch (messageItem.type) {
      case 'text':
        return textMessage(appColors: appColors);
      case 'image':
        return imageMessage(context: context, appColors: appColors);
      case 'voice':
        return voiceMessage(appColors: appColors, messageItem: messageItem);
      default:
        return const SizedBox();
    }
  }

  Widget textMessage({required AppColors appColors}) => Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          Text(
            '${widget.messageItem.message}   ',
            style: TextStyle(
              color: appColors.textColorBlack,
              fontSize:
                  EmojiUtil.hasOnlyEmojis(widget.messageItem.message) ? 30 : 15,
            ),
          ),

          //time
          Text(
            widget.messageTime,
            style: TextStyle(
              color: appColors.textColorBlack.withOpacity(.8),
              fontSize: 11,
            ),
          ),
        ],
      );

  Widget imageMessage(
          {required AppColors appColors, required BuildContext context}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //image preview
          Container(
            width: 240,
            height: 280,
            decoration: BoxDecoration(
              color: appColors.textColorBlack,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ImageMessagePreview(
                        url: widget.messageItem.message,
                        messageItem: widget.messageItem),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: CachedNetworkImage(
                  imageUrl: widget.messageItem.message,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CupertinoActivityIndicator(
                    color: appColors.primaryColor,
                    radius: 10,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: appColors.redColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          if (widget.messageItem.caption != '')
            SizedBox(
              width: 240,
              child: Text(
                widget.messageItem.caption,
                style: TextStyle(
                  color: appColors.textColorBlack,
                  fontSize: 15,
                ),
              ),
            ),
          //time
          Text(
            widget.messageTime,
            style: TextStyle(
              color: appColors.textColorBlack.withOpacity(.8),
              fontSize: 11,
            ),
          ),
        ],
      );

  Widget voiceMessage({
    required AppColors appColors,
    required MessageItem messageItem,
  }) {
    final icon = isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //mic icon
        CircleAvatar(
          radius: 25,
          backgroundColor: appColors.primaryColor,
          child: const Icon(
            Iconsax.microphone_2,
            size: 25,
            color: Colors.white,
          ),
        ),

        //slider
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: appColors.primaryColor,
                    inactiveTrackColor: Colors.grey,
                    trackHeight: 3.0,
                    thumbColor: appColors.primaryColor,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayColor: appColors.primaryColor.withOpacity(.3),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14.0),
                  ),
                  child: Slider(
                    min: 0,
                    max: duraiton.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble(),
                    // activeColor: appColors.primaryColor,
                    // inactiveColor: Colors.grey,
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await audioPlayer.seek(position);

                      // await audioPlayer.resume();
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(position.inSeconds),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: appColors.textColorBlack,
                      ),
                    ),
                    Text(
                      formatTime((duraiton - position).inSeconds),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: appColors.textColorBlack,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),

        Column(
          children: [
            IconButton(
              onPressed: () async {
                if (isPlaying) {
                  await audioPlayer.pause();
                } else {
                  await audioPlayer.play(
                    UrlSource(messageItem.message),
                  );
                }
              },
              icon: Icon(icon),
              color: appColors.primaryColor,
              iconSize: 30.0,
              splashRadius: 20.0,
            ),
            Text(
              '${widget.messageTime}  ',
              style: TextStyle(
                color: appColors.textColorBlack.withOpacity(.8),
                fontSize: 11,
              ),
            ),
          ],
        )
      ],
    );
  }
}
