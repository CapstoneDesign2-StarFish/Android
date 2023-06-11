import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project_1/common/const/data.dart';
import 'package:project_1/common/layout/default_layout.dart';
import 'package:project_1/common/view/root_tab.dart';
import 'package:project_1/user/view/login_screen.dart';
import 'package:web_socket_channel/io.dart';

import '../../user/view/new_login_screen.dart';
import '../const/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // late IOWebSocketChannel channel;
  @override
  void initState() {
    super.initState();
    //deleteToken();
    //channel = IOWebSocketChannel.connect('ws://starfish.kdeDevelop.xyz:22102/ws');
    checkToken();
  }
  //
  // @override
  // void dispose() {
  //   // 웹소켓을 닫습니다.
  //   channel.sink.close();
  //   super.dispose();
  // }

  void deleteToken() async {
    await storage.deleteAll();
  }

  void checkToken() async {
    // final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final username = await storage.read(key: User_email);
    final dio = Dio();

    try {
      final resp = await dio.get(
        'https://$ip/account/validate',
        //http://starfish.kdedevelop.xyz:22101/test
        //token_authenfication 검증
        options: Options(
          headers: {
            'Authorization': '$accessToken',
          },
        ),
      );

      print('->main_page');
      print(resp.data);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => RootTab(),
        ),
        (route) => false,
      );
    } catch (e) {
      print('->login_page');
      print(accessToken);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginThreePage(),
        ),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        backgroundColor: fishbowl_COLOR,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'asset/img/logo/starfish제목.PNG',
                //width: MediaQuery.of(context).size.width - 50,
                width: 300, height: 120
              ),
              const SizedBox(height: 12.0),
              Image.asset(
                  'asset/img/logo/starfish어항.PNG',
                  //width: MediaQuery.of(context).size.width - 50,
                  width: 300, height: 100
              ),
              // const SizedBox(height: 16.0),
              // Text(
              //   'Starfish',
              //   style: TextStyle(
              //       fontSize: 34,
              //       fontWeight: FontWeight.w500,
              //       color: Colors.black),
              // ),
              const SizedBox(height: 60.0),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ));
  }
}
