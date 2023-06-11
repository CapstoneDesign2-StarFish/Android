import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_1/common/const/colors.dart';
import 'package:project_1/common/const/data.dart';
import 'package:project_1/common/layout/default_layout.dart';
import 'package:project_1/common/view/root_tab.dart';
import 'package:project_1/user/view/sign_in_screen.dart';
import 'package:project_1/user/view/webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'new_sign_in_screen.dart';

final kakaoUrl = Uri.parse(
  'https://kauth.kakao.com/oauth/authorize?client_id=f78a40e3747e9f78c797cfa1934027f8&redirect_uri=https://starfish.kdeDevelop.xyz/account/login/oauth/KAKAO/redirect/api/&response_type=code'
);
final googleUrl = Uri.parse(
  'https://accounts.google.com/o/oauth2/v2/auth?client_id=298220959761-emsk4bm8866igsc0r3ithpiap8rua4ag.apps.googleusercontent.com&redirect_uri=https://starfish.kdeDevelop.xyz/account/login/oauth/GOOGLE/redirect/api/&response_type=code&scope=email'
);


class LoginThreePage extends StatefulWidget {
  static const String path = "lib/src/pages/login/login3.dart";

  const LoginThreePage({super.key});

  @override
  State<LoginThreePage> createState() => _LoginThreePageState();
}

class _LoginThreePageState extends State<LoginThreePage> {
  String username = '';
  String password = '';

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
          ListView(
            children: <Widget>[
              SizedBox(
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(
                      height: 28,
                    ),
                    const Text("StarFish",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 40.0)),
                    Card(
                      margin: EdgeInsets.only(left: 30, right: 30, top: 30),
                      elevation: 11,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(40),
                        ),
                      ),
                      child: TextField(
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 16.0)),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(left: 30, right: 30, top: 20),
                      elevation: 11,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(40))),
                      child: TextField(
                        onChanged: (String value) {
                          password = value;
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0)),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 16.0)),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40.0))),
                        ),
                        onPressed: () async {
                          print(username);
                          print(password);
                          final rawString = '$username:$password';
                          final resp = await dio.post(
                            'https://$ip/account/login/api/',
                            // http://starfish.kdedevelop.xyz:22101/account/login/api/
                            data: {'email': '$username', 'password': '$password'},
                          );

                          final accessToken = resp.data;
                          await storage.write(
                              key: ACCESS_TOKEN_KEY, value: accessToken);
                          await storage.write(
                              key: User_email, value: username);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RootTab(),

                            ),
                          );
                          print(resp.data);
                        },
                        child: const Text("로그인",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("보유 계정이 없습니까?"),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.indigo,
                          ),
                          child: const Text("회원가입"),
                          onPressed: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => Sign_inScreen(),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                    const Text("비밀번호 찾기", style: TextStyle(color: Colors.white))
                  ],
                ),
              ),
              const SizedBox(
                height: 54,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    const Text("타사 계정으로 로그인"),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: <Widget>[
                        const SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              backgroundColor: Color(0xfff0f0f0),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(40)),
                              ),
                            ),
                            child: const Text("Google"),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => WebViewPage(url: googleUrl.toString()),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.yellow,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(40)),
                              ),
                            ),
                            child: const Text("Kakao"),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WebViewPage(url: kakaoUrl.toString()),
                                ),
                              );

                              if (result != null) {
                                // 가져온 값을 사용하세요
                                print('Tag Value: $result');
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20.0,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
