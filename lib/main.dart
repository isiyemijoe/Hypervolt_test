import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:hypervolt_test/details.dart';
import 'package:hypervolt_test/static_items.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool isScanning = false;
  String stringState = "Scan to find bluetooth devices";
  var _listKey = GlobalKey<AnimatedListState>();
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = [];
  List<BluetoothService> _service = [];
  int connectingIndex = -1;

  BluetoothDevice _connectedDevice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Hypervolt",
            style: TextStyle(
                color: Colors.black,
                fontFamily: "Sans",
                fontWeight: FontWeight.bold),
          ),
          leading: Image.asset(
            logo,
            height: 30,
            width: 30,
            fit: BoxFit.contain,
          )),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (devicesList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 0, 5),
                child: Text(
                  "Available devices",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: "Sans",
                      fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: devicesList.isEmpty
                  ? emptyState(stringState: stringState)
                  : AnimatedList(
                      key: _listKey,
                      initialItemCount: devicesList.length,
                      itemBuilder:
                          (BuildContext context, int index, animation) {
                        return SlideTransition(
                          position: animation.drive(Tween(
                            begin: Offset(100, 0),
                            end: Offset(0, 0),
                          )),
                          child: ListTile(
                            trailing: connectingIndex == index
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          backgroundColor: Colors.grey,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.blueGrey),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        "Connecting",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: "Sans",
                                            fontWeight: FontWeight.normal),
                                      )
                                    ],
                                  )
                                : null,
                            onTap: connectingIndex != index
                                ? () async {
                                    try {
                                      connectingIndex = index;
                                      setState(() {});
                                      await devicesList[index].connect();
                                    } catch (e) {
                                      if (e.code != 'already_connected') {
                                        throw e;
                                      }
                                      print(e);
                                    } finally {
                                      _service = await devicesList[index]
                                          .discoverServices();
                                      connectingIndex = -1;
                                      setState(() {});
                                    }
                                    _connectedDevice = devicesList[index];
                                    setState(() {});

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => DetailsPage(
                                                  connectedDevice:
                                                      _connectedDevice,
                                                )));
                                  }
                                : null,
                            title: Text(
                              devicesList[index].name == ""
                                  ? "Unknown Device"
                                  : devicesList[index].name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Sans",
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        );
                      }),
            ),
            BouncingWidget(
              onPressed: scan,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black),
                child: Center(
                  child: isScanning
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            backgroundColor: Colors.grey,
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          "Scan",
                          style: TextStyle(
                            fontFamily: "Sans",
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                          ),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  scan() async {
    devicesList.clear();
    if (!await flutterBlue.isOn) {
      showDialog(
          context: context,
          builder: (context) => GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 45),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            "Bluetooth is disabled",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Sans",
                                fontSize: 18,
                                fontWeight: FontWeight.normal),
                          )),
                    ],
                  ),
                ),
              ));
      return;
    }

    setState(() {
      isScanning = true;
    });
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        print("connected devices ${device.name}");
        _addDeviceTolist(device);
      }
    });

    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        print("available device ${result.device.name}");
        setState(() {
          _addDeviceTolist(result.device);
        });
      }
    });

    flutterBlue.stopScan();
    await Future.delayed(Duration(seconds: 4));

    isScanning = false;
    if (devicesList.isEmpty) stringState = "No compatible BLE device found";
    setState(() {});
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        print(device.name);

        devicesList.add(device);
        print(devicesList.indexOf(device));
      });
      if (devicesList.length >= 1) print(devicesList.length);
    }
  }
}

class emptyState extends StatelessWidget {
  const emptyState({
    Key key,
    @required this.stringState,
  }) : super(key: key);

  final String stringState;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: RichText(
      text: TextSpan(
        text: "${stringState.substring(0, stringState.indexOf(" "))}",
        style: TextStyle(
          fontFamily: "Sans",
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        children: [
          TextSpan(
            text: "${stringState.substring(stringState.indexOf(" "))} ",
            style: TextStyle(
              fontFamily: "Sans",
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
        ],
      ),
    ));
  }
}
