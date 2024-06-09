import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'package:robot_app/src/ble.dart';
// import 'package:robot_app/src/blue_tooth_classic.dart';
import 'package:robot_app/src/compass.dart';
import 'package:robot_app/src/map.dart';
import 'package:robot_app/src/provider/bluetooth_provider.dart';
import 'package:robot_app/src/stt/simple_stt.dart';
import 'package:robot_app/src/stt/speach_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeBodyWidget extends StatefulWidget {
  const HomeBodyWidget({super.key});

  @override
  State<HomeBodyWidget> createState() => _HomeBodyWidgetState();
}

class _HomeBodyWidgetState extends State<HomeBodyWidget> {
  String _currentTime = DateTime.now().toIso8601String();

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now().toIso8601String();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Text(
            'Current Time: $_currentTime',
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text(
              'Move AGV',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          ElevatedButton(
            onPressed: () => _showFavoritesMenu(context),
            child: const Text(
              'Favorites',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          ElevatedButton(
            onPressed: () => _makeCall('01012345678'),
            child: const Text('Call',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          ),
          ElevatedButton(
            // Implement Map Viewer
            child: const Text('Map',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MapWidget()));
            },
          ),
          ElevatedButton(
            child: const Text('Camera',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            onPressed: () {},
          ),
        ]));
  }

  void _makeCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $uri');
    }
  }

  void _showFavoritesMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.music_note),
                title: Text('Option 1'),
                onTap: () => _selectOption('Option 1'),
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Option 2'),
                onTap: () => _selectOption('Option 2'),
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Option 3'),
                onTap: () => _selectOption('Option 3'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectOption(String option) {
    Navigator.pop(context);
    print('Selected option: $option');
    // Additional logic based on selection
  }
}
