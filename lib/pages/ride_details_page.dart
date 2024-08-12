import 'package:car_pool_rider/services/ride_service.dart';
import 'package:car_pool_rider/services/rider_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/ride.dart';

class RideDetails extends StatefulWidget {
  final String rideId;
  const RideDetails({super.key, required this.rideId});

  @override
  State<RideDetails> createState() => _RideDetailsState();
}

class _RideDetailsState extends State<RideDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Details"),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: RideService.fetchCurrentRideDetails(widget.rideId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text("Error in fetching current ride details"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            Ride ride = snapshot.data!;
            String rideDateTime = "${ride.startDateTime.day}/${ride.startDateTime.month}/${ride.startDateTime.year} ${ride.startDateTime.hour.toString().padLeft(2, '0')}:${ride.startDateTime.minute.toString().padLeft(2, '0')}";
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(alignment: Alignment.center,child:  ride.driver?.imageUrl == null
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
                    ),),
                
                    const SizedBox(height: 20,),
                    const Text("Driver Details: ",  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const Divider(),
                    Text.rich(TextSpan(text: "Name: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),children: [
                      TextSpan(text: ride.driver?.name, style: const TextStyle(fontWeight: FontWeight.normal)),
                    ])),
                    Text.rich(TextSpan(text: "Phone: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),children: [
                      TextSpan(text: ride.driver?.phone, style: const TextStyle(fontWeight: FontWeight.normal)),
                    ])),
                    Text.rich(TextSpan(text: "Gender: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),children: [
                      TextSpan(text: "${ride.driver?.gender.substring(0,1).toUpperCase()}${ride.driver?.gender.substring(1)}", style: const TextStyle(fontWeight: FontWeight.normal)),
                    ])),
                    const SizedBox(height: 15,),
                    const Text("Vehicle Details:",  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const Divider(),
                    Text.rich(TextSpan(text: "Car Model: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),children: [
                      TextSpan(text: ride.driver?.vehicle.carModel, style: const TextStyle(fontWeight: FontWeight.normal)),
                    ])),
                    Text.rich(TextSpan(text: "Car Capacity: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),children: [
                      TextSpan(text: ride.driver?.vehicle.capacity.toString(), style: const TextStyle(fontWeight: FontWeight.normal)),
                    ])),
                    Text.rich(TextSpan(text: "Special Features: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),children: [
                      TextSpan(text: ride.driver?.vehicle.specialFeatures, style: const TextStyle(fontWeight: FontWeight.normal)),
                    ])),
                    const SizedBox(height: 15,),
                    const Text("Ride Details:",  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const Divider(),
                    Text.rich(TextSpan(text: "Origin: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),children: [
                      TextSpan(text: ride.origin, style: const TextStyle(fontWeight: FontWeight.normal)),
                    ])),
                    Text.rich(TextSpan(text: "Destination: ", style: const TextStyle(fontWeight: FontWeight.bold,  fontSize: 16),children: [
                      TextSpan(text: ride.destination, style: const TextStyle(fontWeight: FontWeight.normal)),
                    ])),
                    Text.rich(TextSpan(text: "Date Time Start: ", style: const TextStyle(fontWeight: FontWeight.bold,  fontSize: 16),children: [
                      TextSpan(text: rideDateTime, style: const TextStyle(fontWeight: FontWeight.normal)),
                    ])),
                    Text.rich(TextSpan(text: "Fare: ", style: const TextStyle(fontWeight: FontWeight.bold,  fontSize: 16),children: [
                      TextSpan(text: "RM${ride.fare}", style: const TextStyle(fontWeight: FontWeight.normal)),
                    ])),
                    const SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ride.riders.any((element) => element!.email == FirebaseAuth.instance.currentUser!.email) ?
                        ElevatedButton(
                            onPressed: () async {
                              RideService.cancelRide(widget.rideId);
                              setState(() {
                              });
                            }, child:  const Text("Cancel"),
                        ) :  ElevatedButton(
                          onPressed: () async {
                            RideService.joinRide(widget.rideId, ride.driver!.vehicle.capacity);
                            setState(() {
                            });
                          }, child:  const Text("Join"),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
