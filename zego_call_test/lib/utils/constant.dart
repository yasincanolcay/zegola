import 'package:flutter/material.dart';

const textFieldcolor = Color.fromARGB(87, 145, 145, 145);
const backgroundColor = Color.fromARGB(255, 8, 164, 255);

showSnackBar(
  String content,
  BuildContext context,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.vertical,
      content: Text(
        content,
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            fontFamily: 'poppins'),
      ),
    ),
  );
}
