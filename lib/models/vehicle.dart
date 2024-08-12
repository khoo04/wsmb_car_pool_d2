import 'dart:core';

class Vehicle {
  final String carModel;
  final int capacity;
  final String specialFeatures;

  Vehicle({
    required this.carModel,
    required this.capacity,
    this.specialFeatures = "",
  });

  Map<String, dynamic> toJson() {
    return {
      "carModel": carModel,
      "capacity": capacity,
      "specialFeatures": specialFeatures,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      carModel: json["carModel"],
      capacity: json["capacity"] as int,
      specialFeatures: json["specialFeatures"],
    );
  }
}
