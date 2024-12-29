import 'dart:io';

import 'package:athena_nike/constants.dart';
import 'package:athena_nike/enums/enums.dart';
import 'package:athena_nike/providers/authentication_provider.dart';
import 'package:athena_nike/providers/chat_provider.dart';
import 'package:athena_nike/utilities/global_methods.dart';
import 'package:athena_nike/widgets/message_reply_preview.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.contactUID,
    required this.contactName,
    required this.contactImage,
    required this.groupID,
  });

  final String contactUID;
  final String contactName;
  final String contactImage;
  final String groupID;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  FlutterSoundRecord? _soundRecord;
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  File? finalFileImage;
  String filePath = '';

  bool isRecording = false;
  bool isShowSendButton = false;
  bool isSendingAudio = false;
  bool isShowEmojiPicker = false;

  // Hide Emoji Container
  void hideEmojiContainer() {
    setState(() {
      isShowEmojiPicker = false;
    });
  }

  // Show Emoji Container
  void showEmojiContainer() {
    setState(() {
      isShowEmojiPicker = true;
    });
  }

  // Show Keyboard
  void showKeyboard() {
    _focusNode.requestFocus();
  }

  // Hide Keyboard
  void hideKeyboard() {
    _focusNode.unfocus();
  }

  // Toggle emoji and keyboard container
  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiPicker) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _soundRecord = FlutterSoundRecord();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _soundRecord?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Check Microphone Permission
  Future<bool> checkMicrophonePermission() async {
    bool hasPermission = await Permission.microphone.isGranted;
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      hasPermission = true;
    } else {
      hasPermission = false;
    }

    return hasPermission;
  }

  // Start Recording Audio
  void startRecording() async {
    final hasPermission = await checkMicrophonePermission();
    if (hasPermission) {
      var tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/flutter_sound.aac';
      await _soundRecord!.start(
        path: filePath,
      );
      setState(() {
        isRecording = true;
      });
    }
  }

  // Stop Recording Audio
  void stopRecording() async {
    await _soundRecord!.stop();
    setState(() {
      isRecording = false;
      isShowSendButton = true;
    });
    // Send audio message to Firestore
    sendFileMessage(
      messageType: MessageEnum.audio,
    );
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );
    // Crop image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  // Select a video file from device
  void selectVideo() async {
    File? fileVideo = await pickVideo(
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );

    popContext();

    if (fileVideo != null) {
      filePath = fileVideo.path;
      // Send video message to Firestore
      sendFileMessage(
        messageType: MessageEnum.video,
      );
    }
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(croppedFilePath) async {
    if (croppedFilePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: croppedFilePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        filePath = croppedFile.path;
        // Send image message to Firestore
        sendFileMessage(
          messageType: MessageEnum.image,
        );
      } else {}
    }
  }

  // Send Image Message to Firestore
  void sendFileMessage({required MessageEnum messageType}) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendFileMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      file: File(filePath),
      messageType: messageType,
      groupID: widget.groupID,
      onSuccess: () {
        _textEditingController.clear();
        _focusNode.unfocus();
        setState(() {
          isSendingAudio = false;
        });
      },
      onError: (error) {
        setState(() {
          isSendingAudio = false;
        });
        showSnackBar(context, error);
      },
    );
  }

  void sendTextMessage() {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendTextMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      message: _textEditingController.text,
      messageType: MessageEnum.text,
      groupID: widget.groupID,
      onSuccess: () {
        _textEditingController.clear();
        _focusNode.unfocus();
      },
      onError: (error) {
        showSnackBar(context, error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messageReply = chatProvider.messageReplyModel;
        final isMessageReply = messageReply != null;
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).cardColor,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Column(
                children: [
                  isMessageReply
                      ? const MessageReplyPreview()
                      : const SizedBox.shrink(),
                  Row(
                    children: [
                      // Emoji Button
                      IconButton(
                        onPressed: toggleEmojiKeyboardContainer,
                        icon: Icon(isShowEmojiPicker ? Icons.keyboard_alt : Icons.emoji_emotions_outlined),
                      ),
                      IconButton(
                        onPressed: isSendingAudio
                            ? null
                            : () {
                                // Show Attachment Options
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Select image from camera
                                            ListTile(
                                              leading: const Icon(Icons.camera),
                                              title: const Text('Camera'),
                                              onTap: () {
                                                selectImage(true);
                                              },
                                            ),
                                            // Select image from gallery
                                            ListTile(
                                              leading: const Icon(Icons.image),
                                              title: const Text('Gallery'),
                                              onTap: () {
                                                selectImage(false);
                                              },
                                            ),
                                            // Select a video file from device
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.video_library),
                                              title: const Text('Video'),
                                              onTap: selectVideo,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                        icon: const Icon(Icons.attachment),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _textEditingController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration.collapsed(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Type a message',
                          ),
                          onChanged: (value) {
                            setState(() {
                              isShowSendButton = value.isNotEmpty;
                            });
                          },
                          onTap: () {
                            hideEmojiContainer();
                          },
                        ),
                      ),
                      chatProvider.isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          : GestureDetector(
                              onTap: isShowSendButton ? sendTextMessage : null,
                              onLongPress:
                                  isShowSendButton ? null : startRecording,
                              onLongPressUp: stopRecording,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.deepPurple,
                                ),
                                margin: const EdgeInsets.all(5),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: isShowSendButton
                                      ? const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.white,
                                        )
                                      : const Icon(
                                          Icons.mic,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            // Show Emoji Container
            isShowEmojiPicker
                ? SizedBox(
                    height: 280,
                    child: EmojiPicker(
                      onEmojiSelected: (category, Emoji emoji) {
                        _textEditingController.text =
                            _textEditingController.text + emoji.emoji;

                        if (!isShowSendButton) {
                          setState(() {
                            isShowSendButton = true;
                          });
                        }
                      },
                      onBackspacePressed: () {
                        _textEditingController.text = _textEditingController
                            .text.characters
                            .skipLast(1)
                            .toString();
                      },
                        // config: const Config(
                        //   columns: 7,
                        //   emojiSizeMax: 32.0,
                        //   verticalSpacing: 0,
                        //   horizontalSpacing: 0,
                        //   initCategory: Category.RECENT,
                        //   bgColor: Color(0xFFF2F2F2),
                        //   indicatorColor: Colors.blue,
                        //   iconColor: Colors.grey,
                        //   iconColorSelected: Colors.blue,
                        //   progressIndicatorColor: Colors.blue,
                        //   backspaceColor: Colors.blue,
                        //   showRecentsTab: true,
                        //   recentsLimit: 28,
                        //   noRecentsText: 'No Recents',
                        //   noRecentsStyle: const TextStyle(
                        //       fontSize: 20, color: Colors.black26),
                        //   tabIndicatorAnimDuration: kTabScrollDuration,
                        //   categoryIcons: const CategoryIcons(),
                        //   buttonMode: ButtonMode.MATERIAL,
                        // ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
