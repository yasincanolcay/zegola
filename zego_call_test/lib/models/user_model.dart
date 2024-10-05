import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String picture;
  final String uid;
  final DateTime createdDate;
  const UserModel({
    required this.username,
    required this.picture,
    required this.uid,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "picture": picture,
        "uid": uid,
        "createdDate":createdDate,
      };

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = (snap.data() as Map<String, dynamic>);
    return UserModel(
      username: snapshot["username"],
      picture: snapshot["picture"],
      uid: snapshot["uid"],
      createdDate: snapshot["createdDate"],
    );
  }
}
