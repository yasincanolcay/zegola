import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_call_test/models/call_model.dart';

class FirebaseMethods {
  final fire = FirebaseFirestore.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<bool> addMeCallRoom(Call callModel) async {
    try {
      await fire.collection("calls").doc(_uid).set(callModel.toMap());
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> deleteMeRoom(String callId) async {
    try {
      await fire.collection("calls").doc(callId).delete();
      return true;
    } catch (err) {
      return false;
    }
  }
}
