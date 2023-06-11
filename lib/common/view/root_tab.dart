import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project_1/common/const/colors.dart';
import 'package:project_1/common/layout/default_layout.dart';
import 'package:project_1/restaurant/view/restaurant_screen.dart';

import '../../restaurant/view/ency_screen.dart';
import '../../restaurant/view/new_home.dart';
import '../../user/view/login_screen.dart';
import '../../user/view/new_profile.dart';
import '../../user/view/profile_screen.dart';
import '../const/data.dart';

class RootTab extends StatefulWidget {
  const RootTab({Key? key,}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;
  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(tabListener);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.removeListener(tabListener);
    super.dispose();
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return DefaultLayout(
      // title: 'Star Fish',
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          DashboardThreePage(),
          EncyScreen(),
          SettingsThreePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: BODY_TEXT_COLOR,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          controller.animateTo(index);
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.abc),
            label: '사전',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}

/*
로그아웃

child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
                    final resp = await dio.get(
                      'http://$ip/account/logout/api/',
                      //http://starfish.kdedevelop.xyz:22101/account/logout/api/
                      //token_authenfication 검증
                      options: Options(
                        headers: {
                          'Authorization': '$accessToken',
                        },
                      ),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                    );
                    await storage.deleteAll();
                    print(accessToken);
                    print(resp.data);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: PRIMARY_COLOR,
                  ),
                  child: Text(
                    '로그아웃',
                  ),
                ),
              ],
            ),



 */

/*

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () async {

                  },
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.cyanAccent,
                  ),
                  child: Text(
                    '계정 관리',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
                    final resp = await dio.get(
                      'http://$ip/account/logout/api/',
                      //http://starfish.kdedevelop.xyz:22101/account/logout/api/
                      //token_authenfication 검증
                      options: Options(
                        headers: {
                          'Authorization': '$accessToken',
                        },
                      ),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                    );
                    await storage.deleteAll();
                    print(accessToken);
                    print(resp.data);
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.cyanAccent,
                  ),
                  child: Text(
                    '로그아웃',
                  ),
                ),
              ),
            ],
          ),
 */