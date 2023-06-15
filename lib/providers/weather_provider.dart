import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as Http;
import 'package:weather_app/models/current_response_model.dart';
import 'package:weather_app/models/forecast_response_model.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/utils/helper_function.dart';

class WeatherProvider extends ChangeNotifier{
  CurrentResponseModel currentResponseModel = CurrentResponseModel();
  ForecastResponseModel forecastResponseModel = ForecastResponseModel();
  String errMsg = '';
  String? city;

  Future<void> getCurrentWeatherData([double lat = 0.0,double lng = 0.0]) async {
    final status = await getTempStatus();
    final unit = status ? 'imperial':'metric';
    final urlString = city ==null ? 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&units=$unit&appid=$weatherApiKey' :
    'https://api.openweathermap.org/data/2.5/weather?q=$city&units=$unit&appid=$weatherApiKey';
    try{

      final response=await Http.get(Uri.parse(urlString));
      final map = json.decode(response.body);
      if(response.statusCode==200){
        currentResponseModel = CurrentResponseModel.fromJson(map);
        print(currentResponseModel.main?.temp.toString());
        notifyListeners();

      }
      else{
        errMsg = map['message'];
        print('ERROR ERROR : $errMsg');
        notifyListeners();

      }

    }catch(error){
      throw error;

    }



  }


  Future<void> getForecastWeatherData([double lat = 0.0,double lng = 0.0]) async {
    final status = await getTempStatus();
    final unit = status ? 'imperial':'metric';
    final urlString = city ==null ? 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lng&units=$unit&appid=$weatherApiKey' :
    'https://api.openweathermap.org/data/2.5/forecast?q=$city&units=$unit&appid=$weatherApiKey';
    try{

      final response=await Http.get(Uri.parse(urlString));
      final map = json.decode(response.body);
      if(response.statusCode==200){
        forecastResponseModel = ForecastResponseModel.fromJson(map);
        notifyListeners();

      }
      else{
        errMsg = map['message'];
        print('ERROR ERROR : $errMsg');
        notifyListeners();

      }

    }catch(error){
      throw error;

    }



  }

}