import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../../main.dart';
import 'control.dart';
import 'package:web_socket_channel/io.dart';

class DashboardThreePage extends StatefulWidget {
  static const String path = "lib/src/pages/dashboard/dash3.dart";

  DashboardThreePage({super.key});

  @override
  State<DashboardThreePage> createState() => _DashboardThreePageState();
}

class _DashboardThreePageState extends State<DashboardThreePage> {
  final String avatar = '';
  //late IOWebSocketChannel channel;
  final TextStyle whiteText = const TextStyle(color: Colors.white);
  late Future<String?> useridFuture;

  @override
  void initState() {
    super.initState();
    checkToken();
    fetchUsername();
    // 웹소켓을 초기화합니다.
  //  channel = IOWebSocketChannel.connect('ws://starfish.kdeDevelop.xyz:22102/ws');
    // 웹소켓 스트림에 리스너를 추가합니다.
    // channel.stream.listen((message) {
    //   // 터미널에 메시지를 출력합니다.
    //   print('Received: $message');
    // });
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
      var data = jsonDecode(resp.data); // JSON 문자열을 Map으로 변환
     // print(data['id']);
      return data['id'];
    }
  }


  Future<List<dynamic>> checkToken() async {
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    final dio = Dio();
    List<dynamic> data = [];
    try {
      final resp = await dio.get(
        'https://$ip/fish/list/api',
        options: Options(
          headers: {
            'Authorization': '$accessToken',
          },
        ),
      );
      print(resp.data);

      if (resp.data is String) {
        data = json.decode(resp.data);
      } else {
        data = resp.data;
      }
      // 필터링
      data = data.where((element) => element != "USER").toList();

    } catch (e) {
      print(e);
    }

    return data;
  }

  @override
  void dispose() {
    // 웹소켓을 닫습니다.
   // channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f0f0),
      body: _buildBody(context),
    );
  }

  List<String> aquariumList = [];

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: checkToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(),
                const SizedBox(height: 20.0),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "어항",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                ),
                // Add a loading indicator instead of the cards.
                Center(child: CircularProgressIndicator()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                const SizedBox(height: 16.0),
                const SizedBox(height: 20.0),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Error occurred
        } else if (snapshot.hasData) {
          List<dynamic> data = snapshot.data ?? [];
          // Add "어항추가" card to the data list
          data.add("어항 추가");

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(),
                const SizedBox(height: 20.0),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    "어항",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                ),
                ...data.asMap().entries.map((entry) {
                  int index = entry.key;
                  dynamic item = entry.value;
                  return _buildCard(index, item);
                }).toList(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                const SizedBox(height: 16.0),
                const SizedBox(height: 20.0),
              ],
            ),
          );
        } else {
          return CircularProgressIndicator(); // Data is loading or null
        }
      },
    );
  }

  Widget _buildCard(int index, dynamic itemData) {
    if (itemData == "어항 추가") {
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(10.0),
        child: Card(
          elevation: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20), // Added SizedBox to create spacing
              Text(
                itemData.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 20), // Added SizedBox to create spacing
              IconButton(
                iconSize: 40.0, // Increased icon size
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.blue,
                ),
                onPressed: () async {
                 // channel.sink.close();
                  showAddDialog();
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(10.0),
        child: Card(
          elevation: 4,
          child: Stack(
            alignment: Alignment.center, // 가운데 정렬을 위한 코드
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center, // Column 내부 아이템들 중앙 정렬
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'asset/img/logo/fishbowl.png',
                    width: 200,
                    height: 120,
                  ),
                  Text(itemData.toString()),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      // channel.sink.close();
                      final userId = await fetchUsername();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ControlPage(itemData: itemData, userId: userId),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Positioned(
                right: 8.0,
                top: 8.0,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    // "X" 버튼을 눌렀을 때 수행할 동작을 여기에 작성하세요.
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void showAddDialog() {
    String aquariumName = '';
    String ipAddress = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('어항 정보 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  aquariumName = value;
                },
                decoration: InputDecoration(
                  labelText: '어항 이름',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  ipAddress = value;
                },
                decoration: InputDecoration(
                  labelText: 'IP 주소',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('추가'),
              onPressed: () async {
                final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
                final dio = Dio();

                final resp = await dio.post(
                  'http://$ipAddress/setting/user',
                  data: accessToken,
                );

                final resp2 = await dio.get(
                  'http://$ipAddress/setting/name',
                  queryParameters: {'name': aquariumName},
                );

                final resp3 = await dio.get(
                  'http://$ipAddress/websocket/connect',
                );

                Navigator.of(context).pop();
                addAquarium(aquariumName);
              },
            ),
          ],
        );
      },
    );
  }


  void addAquarium(String name) {
    setState(() {
      // Add the aquarium name to the list
      aquariumList.add(name);
    });
  }

  Container _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 32.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        color: fishbowl_COLOR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20.0),
          ListTile(
            title: Text(
              "어항 관리",
              style: whiteText.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 30.0),
            ),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              "",
              style: whiteText.copyWith(
                fontSize: 5.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
