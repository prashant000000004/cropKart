import 'dart:convert';
import 'package:cropkart/ApiKey.dart';
import 'package:cropkart/src/pages/Home_pages/Farmers_HomeScreen/weather_pages/CloudsDay.dart';
import 'package:cropkart/src/pages/Home_pages/Farmers_HomeScreen/weather_pages/Rainyday.dart';
import 'package:cropkart/src/pages/Home_pages/Farmers_HomeScreen/weather_pages/SunnyDay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'ApiModels/Apimodel.dart';
import 'ApiModels/GetLocation.dart';

class Farmerweather extends StatefulWidget {
  const Farmerweather({super.key});

  @override
  State<Farmerweather> createState() => _FarmerweatherState();
}

class _FarmerweatherState extends State<Farmerweather> {
  var pages = [const SunnyDay(), const Rainyday(), const CloudsDay()];
  var AllApiData = [];

  int? pagecount;
  bool isLoadingData = false;

  bool isMainLoading = false;
  double? Latitude;
  double? longitude;

  Future getLanAndLon() async {
    setState(() => isLoadingData = true);

    try {
      final position = await LocationService.determinePosition(context);

      Latitude = position.latitude;
      longitude = position.longitude;

      await getApidetails();
    } catch (e) {
      debugPrint("LOCATION ERROR: $e");
      setState(() => isLoadingData = false);
    }
  }

  ApiModel? Apidata;

  Future getApidetails() async {
    try {
      if (longitude == null || Latitude == null) return;

      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather'
          '?lat=$Latitude&lon=$longitude'
          '&appid=${ApiKey.weatherApiKey}&units=metric',
        ),
      );

      if (res.statusCode != 200) {
        throw Exception("Weather API failed");
      }

      final data = jsonDecode(res.body);
      final apiData = ApiModel.fromMap(data);

      final weather = apiData.weatherMain?.toLowerCase();

      setState(() {
        Apidata = apiData;

        if (weather == "clouds") {
          pagecount = 2;
        } else if (weather == "rain") {
          pagecount = 1;
        } else {
          pagecount = 0;
        }

        AllApiData = [
          "Latitude : $Latitude",
          "Longitude : $longitude",
          "Temperature : ${Apidata!.temp}°C",
          "Humidity : ${Apidata!.humidity}",
          "Pressure : ${Apidata!.pressure}",
          "WindSpeed : ${Apidata!.windSpeed}",
          "Weather : ${Apidata!.weatherDescription}",
        ];

        isLoadingData = false;
      });
    } catch (e) {
      debugPrint("API ERROR: $e");
      setState(() => isLoadingData = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getLanAndLon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.person, color: Colors.white),
            );
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        elevation: 11,
        shadowColor: Colors.white10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.location_solid,
                        color: Color.fromRGBO(51, 114, 51, 1.0),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${Apidata?.cityName}",
                        style: const TextStyle(
                          color: Color.fromRGBO(51, 114, 51, 1.0),
                          fontFamily: "Poppins-SemiBold",
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Show a message if data is not available
            AllApiData.isEmpty
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "No data available",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
                : Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          "${AllApiData[index]}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppins-SemiBold",
                          ),
                        ),
                      );
                    },
                    separatorBuilder:
                        (context, index) => Divider(color: Colors.white),
                    itemCount: AllApiData.length,
                  ),
                ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child:
            isLoadingData
                ? CupertinoActivityIndicator(
                  color: Color.fromRGBO(51, 114, 51, 1.0),
                )
                : Column(
                  children: [
                    Container(
                      height: 470,
                      width: double.infinity,
                      child: pages[pagecount ?? 0],
                    ),
                    Container(
                      height: 220,
                      width: 375,
                      child: Card(
                        elevation: 15,
                        shadowColor: Colors.white10,
                        color: Colors.white10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "Temperature",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins_light",
                                      ),
                                    ),
                                    Text(
                                      "${Apidata?.temp}°C",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 55),
                                Column(
                                  children: [
                                    Text(
                                      "Weather",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins_light",
                                      ),
                                    ),
                                    Text(
                                      "${Apidata?.weatherMain}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins",
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.location_solid,
                                          color: Color.fromRGBO(
                                            51,
                                            114,
                                            51,
                                            1.0,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "Current Location",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Poppins_light",
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "${Apidata?.cityName}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontFamily: "Poppins-SemiBold",
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
