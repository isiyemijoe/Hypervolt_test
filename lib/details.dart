import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hypervolt_test/static_items.dart';

class DetailsPage extends StatefulWidget {
  final BluetoothDevice connectedDevice;
  DetailsPage({Key key, this.connectedDevice}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Connected Device",
            style: TextStyle(
                color: Colors.black,
                fontFamily: "Sans",
                fontWeight: FontWeight.normal),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.black,
            ),
          )),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text(
                widget.connectedDevice.name ?? "Unknown device",
                style: TextStyle(
                  fontFamily: "Sans",
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                widget.connectedDevice.id.id,
                style: TextStyle(
                  fontFamily: "Sans",
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
