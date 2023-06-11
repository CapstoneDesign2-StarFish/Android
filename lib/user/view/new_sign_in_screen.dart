import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_1/common/const/colors.dart';
import 'package:project_1/common/const/data.dart';
import 'package:project_1/common/layout/default_layout.dart';
import 'package:project_1/common/view/root_tab.dart';
import 'package:project_1/user/view/sign_in_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'new_login_screen.dart';

class Sign_inScreen extends StatefulWidget {
  static const String path = "lib/src/pages/login/login3.dart";

  const Sign_inScreen({super.key});

  @override
  State<Sign_inScreen> createState() => _Sign_inScreen();
}

class _Sign_inScreen extends State<Sign_inScreen> {
  String username = '';
  String password = '';
  String password_check = '';

  bool isPasswordMatch() {
    return password.isNotEmpty && password == password_check;
  }

  // 텍스트 필드 컨트롤러 생성
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordCheckController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dio = Dio();

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            color: Color(0xff7AA5D2),
          ),
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 28,
                  ),
                  const Text(
                    "StarFish",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 40.0,
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                    elevation: 11,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(40),
                      ),
                    ),
                    child: TextField(
                      controller: usernameController, // 컨트롤러 연결
                      onChanged: (String value) {
                        username = value;
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.black26,
                        ),
                        hintText: "Email",
                        hintStyle: TextStyle(
                          color: Colors.black26,
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: Colors.red,
                        elevation: 11,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                        ),
                      ),
                      onPressed: () async {
                        final resp = await dio.get(
                          'https://$ip/account/signin/email/api/',
                          queryParameters: {'value': username},
                        );

                        final check = resp.data;

                        if (check.toString() == 'true') {
                          print('중복');
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('중복'),
                              content: Text('중복입니다.'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    usernameController.clear(); // 컨트롤러 초기화
                                  },
                                  child: Text('확인'),
                                ),
                              ],
                            ),
                          );
                        }
                        print(resp.data);
                      },
                      child: const Text(
                        "이메일 중복 확인",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.only(left: 30, right: 30, top: 20),
                    elevation: 11,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    child: TextField(
                      onChanged: (String value) {
                        password = value;
                        if (!isPasswordMatch()) {
                          setState(() {}); // 상태 갱신
                        }
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.black26,
                        ),
                        hintText: "Password",
                        hintStyle: TextStyle(
                          color: Colors.black26,
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.only(left: 30, right: 30, top: 20),
                    elevation: 11,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    child: TextField(
                      onChanged: (String value) {
                        password_check = value;
                        if (!isPasswordMatch()) {
                          setState(() {}); // 상태 갱신
                        }
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.black26,
                        ),
                        hintText: "Password Check",
                        hintStyle: TextStyle(
                          color: Colors.black26,
                          fontSize: 18,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor:
                            isPasswordMatch() ? Colors.red : Colors.grey,
                        elevation: 11,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40.0)),
                        ),
                      ),
                      onPressed: isPasswordMatch()
                          ? () async {
                              final resp = await dio.put(
                                'https://$ip/account/signin/api/',
                                data: {
                                  'email': '$username',
                                  'password': '$password'
                                },
                              );

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => LoginThreePage(),
                                ),
                              );
                            }
                          : null,
                      child: const Text(
                        "회원 가입",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
