import 'package:car_pool_rider/pages/ride_details_page.dart';
import 'package:flutter/material.dart';

import '../models/ride.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final String rideId;
  const RideCard({super.key, required this.ride, required this.rideId});

  @override
  Widget build(BuildContext context) {
    String rideDateTime = "${ride.startDateTime.day}/${ride.startDateTime.month}/${ride.startDateTime.year} ${ride.startDateTime.hour.toString().padLeft(2, '0')}:${ride.startDateTime.minute.toString().padLeft(2, '0')}";
    return Card(
      color: Colors.blue[200],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ride.driver?.imageUrl == null
                ? const CircleAvatar(
              radius: 60,
              child: Icon(
                Icons.person,
                size: 60,
              ),
            )
                : CircleAvatar(
              backgroundImage: NetworkImage(ride.driver!.imageUrl!),
              radius: 60,
            ),
            const SizedBox(height: 20,),
            Text.rich(TextSpan(text: "Driver Name: ", style: const TextStyle(fontWeight: FontWeight.bold),children: [
              TextSpan(text: "${ride.driver?.name}", style: const TextStyle(fontWeight: FontWeight.normal)),
            ])),
            const SizedBox(height: 10.0),
            const Text("Ride Details:",  style: TextStyle(fontWeight: FontWeight.bold)),
            Text.rich(TextSpan(text: "Origin: ", style: const TextStyle(fontWeight: FontWeight.bold),children: [
              TextSpan(text: ride.origin, style: const TextStyle(fontWeight: FontWeight.normal)),
            ])),
            Text.rich(TextSpan(text: "Destination: ", style: const TextStyle(fontWeight: FontWeight.bold),children: [
              TextSpan(text: ride.destination, style: const TextStyle(fontWeight: FontWeight.normal)),
            ])),
            Text.rich(TextSpan(text: "Date Time Start: ", style: const TextStyle(fontWeight: FontWeight.bold),children: [
              TextSpan(text: rideDateTime, style: const TextStyle(fontWeight: FontWeight.normal)),
            ])),
            Text.rich(TextSpan(text: "Fare: ", style: const TextStyle(fontWeight: FontWeight.bold),children: [
              TextSpan(text: "RM${ride.fare}", style: const TextStyle(fontWeight: FontWeight.normal)),
            ])),
            const SizedBox(height: 5.0,),
            Align(
              child: ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => RideDetails(rideId: rideId)));
              }, child: const Text("View Details"),),
            )
          ],
        ),
      ),
    );
  }
}
