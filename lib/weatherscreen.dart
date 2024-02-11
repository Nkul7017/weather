import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather/additioninformation.dart';
import 'package:weather/hourlyforecastitem.dart';
import 'package:http/http.dart' as http;


class WeatherScreen extends StatefulWidget{
const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
Future<Map<String,dynamic>> getCurrentWeather() async{
  String cityname='London';
  String countrycode='uk';
  try{
 final res=await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityname,$countrycode&appid=10caf887de116872dbc0aa49c6d74d15'));
  final data=jsonDecode(res.body);
  if(data['cod'] != 200)
  {
    throw data['message'];
  }
   return data;
  // data['main']['temp'];
  }
  catch(e){
    
    throw e.toString();
  }
}
@override
Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      actions: [
        IconButton(onPressed:(){
          debugPrint("refresh");
        }, icon:const Icon(Icons.refresh))
      ],
      title: const Text('Weather App', 
      style:TextStyle(
        fontWeight: FontWeight.bold,
      ) ,),
    ),
    body:FutureBuilder(
      future:getCurrentWeather() ,
      builder: (context, snapshot){

      if(snapshot.connectionState==ConnectionState.waiting)
      { return const Center(child:  CircularProgressIndicator.adaptive());}
      else if(!snapshot.hasError) 
      {
        final data=snapshot.data!;
        print(data);
        final currentTemp=data['main']['temp'];
        final sky=data['weather'][0]['main'];
        final pressure=data['main']['pressure'];  
        final wind=data['wind']['speed'];  
        final humidity=data['main']['humidity'];  
        return Padding(
        padding:const  EdgeInsets.all(16.0),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(
            width: double.infinity,
            // height: 250,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
              ),
              elevation: 10,
              child:ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter:ImageFilter.blur(
                    sigmaX: 10,sigmaY: 10
                  ),
                  child:  Padding(
                    padding:const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('$currentTemp K',
                        style:const TextStyle(
                          fontSize: 32,
                          fontWeight:FontWeight.bold 
                        ),
                        ),
                       const SizedBox(height: 16),
                        Icon(sky=='Clouds'||sky=='Rain'?Icons.cloud:Icons.sunny,
                        size: 64,
                        ),
                       const SizedBox(height: 16),
                        Text(
                          sky,
                        style:const TextStyle(
                          fontSize: 20
                        ),
                        )
                      ],
                    ),
                  )
                ),
              ),
            ),
          ),
         const SizedBox(height: 20),
         const Text('Weather Forecast',
         style: TextStyle(
          fontSize: 24,
          fontWeight:FontWeight.bold 
         ),),
         
         const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
            children: [
                  HourlyForecastItem(time:'09:00',temperature: '300',icon:Icons.cloud),
                  HourlyForecastItem(time:'03:00',temperature: '275',icon:Icons.sunny),
                  HourlyForecastItem(time:'09:00',temperature: '301',icon:Icons.cloud),
                  HourlyForecastItem(time:'03:00',temperature: '275',icon:Icons.sunny),
            ],
                   ),
          ),
          const SizedBox(height: 20),
         const SizedBox(height: 20),
         const Text('Additional Information',
         style: TextStyle(
          fontSize: 24,
          fontWeight:FontWeight.bold 
         ),),
         const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 AdditionalInformation(icon:Icons.water_drop,label:'Humidity',value:pressure.toString()),
                 AdditionalInformation(icon:Icons.air,label:'Wind Speed',value:wind.toString()),
                 AdditionalInformation(icon:Icons.beach_access,label:'Pressure',value:humidity.toString()),
                  
              ],
            ),
          ]
        ),
      );} else {return Center(child: Text(snapshot.error.toString()));}}
    ),
  );
}
}

