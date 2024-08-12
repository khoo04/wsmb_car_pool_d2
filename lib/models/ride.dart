import 'package:car_pool_rider/models/rider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'driver.dart';

class Ride {
  final String origin;
  final String destination;
  final DateTime startDateTime;
  final double fare;
  late DocumentReference? driverRef;
  late Driver? driver;
  late List<DocumentReference> riderRefs;
  late List<Rider?> riders;
  final String? status;

  Ride({
    required this.fare,
    required this.origin,
    required this.destination,
    required this.startDateTime,
    this.driverRef,
    this.driver,
    this.riderRefs = const <DocumentReference>[],
    this.riders = const [],
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "origin": origin,
      "destination": destination,
      "startDateTime": startDateTime,
      "fare": fare,
      "driver": driverRef,
      "riders": riderRefs,
      "status": status,
    };
  }

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      origin: json["origin"],
      destination: json["destination"],
      startDateTime: (json["startDateTime"] as Timestamp).toDate(),
      driver: Driver.fromJson(json["driver"]),
      fare: json["fare"] as double,
      status: json["status"],
      riders: json["riders"] == []
          ? []
          : (json["riders"] as List)
              .map((e) => Rider.fromJson(e))
              .toList(),
    );
  }

}
