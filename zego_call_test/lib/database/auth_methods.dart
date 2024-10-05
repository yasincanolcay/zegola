import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_call_test/database/storage_methods.dart';
import 'package:zego_call_test/models/user_model.dart';

class AuthMethods {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> createNewAccount(
    String email,
    String password,
    String username,
    Uint8List? image,
  ) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      String picture =
          "https://cdn-icons-png.flaticon.com/128/3177/3177440.png";
      if (image != null) {
        picture = await StorageMethods()
            .uploadImageToStorage("ProfilePictures", image);
      }
      UserModel userModel = UserModel(
        username: username,
        picture: picture,
        uid: cred.user!.uid,
        createdDate: DateTime.now(),
      );
      await _fire.collection("users").doc(cred.user!.uid).set(userModel.toJson());
      return true;
    } catch (err) {
      return false;
    }
  }
  Future<void> logOut()async{
    await _auth.signOut();
  }
}
