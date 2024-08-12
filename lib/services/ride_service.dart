import 'package:car_pool_rider/models/ride_history.dart';
import 'package:car_pool_rider/pages/history_ride_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/driver.dart';
import '../models/ride.dart';
import '../models/rider.dart';

class RideService {
  static final ridesRef = FirebaseFirestore.instance.collection('rides');
  static final ridesHistoryRef =
      FirebaseFirestore.instance.collection('userRideHistory');

  static Future<List<Map<String, dynamic>>> fetchRideList(
      {String? origin, String? destination, DateTime? dateTime}) async {
    List<Map<String, dynamic>> data = [];
    final rideDocs = await ridesRef.where("status", isEqualTo: "active").where("startDateTime",isGreaterThan: DateTime.timestamp()).get();
    for (var doc in rideDocs.docs) {
      Map<String, dynamic> docData = doc.data();
      //Get Driver Info
      DocumentReference driverRef = docData["driver"] as DocumentReference;
      Map<String, dynamic> driverData =
          (await driverRef.get()).data() as Map<String, dynamic>;
      docData["driver"] = driverData;

      //Get Riders Info
      final ridersRef = docData["riders"].cast<DocumentReference>();
      List<Map<String, dynamic>> ridersData = [];
      for (DocumentReference riderRef in ridersRef) {
        Map<String, dynamic> riderData =
            (await riderRef.get()).data() as Map<String, dynamic>;
        ridersData.add(riderData);
      }
      docData["riders"] = ridersData;
      data.add({
        "rideId": doc.id,
        "ride": Ride.fromJson(docData),
      });
    }

    if (origin != null && origin != "") {
      data = data.where((e) => e["ride"].origin.contains(origin)).toList();
    }
    if (destination != null && destination != "") {
      data = data
          .where((e) => e["ride"].destination.contains(destination))
          .toList();
    }
    if (dateTime != null) {
      data = data.where((e) => e["ride"].startDateTime.isAfter(dateTime)).toList();
    }
    return data;
  }

  static Future<Ride> fetchCurrentRideDetails(String rideId) async {
    await Future.delayed(Duration(seconds: 2));
    DocumentSnapshot documentSnapshot = await ridesRef.doc(rideId).get();
    Map<String, dynamic> dataMap =
        documentSnapshot.data() as Map<String, dynamic>;

    //Get Driver Info
    DocumentReference driverRef = dataMap["driver"] as DocumentReference;
    Map<String, dynamic> driverData =
        (await driverRef.get()).data() as Map<String, dynamic>;
    dataMap["driver"] = driverData;

    //Get Riders Info
    final ridersRef = dataMap["riders"].cast<DocumentReference>();
    List<Map<String, dynamic>> ridersData = [];
    for (DocumentReference riderRef in ridersRef) {
      Map<String, dynamic> riderData =
          (await riderRef.get()).data() as Map<String, dynamic>;
      ridersData.add(riderData);
    }
    dataMap["riders"] = ridersData;
    final Ride ride = Ride.fromJson(dataMap);
    return ride;
  }

  static Future<bool> joinRide(String rideId, int carCapacity) async {
    try {
      String? uID = FirebaseAuth.instance.currentUser?.uid;
      if (uID == null) {
        throw Exception("User ID was not found");
      }
      //Get Current Login User Ref
      final userRef = FirebaseFirestore.instance.collection('riders').doc(uID);

      DocumentSnapshot documentSnapshot = await ridesRef.doc(rideId).get();
      Map<String, dynamic> dataMap =
          documentSnapshot.data() as Map<String, dynamic>;

      //Get Riders Info
      List<DocumentReference> ridersRef =
          dataMap["riders"].cast<DocumentReference>();
      if (ridersRef.length < carCapacity && !ridersRef.contains((userRef))) {
        //Update Ride Info
        ridersRef.add(userRef);
        ridesRef.doc(rideId).update({"riders": ridersRef});

        DocumentReference currentRideReference = ridesRef.doc(rideId);
        RideHistory rideHistoryModel = RideHistory(
            rideRef: currentRideReference, status: "active", riderRef: userRef);

        String? historyId = (await ridesHistoryRef
            .where("ride", isEqualTo: currentRideReference)
            .where('rider', isEqualTo: userRef)
            .get()).docs.firstOrNull?.id;

        if (historyId != null){
          ridesHistoryRef.doc(historyId).update(rideHistoryModel.toJson());
        }else{
          ridesHistoryRef.add(rideHistoryModel.toJson());
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> cancelRide(String rideId) async {
    try {
      String? uID = FirebaseAuth.instance.currentUser?.uid;
      if (uID == null) {
        throw Exception("User ID was not found");
      }
      //Get Current Login User Ref
      final userRef = FirebaseFirestore.instance.collection('riders').doc(uID);

      DocumentSnapshot documentSnapshot = await ridesRef.doc(rideId).get();
      Map<String, dynamic> dataMap =
          documentSnapshot.data() as Map<String, dynamic>;

      //Get Riders Info
      List<DocumentReference> ridersRef =
          dataMap["riders"].cast<DocumentReference>();
      //Update Ride Info
      ridersRef.remove(userRef);
      ridesRef.doc(rideId).update({"riders": ridersRef});

      DocumentReference currentRideReference = ridesRef.doc(rideId);
      RideHistory rideHistoryModel = RideHistory(
          rideRef: currentRideReference, status: "cancel", riderRef: userRef);

      String historyId = (await ridesHistoryRef
              .where("ride", isEqualTo: currentRideReference)
              .where('rider', isEqualTo: userRef)
              .get())
          .docs
          .first
          .id;

      ridesHistoryRef.doc(historyId).update(rideHistoryModel.toJson());

      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<List<Map<String,dynamic>>> fetchHistoryRide() async {
    List<Map<String,dynamic>> historyRides = [];

    String? uID = FirebaseAuth.instance.currentUser?.uid;
    if (uID == null) {
      throw Exception("User ID was not found");
    }
    //Get Current Login User Ref
    final userRef = FirebaseFirestore.instance.collection('riders').doc(uID);

    final queryMyRides =  await ridesHistoryRef.where('rider', isEqualTo: userRef).get();
    for (var doc in queryMyRides.docs){
      Map<String,dynamic> docData = doc.data();
      DocumentReference rideRef = docData["ride"];

      //Replace reference to json object
      String rideId = (await rideRef.get()).id;
      Map<String,dynamic> rideData = (await rideRef.get()).data() as Map<String,dynamic>;
      docData["ride"] = rideData;

      //Get Driver Info
      DocumentReference driverRef = docData["ride"]["driver"] as DocumentReference;
      Map<String, dynamic> driverData =
      (await driverRef.get()).data() as Map<String, dynamic>;
      docData["ride"]["driver"] = driverData;

      //Get Riders Info
      final ridersRef = docData["ride"]["riders"].cast<DocumentReference>();
      List<Map<String, dynamic>> ridersData = [];
      for (DocumentReference riderRef in ridersRef) {
        Map<String, dynamic> riderData =
        (await riderRef.get()).data() as Map<String, dynamic>;
        ridersData.add(riderData);
      }
      docData["ride"]["riders"] = ridersData;

      DocumentReference riderRef = docData["rider"];

      Map<String,dynamic> riderData = (await riderRef.get()).data() as Map<String,dynamic>;
      docData["rider"] = riderData;

      historyRides.add({
        "id": rideId,
        "data": RideHistory.fromJson(docData),
      });
    }

    return historyRides;
  }
}
