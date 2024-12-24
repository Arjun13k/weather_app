// To parse this JSON data, do
//
//     final airQualityModel = airQualityModelFromJson(jsonString);

import 'dart:convert';

AirQualityModel airQualityModelFromJson(String str) =>
    AirQualityModel.fromJson(json.decode(str));

String airQualityModelToJson(AirQualityModel data) =>
    json.encode(data.toJson());

class AirQualityModel {
  Coord? coord;
  List<ListElement>? list;

  AirQualityModel({
    this.coord,
    this.list,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) =>
      AirQualityModel(
        coord: json["coord"] == null ? null : Coord.fromJson(json["coord"]),
        list: json["list"] == null
            ? []
            : List<ListElement>.from(
                json["list"]!.map((x) => ListElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "coord": coord?.toJson(),
        "list": list == null
            ? []
            : List<dynamic>.from(list!.map((x) => x.toJson())),
      };
}

class Coord {
  double? lon;
  double? lat;

  Coord({
    this.lon,
    this.lat,
  });

  factory Coord.fromJson(Map<String, dynamic> json) => Coord(
        lon: json["lon"]?.toDouble(),
        lat: json["lat"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lon": lon,
        "lat": lat,
      };
}

class ListElement {
  Main? main;
  Map<String, double>? components;
  int? dt;

  ListElement({
    this.main,
    this.components,
    this.dt,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        main: json["main"] == null ? null : Main.fromJson(json["main"]),
        components: Map.from(json["components"]!)
            .map((k, v) => MapEntry<String, double>(k, v?.toDouble())),
        dt: json["dt"],
      );

  Map<String, dynamic> toJson() => {
        "main": main?.toJson(),
        "components": Map.from(components!)
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
        "dt": dt,
      };
}

class Main {
  int? aqi;

  Main({
    this.aqi,
  });

  factory Main.fromJson(Map<String, dynamic> json) => Main(
        aqi: json["aqi"],
      );

  Map<String, dynamic> toJson() => {
        "aqi": aqi,
      };
}
