import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;
import '../../../utils/app_colors.dart';
import '../../../utils/custom_shape.dart';
import '../../../utils/message_Item.dart';
import '../image_message_preview.dart';

class RepliedReceivedChatBubble extends StatefulWidget {
  final MessageItem messageItem;
  final String messageTime;
  const RepliedReceivedChatBubble({
    super.key,
    required this.messageItem,
    required this.messageTime,
  });

  @override
  State<RepliedReceivedChatBubble> createState() =>
      _RepliedReceivedChatBubbleState();
}

class _RepliedReceivedChatBubbleState extends State<RepliedReceivedChatBubble> {
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

//calculating message length
    const double baseWidth = 80;
    double width = 0;
    if (widget.messageItem.message.length > 25) {
      width = baseWidth + 200;
    } else {
      width = baseWidth + (widget.messageItem.message.length * 7.5);
    }
    //main
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
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: appColors.textColorWhite,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: messageChooser(
                      messageItem: widget.messageItem,
                      appColors: appColors,
                      width: width,
                      context: context,
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

  Widget messageChooser({
    required MessageItem messageItem,
    required AppColors appColors,
    required double width,
    required BuildContext context,
  }) {
    switch (messageItem.type) {
      case 'text':
        return textMessage(appColors: appColors, width: width);
      case 'image':
        return imageMessage(appColors: appColors, context: context);
      case 'voice':
        return voiceMessage(appColors: appColors, messageItem: messageItem);
      default:
        return const SizedBox();
    }
  }

  Widget textMessage({required AppColors appColors, required double width}) =>
      InkWell(
        onLongPress: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //replied preview

            widget.messageItem.replyingParentMessageType == 'image'
                ? imageReplyMessage(appColors: appColors)
                : widget.messageItem.replyingParentMessageType == 'text'
                    ? textReplyMessage(appColors: appColors)
                    : voiceReplyMessage(appColors: appColors),
            const SizedBox(height: 5),
            //sent message
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text(
                  '${widget.messageItem.message}   ',
                  style: TextStyle(
                    color: appColors.textColorBlack,
                    fontSize:
                        EmojiUtil.hasOnlyEmojis(widget.messageItem.message)
                            ? 30
                            : 15,
                  ),
                  textAlign: TextAlign.left,
                ),

                //time and read status

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.messageTime}  ',
                      style: TextStyle(
                        color: appColors.textColorBlack.withOpacity(.8),
                        fontSize: 11,
                      ),
                    ),
                    if (widget.messageItem.read)
                      const Text(
                        'read',
                        style: TextStyle(
                          color: Colors.lime,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                  ],
                )
              ],
            ),
          ],
        ),
      );

  Widget imageMessage(
          {required BuildContext context, required AppColors appColors}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.messageItem.replyingParentMessageType == 'image'
              ? imageReplyMessage(appColors: appColors)
              : widget.messageItem.replyingParentMessageType == 'text'
                  ? textReplyMessage(appColors: appColors)
                  : voiceReplyMessage(appColors: appColors),
          //image preview
          Container(
            width: 240,
            height: 280,
            margin: const EdgeInsets.only(top: 8.0),
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
              onLongPress: () {},
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
          //time and read status
          Text(
            '${widget.messageTime}  ',
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
    return GestureDetector(
      onLongPress: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.messageItem.replyingParentMessageType == 'image'
              ? imageReplyMessage(appColors: appColors)
              : widget.messageItem.replyingParentMessageType == 'text'
                  ? textReplyMessage(appColors: appColors)
                  : voiceReplyMessage(appColors: appColors),
          Row(
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
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8.0),
                          overlayColor: appColors.primaryColor.withOpacity(.3),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14.0),
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
          ),
        ],
      ),
    );
  }

  Widget textReplyMessage({required AppColors appColors}) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: widget.messageItem.isRepliedToMyself
                  ? appColors.yellowColor
                  : appColors.textColorBlack,
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                !widget.messageItem.isRepliedToMyself
                    ? Text(
                        'You',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appColors.textColorBlack,
                          fontSize: 12,
                        ),
                      )
                    : Text(
                        widget.messageItem.targetUsername,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appColors.yellowColor,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                        ),
                      ),

                //     ? Text('image')
                Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    widget.messageItem.repliedToMessage,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: appColors.textColorBlack.withOpacity(.6),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );

  Widget imageReplyMessage({required AppColors appColors}) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: widget.messageItem.isRepliedToMyself
                  ? appColors.yellowColor
                  : appColors.textColorBlack,
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            height: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                !widget.messageItem.isRepliedToMyself
                    ? Text(
                        'You',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appColors.textColorBlack,
                          fontSize: 12,
                        ),
                      )
                    : Text(
                        widget.messageItem.targetUsername,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appColors.yellowColor,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12,
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //image
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: widget.messageItem.repliedToMessage,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CupertinoActivityIndicator(
                            color: appColors.primaryColor,
                            radius: 8,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            color: appColors.redColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    //text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.camera5,
                          size: 15,
                          color: appColors.textColorBlack.withOpacity(.8),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Photo',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: appColors.textColorBlack.withOpacity(.8),
                            overflow: TextOverflow.ellipsis,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      );

  voiceReplyMessage({required AppColors appColors}) {
    final color = !widget.messageItem.isRepliedToMyself
        ? appColors.textColorBlack
        : appColors.yellowColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          height: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              !widget.messageItem.isRepliedToMyself
                  ? Text(
                      'You',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appColors.textColorBlack,
                        fontSize: 12,
                      ),
                    )
                  : Text(
                      widget.messageItem.targetUsername,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appColors.yellowColor,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 12,
                      ),
                    ),
              Row(
                children: [
                  //image
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    child: const Icon(
                      Iconsax.microphone_2,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),

                  //text
                  Text(
                    'Voice',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: appColors.textColorBlack.withOpacity(.8),
                      overflow: TextOverflow.ellipsis,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
