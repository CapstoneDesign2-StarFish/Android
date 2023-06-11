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
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/component/custom_text_form_field.dart';

final kakaoUrl = Uri.parse(
'https://kauth.kakao.com/oauth/authorize?client_id=f78a40e3747e9f78c797cfa1934027f8&redirect_uri=https://starfish.kdeDevelop.xyz/account/login/oauth/KAKAO/redirect/api/&response_type=code');
    //'https://kauth.kakao.com/oauth/authorize?client_id=f78a40e3747e9f78c797cfa1934027f8&redirect_uri=http://starfish.kdeDevelop.xyz:22101/account/login/oauth/KAKAO/redirect/api/&response_type=code');
final googleUrl = Uri.parse(
  'https://accounts.google.com/o/oauth2/v2/auth?client_id=298220959761-emsk4bm8866igsc0r3ithpiap8rua4ag.apps.googleusercontent.com&redirect_uri=https://starfish.kdeDevelop.xyz/account/login/oauth/GOOGLE/redirect/api/&response_type=code&scope=email'
);


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String username = '';
  String password = '';
  //
  // WebViewController controller = WebViewController()
  //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //   ..loadRequest(kakaoUrl);

  @override
  Widget build(BuildContext context) {
    final dio = Dio();

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // _Title(),
                // const SizedBox(height: 16.0),
                // _SubTitle(),
                // Image.asset(
                //   'asset/img/logo/fishbowl.png',
                //   width: MediaQuery.of(context).size.width / 3 * 2,
                // ),
                CustomTextFormField(
                  hintText: '이메일을 입력해주세요.',
                  onChanged: (String value) {
                    username = value;
                    storage.write(
                        key: User_email, value: username);
                  },
                ),
                const SizedBox(height: 16.0),
                CustomTextFormField(
                  hintText: '비밀번호를 입력해주세요.',
                  onChanged: (String value) {
                    password = value;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final rawString = '$username:$password';
                    final resp = await dio.post(
                      'http://$ip/account/login/api/',
                      // http://starfish.kdedevelop.xyz:22101/account/login/api/
                      data: {'email': '$username', 'password': '$password'},
                    );


                    final accessToken = resp.data;
                    await storage.write(
                        key: ACCESS_TOKEN_KEY, value: accessToken);



                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>RootTab(),
                      ),
                    );
                    print(resp.data);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: PRIMARY_COLOR,
                  ),
                  child: Text(
                    '로그인',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SigninScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                  ),
                  child: Text(
                    '회원가입',
                  ),
                ),
                TextButton(
                  onPressed: ()  {
                    // Navigator.of(context).push(
                    //   // MaterialPageRoute(
                    //   //   builder: (_) =>  WebViewWidget(
                    //   //     controller: controller,
                    //   //   ),
                    //   // ),
                    // );
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.yellow,
                  ),
                  child: Text(
                    '카카오 로그인',
                  ),
                ),
                TextButton(
                  onPressed: ()  {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (_) =>  WebViewWidget(
                    //       controller: controller,
                    //     ),
                    //   ),
                    // );
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    '구글 로그인',
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

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '환영합니다!',
      style: TextStyle(
          fontSize: 34, fontWeight: FontWeight.w500, color: Colors.black),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '이메일과 비밀번호를 입력해서 로그인 해주세요!',
      style: TextStyle(fontSize: 16, color: BODY_TEXT_COLOR),
    );
  }
}
