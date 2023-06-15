import 'package:flutter/material.dart';
import 'package:weather_app/utils/helper_function.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';


  @override
  State<SettingsPage> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  bool _isOn = false;

  @override
  void initState() {
    getTempStatus().then((value){
      setState(() {
        _isOn = value;
      });
    } );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar
        (title: const Text('Settings'),
      ),
      body:ListView(
        padding: const EdgeInsets.all(8),
        children: [
          SwitchListTile(
            value: _isOn,
            onChanged: (value){
              setState(() {
                _isOn = value;
              });
              setTempStatus(value);
            },
            title: const Text('Show temperature in Fahrenheit'),
            subtitle: const Text('Default is Celsius'),

          )
        ],
      )
    );
  }
}

