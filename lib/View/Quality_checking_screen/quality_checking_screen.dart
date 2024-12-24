import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/Contoller/Api_provider/api_provider.dart';
import 'package:weather_app/Global/global.dart';

class QualityCheckingScreen extends StatefulWidget {
  const QualityCheckingScreen({super.key});

  @override
  State<QualityCheckingScreen> createState() => _QualityCheckingScreenState();
}

class _QualityCheckingScreenState extends State<QualityCheckingScreen> {
  @override
  void initState() {
    // airData();
    super.initState();
  }

  // Future<void> airData() async {
  //   final location = await Provider.of<ApiProvider>(context, listen: false);
  //   final currentLocation = location.airPolution(
  //       location.air?.coord?.lat ?? 0, location.air?.coord?.lon ?? 0);
  // }

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

  @override
  Widget build(BuildContext context) {
    final airQuality = Provider.of<ApiProvider>(context);

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Air Quality Index",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            SizedBox(
              height: 5,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                text: airQuality.weather?.name.toString(),
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              WidgetSpan(
                  child: SizedBox(
                width: 5,
              )),
              TextSpan(
                text: "Published on",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              WidgetSpan(
                  child: SizedBox(
                width: 5,
              )),
              TextSpan(
                text: formatDate(airQuality.air?.list?[0].dt.toString()),
                style: TextStyle(fontSize: 15, color: Colors.black),
              )
            ])),
            SizedBox(
              height: 50,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                text: airQuality.air?.list?[0].components?['pm2_5']
                        ?.round()
                        .toString() ??
                    "",
                style: TextStyle(
                    fontSize: 50,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              WidgetSpan(
                  child: SizedBox(
                width: 10,
              )),
              TextSpan(
                text: quality[airQuality.air?.list?[0].main?.aqi],
                style: TextStyle(
                    fontSize: 20,
                    color: color[airQuality.air?.list?[0].main?.aqi]),
              ),
            ])),
            SizedBox(
              height: 15,
            ),
            Text(dialogue[airQuality.air?.list?[0].main?.aqi]),
            SizedBox(
              height: 50,
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: airQuality.air?.list?.length,
                itemBuilder: (context, index) {
                  final quality = airQuality.air?.list?[index].components;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Text(quality?['pm2_5']?.toString() ?? "",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 20,
                                    color: color[
                                        airQuality.air?.list?[0].main?.aqi])),
                            SizedBox(
                              height: 5,
                            ),
                            Text("pm2 5"),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Text(quality?['pm10']?.toString() ?? "",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 20,
                                    color: color[
                                        airQuality.air?.list?[0].main?.aqi])),
                            SizedBox(
                              height: 5,
                            ),
                            Text("pm10"),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Text(quality?['so2']?.toString() ?? "",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 20,
                                    color: color[
                                        airQuality.air?.list?[0].main?.aqi])),
                            SizedBox(
                              height: 5,
                            ),
                            Text("so2"),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Text(quality?['no2']?.toString() ?? "",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 20,
                                    color: color[
                                        airQuality.air?.list?[0].main?.aqi])),
                            SizedBox(
                              height: 5,
                            ),
                            Text("no2"),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Text(quality?['o3']?.toString() ?? "",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 20,
                                    color: color[
                                        airQuality.air?.list?[0].main?.aqi])),
                            SizedBox(
                              height: 5,
                            ),
                            Text("o3"),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Text(quality?['nh3']?.toString() ?? "",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontSize: 20,
                                    color: color[
                                        airQuality.air?.list?[0].main?.aqi])),
                            SizedBox(
                              height: 5,
                            ),
                            Text("nh3"),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
