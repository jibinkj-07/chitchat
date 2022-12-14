import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chitchat/logic/cubit/internet_cubit.dart';
import 'package:chitchat/logic/database/firebase_chat_operations.dart';
import 'package:chitchat/logic/cubit/replying_message_cubit.dart';
import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/utils/message_Item.dart';
import 'package:chitchat/widgets/chat/gallery_preview_picker.dart';
import 'package:chitchat/widgets/chat/selected_image_preview.dart';
import 'package:chitchat/widgets/chat/sound_recorder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class MessageControls extends StatefulWidget {
  const MessageControls({
    Key? key,
    required this.senderId,
    required this.targetId,
    required this.scrollController,
  }) : super(key: key);
  final String senderId;
  final String targetId;
  final ScrollController scrollController;

  @override
  State<MessageControls> createState() => _MessageControlsState();
}

class _MessageControlsState extends State<MessageControls> {
  TextEditingController messageController = TextEditingController();
  final recorder = SoundRecorder();
  String message = '';
  bool isEmojiPicker = false;
  bool isVoiceMessage = false;
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isPaused = false;
  Duration duraiton = Duration.zero;
  Duration position = Duration.zero;

  int seconds = 0;
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds++;
      });
    });
  }

  void stopTimer() {
    timer!.cancel();
  }

  void resetTimer() {
    setState(() {
      seconds = 0;
      duraiton = Duration.zero;
      position = Duration.zero;
    });
  }

  @override
  void initState() {
    recorder.init();
    messageController.addListener(() {
      setState(() {
        message = messageController.text.trim();
      });
    });
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
    messageController.dispose();
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

  checkFocus() async {
    if (FocusScope.of(context).hasFocus) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        isEmojiPicker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    final bool isRecording = recorder.isRecording;
    final isTimerRunning = timer == null ? false : timer!.isActive;
    checkFocus();

    return BlocBuilder<ReplyingMessageCubit, ReplyingMessageState>(
      builder: (ctx, state) {
        return WillPopScope(
          onWillPop: () async {
            if (isEmojiPicker) {
              setState(() {
                isEmojiPicker = false;
              });
              return false;
            }
            return true;
          },
          child: isVoiceMessage
              ? voiceMessageController(
                  state: state,
                  isRecording: isRecording,
                  isTimerRunning: isTimerRunning,
                  appColors: appColors,
                )
              : textMessageController(state: state, appColors: appColors),
        );
      },
    );
  }

  Widget textMessageController({
    required ReplyingMessageState state,
    required AppColors appColors,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5, left: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: state.isReplying
                      ? replyingMessageController(
                          appColors: appColors, state: state)
                      : generalMessageController(
                          appColors: appColors, state: state),
                ),
                message.trim() == '' ? micButton() : sendButton(state: state)
              ],
            ),
          ),
          if (isEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onBackspacePressed: () {
                  if (messageController.text.isNotEmpty) {
                    messageController.text.characters.skipLast(1);
                  }
                },
                textEditingController: messageController,
                config: Config(
                  columns: 8,
                  emojiSizeMax: 32.0,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  gridPadding: EdgeInsets.zero,
                  initCategory: Category.RECENT,
                  bgColor: const Color(0xFFFFFFFF),
                  indicatorColor: appColors.primaryColor,
                  iconColor: Colors.grey,
                  iconColorSelected: appColors.primaryColor,
                  backspaceColor: appColors.primaryColor,
                  skinToneDialogBgColor: Colors.white,
                  skinToneIndicatorColor: Colors.grey,
                  enableSkinTones: true,
                  showRecentsTab: true,
                  recentsLimit: 28,
                  noRecents: const Text(
                    'No Recents',
                    style: TextStyle(fontSize: 20, color: Colors.black26),
                    textAlign: TextAlign.center,
                  ), // Needs to be const Widget
                  loadingIndicator:
                      const SizedBox.shrink(), // Needs to be const Widget
                  tabIndicatorAnimDuration: kTabScrollDuration,
                  categoryIcons: const CategoryIcons(),
                  buttonMode: ButtonMode.MATERIAL,
                ),
              ),
            )
        ],
      );

  Widget voiceMessageController({
    required ReplyingMessageState state,
    required bool isRecording,
    required bool isTimerRunning,
    required AppColors appColors,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: recordInfo(
              isRecording,
              state,
              appColors,
            ),
          ),
          stopOrSendButton(
            isRecording: isRecording,
            isTimerRunning: isTimerRunning,
            replyingMessageState: state,
          ),
        ],
      ),
    );
  }

  Widget recordInfo(
    bool isRecording,
    ReplyingMessageState state,
    AppColors appColors,
  ) {
    final color = isRecording ? AppColors().redColor : Colors.white;
    final subColor = isRecording ? Colors.white : AppColors().primaryColor;
    return Column(
      children: [
        if (state.isReplying)
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: appColors.textColorWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                )),
            child: state.parentMessageType == 'image'
                ? imageReplyPreview(
                    appColors: appColors,
                    state: state,
                    isCloseNeed: false,
                  )
                : state.parentMessageType == 'text'
                    ? textReplyPreview(
                        appColors: appColors,
                        state: state,
                        isCloseNeed: false,
                      )
                    : voiceReplyPreview(
                        appColors: appColors,
                        state: state,
                        isCloseNeed: false,
                      ),
          ),
        Material(
          color: color,
          borderRadius: state.isReplying
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0))
              : BorderRadius.circular(25.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 25,
                      width: 25,
                      child: Icon(
                        Iconsax.microphone_25,
                        color: subColor,
                        size: 22,
                      ),
                    ),
                    isPlaying
                        ? Text(
                            formatTime(position.inSeconds),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: subColor,
                            ),
                          )
                        : Text(
                            formatTime(seconds),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: subColor,
                            ),
                          ),
                  ],
                ),
                if (!isRecording)
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: appColors.primaryColor,
                        inactiveTrackColor: Colors.grey,
                        trackHeight: 3.0,
                        thumbColor: appColors.primaryColor,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8.0),
                        overlayColor: appColors.primaryColor.withOpacity(.3),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 14.0),
                      ),
                      child: Slider(
                        min: 0,
                        max: duraiton.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        activeColor: AppColors().primaryColor,
                        inactiveColor: Colors.grey,
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await audioPlayer.seek(position);
                        },
                      ),
                    ),
                  ),
                if (isRecording)
                  AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      FadeAnimatedText(
                        'Recording',
                        duration: const Duration(milliseconds: 800),
                        fadeOutBegin: .8,
                        fadeInEnd: 0.5,
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                if (!isRecording)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      playButton(isRecording),
                      const SizedBox(width: 10.0),
                      cancelButton(isRecording, state),
                    ],
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget playButton(bool isRecording) {
    final icon = isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded;
    return SizedBox(
      height: 35,
      width: 35,
      child: IconButton(
        onPressed: () async {
          if (isPlaying) {
            await audioPlayer.pause();
          } else {
            await audioPlayer.play(
              DeviceFileSource(
                  '/data/user/0/com.example.chitchat/cache/audio.aac'),
            );
          }
        },
        padding: const EdgeInsets.all(0.0),
        icon: Icon(icon),
        color: AppColors().primaryColor,
        splashRadius: 18.0,
        iconSize: 30.0,
      ),
    );
  }

  Widget cancelButton(bool isRecording, ReplyingMessageState state) => SizedBox(
        height: 25,
        width: 25,
        child: IconButton(
          onPressed: () {
            if (isPlaying) {
              audioPlayer.stop();
            }
            resetTimer();
            if (state.isReplying) {
              context.read<ReplyingMessageCubit>().clearMessage();
            }
            setState(() {
              isVoiceMessage = false;
            });
          },
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(CupertinoIcons.delete),
          color: AppColors().redColor,
          splashColor: AppColors().redColor.withOpacity(.2),
          splashRadius: 18.0,
          iconSize: 20.0,
        ),
      );

  Widget stopOrSendButton({
    required bool isRecording,
    required bool isTimerRunning,
    required ReplyingMessageState replyingMessageState,
  }) {
    final icon = isTimerRunning ? Icons.stop_rounded : Iconsax.send_1;
    return BlocBuilder<InternetCubit, InternetState>(
      builder: (context, state) {
        return FloatingActionButton(
          onPressed: () async {
            log('is timer running = $isTimerRunning');
            if (isTimerRunning) {
              stopTimer();
              recorder.toggleRercording();
            } else {
              if (state is InternetDisabled) {
                showNoInternetAlert();
              } else {
                final bloc = context.read<ReplyingMessageCubit>();
                await FirebaseChatOperations().sendVoice(
                  senderId: widget.senderId,
                  targetId: widget.targetId,
                  replyingParentMessageType:
                      replyingMessageState.parentMessageType,
                  isReplying: replyingMessageState.isReplying,
                  isRepliedToMe: replyingMessageState.isReplyingToMyMessage,
                  parentMessage: replyingMessageState.message,
                  voiceMessage:
                      File('/data/user/0/com.example.chitchat/cache/audio.aac'),
                );
                resetTimer();
                if (replyingMessageState.isReplying) {
                  bloc.clearMessage();
                }
                setState(() {
                  isVoiceMessage = false;
                });

                if (widget.scrollController.hasClients) {
                  widget.scrollController.animateTo(
                    0.0,
                    curve: Curves.easeOut,
                    duration: const Duration(seconds: 1),
                  );
                }
              }
            }
            setState(() {});
          },
          mini: true,
          backgroundColor: AppColors().primaryColor,
          child: Icon(icon),
        );
      },
    );
  }

  Widget replyingMessageController(
          {required AppColors appColors,
          required ReplyingMessageState state}) =>
      Material(
        color: appColors.textColorWhite,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(6.0),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              //reply message preview
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                // decoration: BoxDecoration(color: Colors.black),
                child: state.parentMessageType == 'image'
                    ? imageReplyPreview(
                        appColors: appColors,
                        state: state,
                        isCloseNeed: true,
                      )
                    : state.parentMessageType == 'text'
                        ? textReplyPreview(
                            appColors: appColors,
                            state: state,
                            isCloseNeed: true,
                          )
                        : voiceReplyPreview(
                            appColors: appColors,
                            state: state,
                            isCloseNeed: true,
                          ),
                //image displaying
              ),

              //controller
              Row(
                children: [
                  //emoji icon button
                  isEmojiPicker ? keyboardButton() : emojiButton(),

                  //textfield
                  Expanded(
                    child: textField(),
                  ),

                  //camera button
                  if (message.trim() == '') photoButton(),
                  const SizedBox(width: 20),
                  if (message.trim() == '') cameraButton(),
                ],
              ),
            ],
          ),
        ),
      );

  Widget textReplyPreview(
          {required AppColors appColors,
          required ReplyingMessageState state,
          required bool isCloseNeed}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //bar
          Container(
            height: 40,
            width: 5,
            decoration: BoxDecoration(
              color: state.isReplyingToMyMessage
                  ? appColors.greenColor
                  : appColors.redColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 5),
          //body
          Expanded(
            child: SizedBox(
              height: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //top
                  state.isReplyingToMyMessage
                      ? Text(
                          'You',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: appColors.greenColor,
                            fontSize: 12,
                          ),
                        )
                      : SizedBox(
                          width: 200,
                          child: Text(
                            state.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appColors.redColor,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  //bottom

                  Text(
                    state.message,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: appColors.textColorBlack,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          //cancel button
          if (isCloseNeed)
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: () {
                  context.read<ReplyingMessageCubit>().clearMessage();
                },
                icon: const Icon(Icons.close_rounded),
                color: appColors.textColorBlack,
                iconSize: 18,
                splashRadius: 20.0,
              ),
            )
        ],
      );

  Widget imageReplyPreview(
          {required AppColors appColors,
          required ReplyingMessageState state,
          required bool isCloseNeed}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //bar
          Container(
            height: 100,
            width: 5,
            decoration: BoxDecoration(
              color: state.isReplyingToMyMessage
                  ? appColors.greenColor
                  : appColors.redColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 5),
          //body
          Expanded(
            child: SizedBox(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //top
                  state.isReplyingToMyMessage
                      ? Text(
                          'You',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: appColors.greenColor,
                            fontSize: 12,
                          ),
                        )
                      : SizedBox(
                          width: 200,
                          child: Text(
                            state.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appColors.redColor,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  //bottom
                  // const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.camera5,
                            size: 15,
                            color: appColors.textColorBlack.withOpacity(.8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Photo',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: appColors.textColorBlack,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),

                      //image
                      SizedBox(
                        height: 80,
                        width: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: state.message,
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
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          //cancel button
          if (isCloseNeed)
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: () {
                  context.read<ReplyingMessageCubit>().clearMessage();
                },
                icon: const Icon(Icons.close_rounded),
                color: appColors.textColorBlack,
                iconSize: 18,
                splashRadius: 20.0,
              ),
            )
        ],
      );

  voiceReplyPreview(
      {required AppColors appColors,
      required ReplyingMessageState state,
      required bool isCloseNeed}) {
    final color =
        state.isReplyingToMyMessage ? appColors.greenColor : appColors.redColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //bar
        Container(
          height: 70,
          width: 5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 5),
        //body
        Expanded(
          child: SizedBox(
            height: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //top
                state.isReplyingToMyMessage
                    ? Text(
                        'You',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appColors.greenColor,
                          fontSize: 12,
                        ),
                      )
                    : SizedBox(
                        width: 200,
                        child: Text(
                          state.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: appColors.redColor,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 12,
                          ),
                        ),
                      ),
                //bottom
                // const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //text
                    Text(
                      'Voice',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: appColors.textColorBlack,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 10,
                      ),
                    ),

                    //image
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      child: const Icon(
                        Iconsax.microphone_2,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        //cancel button
        if (isCloseNeed)
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: () {
                context.read<ReplyingMessageCubit>().clearMessage();
              },
              icon: const Icon(Icons.close_rounded),
              color: appColors.textColorBlack,
              iconSize: 18,
              splashRadius: 20.0,
            ),
          )
      ],
    );
    ;
  }

  Widget generalMessageController(
          {required AppColors appColors,
          required ReplyingMessageState state}) =>
      Material(
        color: appColors.textColorWhite,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(6.0),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              //emoji icon button
              isEmojiPicker ? keyboardButton() : emojiButton(),

              //textfield
              Expanded(
                child: textField(),
              ),

              //camera button
              if (message.trim() == '') photoButton(),
              const SizedBox(width: 20),
              if (message.trim() == '') cameraButton(),
            ],
          ),
        ),
      );

  Widget emojiButton() => SizedBox(
        height: 25,
        width: 25,
        child: IconButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();

            await Future.delayed(
              const Duration(milliseconds: 100),
            );
            setState(() {
              isEmojiPicker = !isEmojiPicker;
            });
            //emoji picker
          },
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(Iconsax.happyemoji5),
          color: AppColors().primaryColor,
          splashRadius: 18.0,
          iconSize: 22.0,
          splashColor: AppColors().primaryColor.withOpacity(.2),
        ),
      );

  Widget keyboardButton() => SizedBox(
        height: 25,
        width: 25,
        child: IconButton(
          onPressed: () async {
            FocusScope.of(context).requestFocus();
          },
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(Iconsax.keyboard5),
          color: AppColors().primaryColor,
          splashRadius: 18.0,
          iconSize: 22.0,
          splashColor: AppColors().primaryColor.withOpacity(.2),
        ),
      );

  Widget photoButton() => SizedBox(
        height: 25,
        width: 25,
        child: IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => GalleryPreviewPicker(
                    currentUserid: widget.senderId,
                    listScrollController: widget.scrollController,
                    targetUserid: widget.targetId)));
          },
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(Iconsax.gallery5),
          color: AppColors().primaryColor,
          splashRadius: 18.0,
          iconSize: 22.0,
          splashColor: AppColors().primaryColor.withOpacity(.2),
        ),
      );

  Widget cameraButton() => SizedBox(
        height: 25,
        width: 25,
        child: IconButton(
          onPressed: () {
            pickImage();
          },
          padding: const EdgeInsets.all(0.0),
          icon: const Icon(Iconsax.camera5),
          color: AppColors().primaryColor,
          splashRadius: 18.0,
          iconSize: 22.0,
          splashColor: AppColors().primaryColor.withOpacity(.2),
        ),
      );

  Widget textField() => CupertinoTextField(
        controller: messageController,
        autofocus: true,
        minLines: 1,
        maxLines: 5,
        textCapitalization: TextCapitalization.sentences,
        placeholder: "Type message",
        clearButtonMode: OverlayVisibilityMode.editing,
        cursorColor: AppColors().primaryColor,
        decoration: const BoxDecoration(),
      );

  Widget sendButton({required ReplyingMessageState state}) =>
      BlocBuilder<InternetCubit, InternetState>(
        builder: (context, cubitState) {
          return FloatingActionButton(
            backgroundColor: AppColors().primaryColor,
            foregroundColor: Colors.white,
            mini: true,
            onPressed: () {
              if (cubitState is InternetEnabled) {
                if (state.isReplying) {
                  FirebaseChatOperations().sendMessage(
                    senderId: widget.senderId,
                    targetId: widget.targetId,
                    body: message.trim(),
                    type: 'text',
                    replyingParentMessageType: state.parentMessageType,
                    isReplyingMessage: true,
                    replyingParentMessage: state.message,
                    isReplyingToMyMessage: state.isReplyingToMyMessage,
                  );
                  context.read<ReplyingMessageCubit>().clearMessage();
                } else {
                  FirebaseChatOperations().sendMessage(
                    senderId: widget.senderId,
                    targetId: widget.targetId,
                    body: message.trim(),
                    type: 'text',
                    isReplyingMessage: false,
                    replyingParentMessage: '',
                    replyingParentMessageType: '',
                    isReplyingToMyMessage: false,
                  );
                }
                messageController.clear();
                setState(() {
                  message = '';
                });
                if (widget.scrollController.hasClients) {
                  widget.scrollController.animateTo(
                    0.0,
                    curve: Curves.easeOut,
                    duration: const Duration(seconds: 1),
                  );
                }
              } else {
                showNoInternetAlert();
              }
            },
            child: const Icon(
              Iconsax.send_1,
              size: 22,
            ),
          );
        },
      );

  Widget micButton() => FloatingActionButton(
        backgroundColor: AppColors().primaryColor,
        foregroundColor: Colors.white,
        mini: true,
        onPressed: () async {
          startTimer();
          await recorder.toggleRercording();
          setState(() {
            isVoiceMessage = true;
            if (isEmojiPicker) {
              isEmojiPicker = false;
            }
          });
        },
        child: const Icon(
          Iconsax.microphone,
          size: 22,
        ),
      );

  void pickImage() {
    FocusScope.of(context).unfocus();
    ImagePicker imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.camera).then((pickedImage) async {
      if (pickedImage == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SelectedImagePreview(
            cameraImage: File(pickedImage.path),
            currentUserid: widget.senderId,
            targetUserid: widget.targetId,
            scrollController: widget.scrollController,
          ),
        ),
      );
    });
  }

  void showNoInternetAlert() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          title: const Text(
            "No internet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Please enable Mobile data or Wifi to send message",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors().textColorBlack,
              ),
              child: const Text("Okay"),
            )
          ],
        );
      },
    );
  }
}
