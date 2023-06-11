import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../common/component/custom_text_form_field.dart';
import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../component/restaurant_card.dart';
//
// class EncyScreen extends StatelessWidget {
//   const EncyScreen({Key? key}) : super(key: key);

class EncyScreen extends StatefulWidget {
  const EncyScreen({Key? key}) : super(key: key);
  static const String path = "lib/src/pages/lists/list2.dart";

  @override
  _EncyScreenState createState() => _EncyScreenState();
}

class _EncyScreenState extends State<EncyScreen> {
  final TextStyle dropdownMenuItem =
      const TextStyle(color: Colors.black, fontSize: 18);
  String search_value = '';
  String Content = '';

  final primary = const Color(0xff696b9e);
  final secondary = const Color(0xfff29a94);
  List<Fish> fishList = [];

  //final info_url = 'http://starfish.kdedevelop.xyz:22101/encyclopedia/information';

  Future<void> search_data() async {
    print(search_value);
    print('https://$ip/encyclopedia/search/'+'$search_value',);
    final resp = await dio.get(
      'https://$ip/encyclopedia/search/'+'$search_value',
      //queryParameters: {'name': search_value},
    );

    print(resp.data);
// JSON 데이터를 문자열로 가정
    String responseData = resp.data;
    List<dynamic> jsonList = jsonDecode(responseData);
    setState(() {
      fishList.clear();
      jsonList.forEach((json) {
        Fish fish = Fish.fromJson(json);
        fishList.add(fish);
      });
    });
    // 이제 fishList에 데이터가 저장되었습니다.
  }

  Future<void> info_data(String fishName, int id) async {
    final resp = await dio.get(
      'https://$ip/encyclopedia/info/'+'$id',
      //queryParameters: {'id': id},
    );
    print(resp.data);
    String responseData = resp.data;
    // JSON 데이터 파싱
    Map<String, dynamic> data = json.decode(responseData);
// "content" 값 가져오기
    String content = data['content'];
// content 값 출력
    Content = content;
    showFishDialog(fishName,id);
  }

  void showFishDialog(String name,int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fish Name : $name'),
          content: Text('$Content'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  final dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 170),
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: ListView.builder(
                  itemCount: fishList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Fish fish = fishList[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 32.0),
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('asset/img/logo/starfish어항.PNG'),
                          //child: Text(fish.fishName[0]),
                        ),
                        title: Text(
                          fish.fishName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        //subtitle: Text('ID: ${fish.id.toString()}'),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () async {
                          info_data(fish.fishName,fish.id);
                          // ListTile을 클릭했을 때 수행할 작업
                          //showFishDialog(fish.fishName,fish.id);
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: fishbowl_COLOR,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: const Icon(
                      //     Icons.menu,
                      //     color: Colors.white,
                      //   ),
                      // ),
                      const Text(
                        "백과사전",
                        style: TextStyle(color: Colors.white, fontSize: 28),
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: const Icon(
                      //     Icons.filter_list,
                      //     color: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 110,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Material(
                        elevation: 5.0,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        child: TextField(
                          onChanged: (String value) {
                            search_value = value;
                          },
                          // 입력 완료(엔터키)시 동작 설정
                          onSubmitted: (String value) async {
                            await search_data();
                          },
                          cursorColor: Theme.of(context).primaryColor,
                          style: dropdownMenuItem,
                          decoration: InputDecoration(
                              hintText: "검색",
                              hintStyle: TextStyle(color: Colors.black38, fontSize: 16),
                              prefixIcon: Material(
                                elevation: 0.0,
                                borderRadius: BorderRadius.all(Radius.circular(40)),
                                child: IconButton(
                                  onPressed: () async {
                                    await search_data();
                                  },
                                  icon: const Icon(Icons.search),
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 13)),
                        )

                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Fish {
  final String fishName;
  final int id;

  Fish({required this.fishName, required this.id});

  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      fishName: json['fishName'],
      id: json['fishNumber'],
    );
  }

  @override
  String toString() {
    return 'Fish{fishName: $fishName, id: $id}';
  }
}
