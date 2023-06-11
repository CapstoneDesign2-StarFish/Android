import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../common/const/data.dart';

class ControlPage extends StatefulWidget {
  static const String path = "lib/src/pages/dashboard/dash3.dart";

  final dynamic itemData;
  final String? userId;

  ControlPage({Key? key, required this.itemData, this.userId})
      : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class SensorData {
  final DateTime date;
  final double temp;
  final double ph;

  SensorData({required this.date, required this.temp, required this.ph});
}

class _ControlPageState extends State<ControlPage> {
  late IOWebSocketChannel channel;
  String? lastFunction; // Store the last function name

  // 각 TextField의 입력값을 관리하기 위한 TextEditingController들을 선언합니다.
  final TextEditingController maxPhController = TextEditingController();
  final TextEditingController minPhController = TextEditingController();
  final TextEditingController maxWaterTempController = TextEditingController();
  final TextEditingController minWaterTempController = TextEditingController();

  bool isUpdatingImage = false;
  Timer? timer;
  Timer? _imageUpdateTimer;

  @override
  void initState() {
    super.initState();

    // 웹소켓을 초기화합니다.
    channel =
        IOWebSocketChannel.connect('ws://starfish.kdeDevelop.xyz:22102/ws');
    // channel.stream.listen((message) {
    //   // 터미널에 메시지를 출력합니다.
    //   print('Received: $message');
    // });
    channel.sink.add(
      json.encode({
        "function": "init",
        "content": {
          "userId": "${widget.userId}",
          "name": "USER",
        },
      }),
    );

    // _imageUpdateTimer = Timer.periodic(Duration(milliseconds: 500), (Timer timer) async {
    //   Uint8List? newBytes = await _loadAndDecodeImage();
    //   if (newBytes != null) {
    //     setState(() {
    //       _imageBytes = newBytes;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    // 웹소켓을 닫습니다.
    channel.sink.close();
    super.dispose();
  }

  Uint8List? _imageBytes;

  Future<Uint8List> _loadAndDecodeImage() async {
    Dio dio = new Dio();
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    var response = await await dio.get(
      'https://$ip/picture',
      queryParameters: {'fishBowlName': widget.itemData},
      options: Options(
        headers: {
          'Authorization': '$accessToken',
        },
      ),
    );
    var base64Data = response.data;
    var bytes = base64Decode(base64Data);
    return bytes;
  }

  final String avatar = '';

  final TextStyle whiteText = const TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f0f0),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(context),
          const SizedBox(height: 20.0),
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder(
              stream: channel.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (_imageBytes != null) {
                  return Image.memory(_imageBytes!);
                } else if (snapshot.hasData) {
                  final decodedData = json.decode(snapshot.data);
                  // Check if the function is 'graph'
                  if (decodedData["function"] == 'graph') {
                    final List<dynamic> graphData =
                        decodedData["content"]["graph"];
                    final List<SensorData> sensorData = graphData
                        .map((data) => SensorData(
                              date: DateTime.parse(data["date"]),
                              temp: data["temp"].toDouble(),
                              ph: data["ph"].toDouble(),
                            ))
                        .toList();

                    List<ChartData> chartData = [];
                    for (int i = 0; i < sensorData.length; i++) {
                      chartData.add(ChartData(
                        x: sensorData[i].date,
                        y: sensorData[i].temp,
                        secondSeriesYValue: sensorData[i].ph,
                      ));
                    }

                    return Container(
                      height: 300,
                      padding: const EdgeInsets.all(8.0),
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                          intervalType: DateTimeIntervalType.minutes,
                        ),
                        primaryYAxis: NumericAxis(
                          interval: 2,
                        ),
                        series: <ChartSeries>[
                          LineSeries<ChartData, DateTime>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            name: '온도',
                          ),
                          LineSeries<ChartData, DateTime>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) =>
                                data.secondSeriesYValue,
                            name: 'pH',
                          ),
                        ],
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.top,
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  } else if (decodedData["function"] == 'measure') {
                    // Get the measurement data
                    final measureData = decodedData["content"]["measure"];
                    final temp = measureData["temp"];
                    final ph = measureData["ph"];

                    // Display the data
                    return Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            height: 300.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: Colors.black,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    '수온: $temp', // Temperature 값 출력
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'pH: $ph', // pH 값 출력
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Return different widget or empty Container
                    return Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            height: 300.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: Colors.black,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Center(
                                  child: _imageBytes != null
                                      ? Image.memory(_imageBytes!)
                                      : Text(
                                          decodedData["function"] == 'init'
                                              ? '' // 'init' 함수일 경우 아무것도 출력하지 않음
                                              : decodedData[
                                                  "function"], // function에 해당하는 값 출력
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 36.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildTile(
                    color: Colors.blue,
                    icon: Icons.light,
                    title: "전등",
                    data: "light",
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildTile(
                    color: Color(0xff94FF5C),
                    icon: Icons.cleaning_services,
                    title: "청소",
                    data: "clean",
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildTile(
                    color: Colors.blue,
                    icon: Icons.sensors,
                    title: "센서",
                    data: "get_sensor",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildTile(
                    color: Color(0xff94FF5C),
                    icon: Icons.flatware,
                    title: "먹이주기",
                    data: "feed",
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildTile(
                    color: Colors.blue,
                    icon: Icons.settings,
                    title: "설정",
                    data: "setting",
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildTile(
                    color: Color(0xff94FF5C),
                    icon: Icons.bar_chart,
                    title: "그래프",
                    data: "get_graph",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildTile(
                    color: Colors.white,
                    icon: Icons.camera_alt,
                    title: "영상",
                    data: "feed",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Container _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 32.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        color: Colors.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.only(left: 32.0, right: 32.0),
            leading: Text(
              "관리",
              style: whiteText.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            trailing: IconButton(
              onPressed: () {
                Navigator.pop(context); // 이 코드를 추가합니다.
              },
              icon: Icon(Icons.close),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  GestureDetector _buildTile(
      {Color? color,
      IconData? icon,
      required String title,
      required String data}) {
    bool toggleLight = false; // 전등 상태를 나타내는 변수

    return GestureDetector(
      onTap: () async {
        if (title == "영상") {
          showDialog(
            context: context,
            builder: (_) => ImageUpdateDialog(
              onClosed: () {
                // 여기에 "닫기" 버튼이 클릭됐을 때 수행할 작업을 넣어주세요.
              },
              itemData: widget.itemData, // itemData를 ImageUpdateDialog로 전달합니다.
            ),
          );
        } else if (title == "설정") {
          _showSettingsDialog(context, data);
        } else if (title == "전등") {
          if (!toggleLight) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("전등 ON")), // "ON" 메시지를 표시합니다.
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("전등 OFF")), // "OFF" 메시지를 표시합니다.
            );
          }
          toggleLight = !toggleLight; // 상태를 토글합니다.
          sendMessage(data, null);
        } else {
          sendMessage(data, null);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        height: 100.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: color,
        ),
        child: Column(
          //    crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.black,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0, // 크기를 20.0으로 설정
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('어항 설정'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: maxPhController,
                  decoration: InputDecoration(hintText: 'maxPh'),
                ),
                TextField(
                  controller: minPhController,
                  decoration: InputDecoration(hintText: 'minPh'),
                ),
                TextField(
                  controller: maxWaterTempController,
                  decoration: InputDecoration(hintText: 'maxWaterTemp'),
                ),
                TextField(
                  controller: minWaterTempController,
                  decoration: InputDecoration(hintText: 'minWaterTemp'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                var settings = {
                  "maxPh": double.parse(maxPhController.text),
                  "minPh": double.parse(minPhController.text),
                  "maxWaterTemp": double.parse(maxWaterTempController.text),
                  "minWaterTemp": double.parse(minWaterTempController.text),
                };
                sendMessage(data, settings);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void sendMessage(String data, Map<String, double>? settings) {
    var message = {
      "function": data,
      "content": {
        "userId": widget.userId,
        "name": widget.itemData, // Use the itemData here
        if (settings != null) "setting": settings,
      },
    };
    String encodedMessage = json.encode(message);
    channel.sink.add(encodedMessage);
    print(encodedMessage);
  }
}

class ImageUpdateDialog extends StatefulWidget {
  final Function onClosed;
  final dynamic itemData;

  ImageUpdateDialog({
    Key? key,
    required this.onClosed,
    required this.itemData,
  }) : super(key: key);

  @override
  _ImageUpdateDialogState createState() => _ImageUpdateDialogState();
}

class _ImageUpdateDialogState extends State<ImageUpdateDialog> {
  Uint8List? _imageBytes;
  Uint8List? _oldImageBytes;
  Timer? _imageUpdateTimer;

  @override
  void initState() {
    super.initState();

    _imageUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      var newBytes = await _loadAndDecodeImage();
      if (newBytes != null) {
        setState(() {
          _oldImageBytes = _imageBytes;
          _imageBytes = newBytes;
        });
      }
    });
  }

  Future<Uint8List> _loadAndDecodeImage() async {
    Dio dio = new Dio();
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    var response = await await dio.get(
      'https://$ip/picture',
      queryParameters: {'fishBowlName': widget.itemData},
      options: Options(
        headers: {
          'Authorization': '$accessToken',
        },
      ),
    );
    var base64Data = response.data;
    var bytes = base64Decode(base64Data);
    return bytes;
  }

  @override
  void dispose() {
    _imageUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: double.maxFinite,
        child: _imageBytes != null
            ? AnimatedCrossFade(
                duration: const Duration(seconds: 1),
                firstChild: _oldImageBytes != null
                    ? Image.memory(
                        _oldImageBytes!,
                        fit: BoxFit.fill,
                      )
                    : Container(),
                secondChild: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.fill,
                ),
                crossFadeState: _oldImageBytes == null
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              )
            : CircularProgressIndicator(),
      ),
      actions: [
        TextButton(
          child: const Text('닫기'),
          onPressed: () {
            widget.onClosed(); // "닫기" 버튼이 클릭됐을 때 수행할 작업 실행
            Navigator.of(context).pop(); // 다이얼로그 닫기
          },
        ),
      ],
    );
  }
}

class ChartData {
  final DateTime x;
  final double y;
  final double secondSeriesYValue;

  ChartData({
    required this.x,
    required this.y,
    required this.secondSeriesYValue,
  });
}
