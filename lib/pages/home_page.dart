import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_weather_app/consts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);

  Weather? _weather;
  Position? _position;
  // @override
  // void initState() {
  //   getCurrentCity();
  //   super.initState();
  //   // _wf.currentWeatherByCityName("Tokyo").then((w){
  //   //   setState(() {
  //   //     _weather = w;
  //   //   });
  //   // });
  //   _wf.currentWeatherByLocation(_position!.latitude, _position!.longitude).then( (w)
  //   {
  //       setState(() {
  //         _weather = w;
  //       });
  //   }
  //   );
  // }
  @override
void initState() {
  getCurrentCity().then((_) {
    _wf.currentWeatherByLocation(_position!.latitude, _position!.longitude).then((w) {
      setState(() {
        _weather = w;
      });
    }).catchError((error) {
      print("Error fetching weather data: $error");
    });
  });
  super.initState();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _buildUI(),
    );
  }
  Widget _buildUI() {
    if(_weather == null){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
         [
            _locationHeader(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.08,
            ),
            _dateTimeInfo(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.05,
            ),
            _weatherIcon(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.02,
            ),
            _currentTemp(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height*0.02,
            ),
            _realFeel(),
            SizedBox(
              height: MediaQuery.sizeOf(context).height*0.02,
            ),
            _extraInfo(),
         ],
         ),
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "",
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500
      ),
    );
  }
  Widget _dateTimeInfo(){
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(
            fontSize: 35,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE,").format(now),
              style: const TextStyle(
                fontWeight: FontWeight.w700
              ),
            ),
            Text(
              "  ${DateFormat("d.m.y").format(now)}",
              style: const TextStyle(
                fontWeight: FontWeight.w400
              ),
            )
          ],
        )
      ],
    );
  }
  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: 
              NetworkImage("http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),)
          ),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 25,
          ),
        )
      ],
    );
  }

Widget _currentTemp() {
  return Text(
    "${_weather?.temperature?.celsius?.toStringAsFixed(0)} °C",
    style: const TextStyle(
        color: Colors.black,
        fontSize: 35,
        fontWeight: FontWeight.w500
    ),
  );
}
Widget _realFeel() {
  return Text(
    "Real feel like : ${_weather?.tempFeelsLike?.celsius?.toStringAsFixed(0)}°C",
    style: 
    TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold
    ),
  );
}
Widget _extraInfo(){
  return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.8,
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent, borderRadius: BorderRadius.circular(20)
      ),
      padding: const EdgeInsets.all(
        8.0
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)} °C",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15
              ),
              ),
              Text("Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)} °C",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15
              ),
              )
            ],
            ),
            Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Wind: ${_weather?.windSpeed?.toStringAsFixed(0)} m/s",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15
              ),
              ),
              Text("Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15
              ),
              )
            ],
            )
        ],
      ),
    );
  }
  Future<void> getCurrentCity() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  setState(() {
    _position = position;
  });
}
}