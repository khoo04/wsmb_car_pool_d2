import 'package:car_pool_rider/models/ride.dart';
import 'package:car_pool_rider/models/rider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideHistory {
  final DocumentReference? riderRef;
  final Ride? ride;
  final DocumentReference? rideRef;
  final Rider? rider;
  final String status;

  RideHistory({
    this.ride,
    required this.status,
    this.riderRef,
    this.rideRef,
    this.rider,
  });


  set status(String value) => status;

  Map<String, dynamic> toJson() {
    return {
      "rider": riderRef,
      "ride": rideRef,
      "status": status,
    };
  }

  factory RideHistory.fromJson(Map<String, dynamic> json) {
    return RideHistory(
      ride: Ride.fromJson(json["ride"]),
      rider: Rider.fromJson(json["rider"]),
      status: json["status"],
    );
  }
}