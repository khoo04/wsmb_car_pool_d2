import 'dart:ui';

import 'package:car_pool_rider/pages/ride_details_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/ride_service.dart';

class HistoryRidePage extends StatelessWidget {
  const HistoryRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your History Ride"),
      ),
      body: FutureBuilder(
        future: RideService.fetchHistoryRide(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return const Center(
              child: Text("Error in fetching history rides"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          List<Map<String, dynamic>> historyRide = snapshot.data!;
          double totalFare = 0;
          for (var ride in historyRide) {
            if (ride["data"].status != "cancel") {
              totalFare += ride["data"].ride!.fare;
            }
          }

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        DateTime currentTime = DateTime.now();
                        String status = historyRide[index]["data"].status;
                        if ((historyRide[index]["data"].ride!.startDateTime
                                    as DateTime)
                                .isBefore(currentTime) &&
                            status != "cancel") {
                          status = "inactive";
                        }
                        Color? color;
                        switch (status) {
                          case "inactive":
                            color = Colors.grey;
                            break;
                          case "cancel":
                            color = Colors.red[400];
                            break;
                          case "active":
                          default:
                            color = Colors.blue[200];
                            break;
                        }
                        String rideDateTime =
                            "${historyRide[index]["data"].ride!.startDateTime.day}/${historyRide[index]["data"].ride!.startDateTime.month}/${historyRide[index]["data"].ride!.startDateTime.year} ${historyRide[index]["data"].ride!.startDateTime.hour.toString().padLeft(2, '0')}:${historyRide[index]["data"].ride!.startDateTime.minute.toString().padLeft(2, '0')}";

                        return Card(
                          color: color,
                          child: ListTile(
                            title: Text.rich(TextSpan(
                                text: "Origin: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                      text:
                                          "${historyRide[index]["data"].ride!.origin}\n",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  const TextSpan(
                                      text: "Destination: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: historyRide[index]["data"]
                                          .ride!
                                          .destination,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal)),
                                ])),
                            subtitle: Text.rich(TextSpan(
                                text: "Date Time: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                      text: "$rideDateTime\n",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  const TextSpan(
                                      text: "Status: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text:
                                          "${status.substring(0, 1).toUpperCase()}${status.substring(1)}\n",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  const TextSpan(
                                      text: "Fare: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text:
                                      "RM ${historyRide[index]["data"].ride!.fare}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal)),
                                ])),
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RideDetails(
                                          rideId: historyRide[index]["id"])));
                            },
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 8.0,
                        );
                      },
                      itemCount: historyRide.length),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Fare:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24.0),
                      ),
                      Text("RM$totalFare",
                          style: const TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 24.0)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
