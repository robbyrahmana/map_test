import 'package:cloud_firestore/cloud_firestore.dart';

class MapModel {
  final String name;
  final GeoPoint location;

  MapModel({this.name, this.location});

  factory MapModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return MapModel(name: json['name'], location: json['location']);
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "location": location};
  }
}
