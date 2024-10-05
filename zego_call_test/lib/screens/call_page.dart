// ignore_for_file: use_build_context_synchronously
// Flutter imports:
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zego_call_test/database/firebase_methods.dart';
import 'package:zego_call_test/database/players_methods.dart';
import 'package:zego_call_test/widgets/common.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatefulWidget {
  const CallPage({
    Key? key,
    required this.callId,
    required this.username,
    required this.uid,
  }) : super(key: key);
  final String callId;
  final String username;
  final String uid;

  @override
  State<StatefulWidget> createState() => CallPageState();
}

class CallPageState extends State<CallPage> {
  AudioPlayerMethods players = AudioPlayerMethods();
  Timer? callTimer;
  int totalCallSecond = 60;
  bool showAlert = false;
  void endCall() async {
    bool response = await FirebaseMethods().deleteMeRoom(widget.callId);
    if (response) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (totalCallSecond > 0) {
          totalCallSecond--;
        }

        if (totalCallSecond > 0 && totalCallSecond <= 10) {
          setState(() {
            showAlert = true;
          });
          players.playAudio(
              "https://cdn.pixabay.com/audio/2024/08/05/audio_20e4b8b7b8.mp3",
              true);
        }
        if (totalCallSecond == 0) {
          players.stopPlayer();
          callTimer!.cancel();
          endCall();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    players.stopPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAlert
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.red,
              leading: const Icon(
                Icons.call_end,
              ),
              title: Text(
                "Kalan Süre: $totalCallSecond",
                style: const TextStyle(
                  fontFamily: "poppins",
                  color: Colors.white,
                ),
              ),
            )
          : null,
      body: WillPopScope(
        onWillPop: () async {
          return await Future.value(false);
        },
        child: SafeArea(
          child: ZegoUIKitPrebuiltCall(
            appID: 598638491,
            /*input your AppID*/
            appSign:
                "e456bc0ab8fb0644b0e13a9568ffabcf0c26e8714c8fac68c39efece9f001d4f" /*input your AppSign*/,
            userID: widget.uid,
            userName: widget.username,
            callID: widget.callId,
            onDispose: () {},
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()

              /// support minimizing
              ..topMenuBarConfig =
                  ZegoTopMenuBarConfig(isVisible: true, buttons: [
                ZegoMenuBarButtonName.toggleMicrophoneButton,
              ])
              ..avatarBuilder = customAvatarBuilder
              ..onHangUp = () {
                endCall();
              }
              ..turnOnCameraWhenJoining = false
              ..onOnlySelfInRoom = (context) {
                endCall();
              },
          ),
        ),
      ),
    );
  }
}
