import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../common/const/colors.dart';
import '../../common/const/colors.dart';
import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import 'new_login_screen.dart';
//import 'package:flutter_ui_challenges/core/presentation/res/assets.dart';

class SettingsThreePage extends StatefulWidget {
  static const String path = "lib/src/pages/settings/settings3.dart";

  SettingsThreePage({super.key});

  @override
  State<SettingsThreePage> createState() => _SettingsThreePageState();
}

class _SettingsThreePageState extends State<SettingsThreePage> {
  late Future<String?> usernameFuture;
  @override
  void initState() {
    super.initState();
    usernameFuture = fetchUsername();
  }

  Future<String?> fetchUsername() async {
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final dio = Dio();

    final resp = await dio.get(
      'https://$ip/account/user/info/api/',
      options: Options(
        headers: {
          'Authorization': '$accessToken',
        },
      ),
    );
    print(resp.data);

    // "data" 필드가 String 타입이라고 가정
    if (resp.data is String) {
      var data = jsonDecode(resp.data);  // JSON 문자열을 Map으로 변환
      return data['name'];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  final TextStyle headerStyle = TextStyle(
    color: Colors.grey.shade800,
    fontWeight: FontWeight.bold,
    fontSize: 20.0,
  );

  final Future<String?> emailFuture = storage.read(key: User_email);

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    return Scaffold(
      backgroundColor: Color(0xfff0f0f0),
      appBar: AppBar(
        backgroundColor: fishbowl_COLOR,
        title: SizedBox(
          child: const Text(
            '프로필',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              " 계정",
              style: headerStyle,
            ),
            const SizedBox(height: 10.0),
            Card(
              elevation: 0.5,
              margin: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
              ),
              child: Column(
                children: <Widget>[
                  FutureBuilder<String?>(
                    future: usernameFuture,
                    builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          leading: CircleAvatar(),
                          title: Text('Loading...'),
                        );
                      } else {
                        if (snapshot.hasError)
                          return Text('Error: ${snapshot.error}');
                        else
                          return ListTile(
                            leading: CircleAvatar(),
                            title: Text('${snapshot.data}'),
                          );
                      }
                    },
                  ),
                  _buildDivider(),
                ],
              ),
            ),
            const SizedBox(height: 320),

            Card(
              margin: const EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text("로그아웃"),
                onTap: () async {
                  final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
                  final resp = await dio.get(
                    'https://$ip/account/logout/api/',
                    options: Options(
                      headers: {
                        'Authorization': '$accessToken',
                      },
                    ),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LoginThreePage(),
                    ),
                  );
                  await storage.deleteAll();
                  print(accessToken);
                  print(resp.data);
                },
              ),
            ),
            const SizedBox(height: 60.0),
          ],
        ),
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade300,
    );
  }
}
