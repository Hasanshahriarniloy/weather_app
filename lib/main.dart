import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/pages/settings_page.dart';
import 'package:weather_app/pages/weather_homepage.dart';
import 'package:weather_app/providers/weather_provider.dart';


void main() {
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context)=>WeatherProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Merriweather',
          primarySwatch: Colors.blue,
        ),
        home:WeatherHomePage(),

        routes: {
          WeatherHomePage.routeName:(context)=>WeatherHomePage(),
          SettingsPage.routeName:(context)=>SettingsPage(),



        },
      ),
    );
  }
}

