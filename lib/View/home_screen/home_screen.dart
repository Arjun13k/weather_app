import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:weather_app/Contoller/Api_provider/api_provider.dart';
import 'package:weather_app/Contoller/Location_provider/location_provider.dart';
import 'package:weather_app/Global/global.dart';
import 'package:weather_app/View/Quality_checking_screen/quality_checking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isCheked = false;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.determinePosition().then((_) {
      if (locationProvider.currentLocation != null) {
        var city = locationProvider.currentLocation!.locality;
        if (city != null) {
          _getWeatherAndForecast(city);
          Provider.of<ApiProvider>(context, listen: false).airPolution(
              locationProvider.currentPosition?.latitude.toDouble() ?? 0,
              locationProvider.currentPosition?.longitude.toDouble() ?? 0);
        }
      }
    });
  }

  // Fetch weather, forecast, and air pollution for a searched city
  void _getWeatherAndForecast(String city) {
    setState(() {
      isLoading = true;
    });

    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    apiProvider.fetchDataOfCity(city).then((_) {
      return apiProvider.forcaste(city);
    }).then((_) {
      setState(() {
        isLoading = false;
      });

      // Now fetch air pollution for the searched city's coordinates
      if (apiProvider.weather != null) {
        double latitude = apiProvider.weather?.coord?.lat ?? 0;
        double longitude = apiProvider.weather?.coord?.lon ?? 0;
        _getAirPollutionData(latitude, longitude);
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching data: $error");
    });
  }

  // Function to fetch air pollution data based on latitude and longitude
  void _getAirPollutionData(double latitude, double longitude) {
    Provider.of<ApiProvider>(context, listen: false)
        .airPolution(latitude, longitude);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String? formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      DateTime dateTime = DateTime.parse(dateString);

      return DateFormat("dd MMM").format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  String? formatTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      DateTime dateTime = DateTime.parse(dateString);

      return DateFormat("hh a").format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerCity = Provider.of<ApiProvider>(context);
    if (providerCity.isLoading || isLoading || providerCity.weather == null) {
      return Center(child: CircularProgressIndicator());
    }
    int sunriseTimestamp = providerCity.weather?.sys?.sunrise ?? 0;
    int sunsetTimestamp = providerCity.weather?.sys?.sunset ?? 0;
    ;

    DateTime sunriseTime = DateTime.fromMillisecondsSinceEpoch(
        sunriseTimestamp * 1000,
        isUtc: true);
    DateTime sunsetTime = DateTime.fromMillisecondsSinceEpoch(
        sunsetTimestamp * 1000,
        isUtc: true);

    Duration timezoneOffset = Duration(seconds: 19800);
    DateTime localSunriseTime = sunriseTime.add(timezoneOffset);
    DateTime localSunsetTime = sunsetTime.add(timezoneOffset);

    String formattedSunrise = DateFormat('hh:mm a').format(localSunriseTime);
    String formattedSunset = DateFormat('hh:mm a').format(localSunsetTime);

    if (providerCity.isLoading || isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    Size size = MediaQuery.of(context).size;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          title: isCheked
              ? Container(
                  height: 50,
                  child: TextFormField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(20)),
                          // filled: true,
                          hintText: "Search",
                          hintStyle: TextStyle(color: Colors.white)),
                      controller: searchController),
                )
              : Text(
                  providerCity.weather?.name ?? "",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 25),
                ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isCheked = !isCheked;
                  isLoading = true;

                  _getWeatherAndForecast(searchController.text.trim());
                  searchController.clear();
                });
              },
              icon: Icon(Icons.search, color: Colors.white),
            ),
          ],
          backgroundColor: Colors.transparent,
        ),
        body: RefreshIndicator(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    imagePath[providerCity.weather?.weather?[0].main ?? ""] ??
                        "asset/images/pexels-babybluecat-6843588.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            height: size.height,
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 150),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      enabled: true,
                      child: Text(
                        "${providerCity.weather?.main?.temp?.round()}°C",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 90,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: providerCity.weather?.weather?[0].main ?? "",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 30,
                                color: Colors.white)),
                        WidgetSpan(child: SizedBox(width: 10)),
                        TextSpan(
                            text:
                                "${providerCity.weather?.main?.tempMax?.round()}°",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 25,
                                color: Colors.white)),
                        TextSpan(
                            text: "/",
                            style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 30,
                                color: Colors.white)),
                        TextSpan(
                            text:
                                "${providerCity.weather?.main?.tempMin?.round()}°",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 25,
                                color: Colors.white)),
                      ]),
                    ),
                    Text(providerCity.weather?.name ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white)),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QualityCheckingScreen(),
                            ));
                      },
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco,
                                color: Colors.white,
                              ),
                              Text("AQI",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white))
                            ],
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(.2)),
                      ),
                    ),
                    SizedBox(height: 80),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(.1)),
                      child: Column(
                        children: [
                          Text("Hourly Forecast",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white)),
                          SizedBox(height: 10),
                          Divider(),
                          SizedBox(height: 10),
                          Container(
                            height: 150,
                            child: ListView.builder(
                              itemCount:
                                  providerCity.forcasteData?.list?.length,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final data =
                                    providerCity.forcasteData?.list?[index];
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.black.withOpacity(.3)),
                                  width: 70,
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        formatDate(data?.dtTxt.toString()) ??
                                            'Invalid date',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      // SizedBox(height: 5),
                                      Text(
                                        formatTime(data?.dtTxt.toString()) ??
                                            'Invalid date',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      SizedBox(height: 5),
                                      Image.asset(
                                        icons[providerCity
                                                    .forcasteData
                                                    ?.list?[index]
                                                    .weather?[0]
                                                    .main ??
                                                ""] ??
                                            "asset/images/pexels-babybluecat-6843588.jpg",
                                        scale: 19,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        data != null
                                            ? "${data.main?.temp?.round()}°C"
                                            : "No data",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // if (providerCity.forcasteData != null) ...[
                          //   Text(
                          //       'Humidity: ${providerCity.forcasteData?.list?.first.main?.humidity}%',
                          //       style: TextStyle(color: Colors.white)),
                          //   // Display more forecast data as needed
                          // ],
                          // if (providerCity.forcasteData == null) ...[
                          //   Text('No forecast data available.',
                          //       style: TextStyle(color: Colors.white)),
                          // ],
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            // width: 100,
                            height: 190,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.3),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      "asset/images/sun.png",
                                      scale: 2,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Sunrise",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      formattedSunrise,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 17,
                                  ),
                                  Expanded(
                                    child: Image.asset(
                                      "asset/images/moon.png",
                                      scale: 4,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Sunset",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      formattedSunset,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            // width: 220,
                            height: 190,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.3),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Humidity",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        "${providerCity.weather?.main?.humidity.toString()} %",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    thickness: .2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Real Feals",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        "${providerCity.weather?.main?.feelsLike?.round()}°",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    thickness: .2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Pressure",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        "${providerCity.weather?.main?.pressure.toString()}mbar",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    thickness: .2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Wind",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        "${providerCity.weather?.wind?.speed.toString()} km/h",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    thickness: .2,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
          ),
          onRefresh: () async {
            _fetchInitialData();
          },
        ));
  }
}
