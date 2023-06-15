import 'dart:core';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/pages/settings_page.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/utils/helper_function.dart';

class WeatherHomePage extends StatefulWidget {
 static const String routeName = '/home';

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late WeatherProvider _provider;
  bool _isInit = true;
  bool _isLoading = true;


  @override
  void didChangeDependencies() {
    if(_isInit){
      _provider = Provider.of<WeatherProvider>(context);
      _getData();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _getData()async{
    _determinePosition().then((position)async{
     await  _provider.getCurrentWeatherData(position.latitude,position.longitude);
     await  _provider.getForecastWeatherData(position.latitude,position.longitude);
     setState(() {
       _isLoading = false;
     });

    });


  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location),
            onPressed: (){
              _provider.city = null;
              _getData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: (){
              showSearch(context: context, delegate:_CitySearchDelegate()).then((city){
                print(city);

               if(city != null && city.isNotEmpty){
                 _provider.city = city;
                 _provider.getCurrentWeatherData();
                 _provider.getForecastWeatherData();

               }
              } );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator
            .pushNamed(context, SettingsPage.routeName).then((_){
              _getData();

            }),
          ),
        ],
        ),

      body: _isLoading ? Center(child: CircularProgressIndicator(),) :
      ListView(
        children: [
          Text('${_provider.currentResponseModel.name},${_provider.currentResponseModel.sys!.country}',style: TextStyle(fontSize: 25),),
          Text(getFormattedDate(_provider.currentResponseModel.dt!,'EEE,MMM dd,yyyy',),style: TextStyle(fontSize: 25),),
          Text('${_provider.currentResponseModel.main!.temp!.round()}\u00B0',style: TextStyle(fontSize: 80),),
          Text('Feels like:  ${_provider.currentResponseModel.main!.feelsLike}\u00B0',style: TextStyle(fontSize: 20),),
          Row(
            children: [
              Image.network('$icon_Prefix${_provider.currentResponseModel.weather![0].icon}$icon_Suffix',width: 100,height: 100,),
              Text(_provider.currentResponseModel.weather! [0].description!,style: TextStyle(fontSize: 20),)
            ],
          ),
          Column(
            children: _provider.forecastResponseModel.list!.map((forecast) => Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(getFormattedDate(forecast.dt!, 'EEE HH:mm')),
                  subtitle: Text('Max:${forecast.main!.tempMax!.round()},Min:${forecast.main!.tempMin!.round()}\u00B0'),


                ),
              ),
            )).toList(),
          )
        ],
      ),

    );
  }




  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void _convertCityToLatLng(String city) async{
    final locationList = await locationFromAddress(city);
    if(locationList != null && locationList.isNotEmpty){
      final lat = locationList.first.latitude;
      final lng = locationList.first.longitude;
      _provider.getCurrentWeatherData(lat, lng);
    }

  }
}

class _CitySearchDelegate extends SearchDelegate<String>{

  @override
  List<Widget>? buildActions(BuildContext context) {
  return<Widget> [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: (){
        query = '';
      },
    )
  ];
  }

  @override
  Widget? buildLeading(BuildContext context) {

      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: (){
          close(context, query);
        },
      );


  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      title: Text(query),
      leading: const Icon(Icons.search),
      onTap: (){
        close(context, query);
      },
    );

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggetionList = query == null ? cities :
        cities.where((city) => city.toLowerCase().startsWith(query.toLowerCase())).toList();
    return ListView.builder(
        itemCount: suggetionList.length,
        itemBuilder:(context,index)=> ListTile(
          onTap: (){
            close(context, suggetionList[index]);
          },
          title: Text(suggetionList[index]),
        )
    );

  }



}
