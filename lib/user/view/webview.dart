import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../../common/view/root_tab.dart';
import 'new_login_screen.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({required this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social login'),
        backgroundColor: fishbowl_COLOR,
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        gestureNavigationEnabled: true,
        userAgent: "random",
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        navigationDelegate: (NavigationRequest request) async {
          if (request.url == 'https://starfish.kdedevelop.xyz/index') {
            final cookies = await _webViewController.evaluateJavascript('document.cookie;');
            print('성공');
            print('Cookies: $cookies');

            String token = cookies.replaceAll('Authorization=', '');
            token = token.replaceAll('"', '');
            print(token);
            checkToken(token);
            // 원하는 작업 수행 후 WebView를 종료
            //Navigator.pop(context);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  void checkToken(String token) async {
    final dio = Dio();

    try {
      final resp = await dio.get(
        'https://$ip/account/validate',
        //http://starfish.kdedevelop.xyz:22101/test
        //token_authenfication 검증
        options: Options(
          headers: {
            'Authorization': '$token',
          },
        ),
      );

      await storage.write(
          key: ACCESS_TOKEN_KEY, value: token);
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
      print(token);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginThreePage(),
        ),
            (route) => false,
      );
    }
  }
}
