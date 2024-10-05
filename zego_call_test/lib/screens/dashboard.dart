// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_call_test/database/auth_methods.dart';
import 'package:zego_call_test/database/firebase_methods.dart';
import 'package:zego_call_test/database/players_methods.dart';
import 'package:zego_call_test/models/call_model.dart';
import 'package:zego_call_test/screens/auth/login_screen.dart';
import 'package:zego_call_test/screens/call_page.dart';
import 'package:zego_call_test/utils/constant.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Stream<QuerySnapshot>? callStream;
  AudioPlayerMethods players = AudioPlayerMethods();
  bool isMatching = false;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String username = "";
  String picture = "";

  void endMatching() async {
    await FirebaseMethods().deleteMeRoom(uid);
  }

  void getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> userSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    username = userSnap.data()!["username"];
    picture = userSnap.data()!["picture"];
    setState(() {});
  }

  void startMatching(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> snap,
  ) async {
    if (snap.isEmpty) {
      Call callModel = Call(
        callerId: uid,
        callerName: username,
        callerPic: picture,
        receiverId: "",
        receiverName: "",
        receiverPic: "",
        callId: uid,
        hasDialled: false,
      );
      await FirebaseMethods().addMeCallRoom(callModel);
    } else {
      if (isMatching) {
        QueryDocumentSnapshot<Map<String, dynamic>> userData =
            snap[Random().nextInt(snap.length)];

        await FirebaseFirestore.instance
            .collection("calls")
            .doc(userData.data()["callId"])
            .update({
          "receiverId": uid,
          "receiverName": username,
          "receiverPic": picture,
          "hasDialled": true,
        });
        players.stopPlayer();
        setState(() {
          isMatching = false;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CallPage(
              callId: userData.data()["callId"],
              username: username,
              uid: uid,
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    getUserData();
    callStream = FirebaseFirestore.instance
        .collection('calls')
        .where('callId', isEqualTo: uid)
        .where('hasDialled', isEqualTo: true)
        .snapshots();
    callStream!.listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['hasDialled'] == true) {
          setState(() {
            players.stopPlayer();
            isMatching = false;
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CallPage(
                callId: doc.id,
                username: username,
                uid: uid,
              ),
            ),
          );
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leadingWidth: 50,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "assets/icons/playstore.png",
          ),
        ),
        title: const Text(
          "ZEGOLA",
          style: TextStyle(
            fontFamily: "poppins",
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton(
              child: const Icon(Icons.more_vert_rounded),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () async {
                      await AuthMethods().logOut().then((value) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false);
                      });
                    },
                    child: const Text(
                      "Çıkış Yap",
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("calls")
              .where("hasDialled", isEqualTo: false)
              .where("callId", isNotEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SafeArea(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      const Text(
                        "Random Eşleş",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "poppins",
                            fontSize: 25,
                            color: Colors.white),
                      ),
                      const Spacer(
                        flex: 2,
                      ),
                      AvatarGlow(
                        animate: true,
                        glowCount: 5,
                        repeat: true,
                        glowColor: isMatching
                            ? const Color.fromARGB(255, 34, 18, 255)
                            : Colors.white,
                        child: InkWell(
                          onTap: () {
                            if (!isMatching) {
                              setState(() {
                                isMatching = true;
                                startMatching(snapshot.data!.docs);
                                players.playAudio(
                                    "https://cdn.pixabay.com/audio/2023/06/11/audio_c1a47dc34e.mp3",
                                    true);
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(60),
                          child: CircleAvatar(
                            radius: 60,
                            child: Text(
                                !isMatching ? "Eşleşme Bul!" : "Aranıyor..."),
                          ),
                        ),
                      ),
                      isMatching
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isMatching = false;
                                    players.stopPlayer();
                                    endMatching();
                                  });
                                },
                                borderRadius: BorderRadius.circular(60),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  radius: 30,
                                  child: Text("Durdur!"),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      const Spacer(
                        flex: 3,
                      ),
                      isMatching
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "Partner Bulunuyor...",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "poppins",
                                    fontSize: 25,
                                    color: Colors.white),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
