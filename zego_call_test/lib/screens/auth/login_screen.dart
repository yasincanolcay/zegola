import 'package:flutter/material.dart';
import 'package:zego_call_test/database/auth_methods.dart';
import 'package:zego_call_test/screens/auth/sign_in_screen.dart';
import 'package:zego_call_test/screens/dashboard.dart';
import 'package:zego_call_test/utils/constant.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isHiddenPassword = true;
  bool isLoading = false;

  void login() async {
    if (_mailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      bool response = await AuthMethods()
          .login(_mailController.text, _passwordController.text);
      if (response) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const Dashboard(),
              ),
              (route) => false);
        }
      } else {
        if (mounted) {
          showSnackBar("Bir hata oluştu, tekrar deneyin!", context);
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _mailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  "assets/icons/playstore.png",
                  width: 100,
                  height: 100,
                ),
                const Text(
                  "ZEGOLA CALL",
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
                  onPressed: login,
                  child: !isLoading
                      ? const Text(
                          "Giriş Yap",
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
                          builder: (context) => const SignInScreen(),
                        ),
                        (route) => false);
                  },
                  child: const Text(
                    "Hesap Oluştur",
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
