import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_1/common/const/colors.dart';
import 'package:project_1/common/const/data.dart';
import 'package:project_1/common/layout/default_layout.dart';
import 'package:project_1/common/view/root_tab.dart';
import 'package:project_1/user/view/login_screen.dart';

import '../../common/component/custom_text_form_field.dart';
import 'new_login_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  State<SigninScreen> createState() => _SigninScreen();
}

class _SigninScreen extends State<SigninScreen> {
  String username = '';
  String password = '';
  String password_check = '';
  final GlobalKey<FormState> formkey = GlobalKey();

  bool isPasswordMatch() {
    return password.isNotEmpty && password == password_check;
  }

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    String errorMessage = '';

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Title(),
                  const SizedBox(height: 16.0),
                  _SubTitle(),
                  const SizedBox(height: 16.0),
                  CustomTextFormField(
                    hintText: '이메일을 입력해주세요.',
                    onChanged: (String value) {
                      username = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
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
                                },
                                child: Text('확인'),
                              ),
                            ],
                          ),
                        );
                      }
                      print(resp.data);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: PRIMARY_COLOR,
                    ),
                    child: Text('이메일 중복 확인'),
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextFormField(
                    hintText: '비밀번호를 입력해주세요.',
                    onChanged: (String value) {
                      password = value;
                      if (!isPasswordMatch()) {
                        errorMessage = '비밀번호가 일치하지 않습니다.';
                      } else {
                        errorMessage = '';
                      }
                      setState(() {}); // 상태 갱신
                    },
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextFormField(
                    hintText: '비밀번호를 다시 입력해주세요.',
                    onChanged: (String value) {
                      password_check = value;
                      if (!isPasswordMatch()) {
                        errorMessage = '비밀번호가 일치하지 않습니다.';
                      } else {
                        errorMessage = '';
                      }
                      setState(() {}); // 상태 갱신
                    },
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: isPasswordMatch()
                        ? () async {
                      final resp = await dio.put(
                        'https://$ip/account/signin/api/',
                        data: {'email': '$username', 'password': '$password'},
                      );

                      if (resp.data == 'success') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LoginThreePage(),
                          ),
                        );
                      }
                    }
                        : null,  // isPasswordMatch()의 결과에 따라 onPressed 값 설정
                    style: ElevatedButton.styleFrom(
                      primary: isPasswordMatch() ? PRIMARY_COLOR : Colors.grey,
                      onPrimary: Colors.white,
                    ),
                    child: Text(
                      '회원가입',
                    ),
                  ),
                  errorMessage.isNotEmpty
                      ? Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  )
                      : SizedBox(),
                ],
              ),
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
      '이메일과 비밀번호를 입력해서 회원가입을 진행해주세요!',
      style: TextStyle(fontSize: 16, color: BODY_TEXT_COLOR),
    );
  }
}
