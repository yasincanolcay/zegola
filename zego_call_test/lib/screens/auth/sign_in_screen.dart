import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zego_call_test/database/auth_methods.dart';
import 'package:zego_call_test/screens/auth/login_screen.dart';
import 'package:zego_call_test/utils/constant.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Uint8List? img;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isHiddenPassword = true;
  bool isLoading = false;

  void _pickPhoto() async {
    ImagePicker picker = ImagePicker();
    var pickImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      setState(() {
        var file = File(pickImage.path);
        img = file.readAsBytesSync();
      });
    }
  }

  void signIn() async {
    if (_usernameController.text.trim().isNotEmpty &&
        _mailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      bool response = await AuthMethods().createNewAccount(_mailController.text,
          _passwordController.text, _usernameController.text, img);
      if (response) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false);
        }
      } else {
        if (mounted) {
          showSnackBar("Kayıt olurken bir hata oluştu!", context);
          setState(() {
            isLoading = false;
          });
        }
      }
    } else {
      showSnackBar("Lütfen gerekli alanları doldurun!", context);
    }
  }

  @override
  void dispose() {
    _mailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false);
        return Future.value(false);
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    img == null
                        ? const CircleAvatar(
                            radius: 45,
                            child: Icon(
                              Icons.person,
                            ),
                          )
                        : CircleAvatar(
                            radius: 45,
                            backgroundImage: MemoryImage(img!),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: _pickPhoto,
                        icon: const Icon(
                          Icons.photo,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  "Hesap Oluştur",
                  style: TextStyle(
                    fontFamily: "poppins",
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: textFieldcolor,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Kullanıcı Adı",
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: textFieldcolor,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: TextFormField(
                    controller: _mailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Email Adresi",
                      prefixIcon: Icon(
                        Icons.mail,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: textFieldcolor,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: TextFormField(
                    obscureText: isHiddenPassword,
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Şifre",
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isHiddenPassword = !isHiddenPassword;
                            });
                          },
                          icon: Icon(
                            isHiddenPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        )),
                  ),
                ),
                ElevatedButton(
                  onPressed: signIn,
                  child: !isLoading
                      ? const Text(
                          "Kayıt Ol",
                          style: TextStyle(
                            fontFamily: "poppins",
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false);
                  },
                  child: const Text(
                    "Giriş Yap",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
