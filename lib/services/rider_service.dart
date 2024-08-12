import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../models/driver.dart';
import '../models/rider.dart';
import '../models/vehicle.dart';

class RiderService {
  static final riderRef = FirebaseFirestore.instance.collection('riders');

  static Future<bool> createNewRider(Rider rider) async {
    try {
      String? uId = FirebaseAuth.instance.currentUser?.uid;
      await riderRef.doc(uId).set(rider.toJson());
      return true;
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<Rider?> getCurrentLoginUser() async {
    try {
      String? uId = FirebaseAuth.instance.currentUser?.uid;
      final snapshot = await riderRef.doc(uId).get();
      final userData = snapshot.data();
      if (userData != null) {
        Rider rider = Rider.fromJson(userData);
        return rider;
      } else {
        throw Exception("Rider does not exist");
      }
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<bool> checkIsDuplicated(String email, String ic) async {
    final snapshotEmail =
        await riderRef.where("email", isEqualTo: email).get();
    final snapshotIC = await riderRef.where("IC", isEqualTo: ic).get();
    if (snapshotEmail.docs.isEmpty && snapshotIC.docs.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> updateRiderDetails(Rider rider) async {
    try {
      String? uId = FirebaseAuth.instance.currentUser?.uid;

      if (rider.imageUrl == null){
        debugPrint("Update without new image");
        await riderRef.doc(uId).update({
          "name": rider.name,
          "address": rider.address,
          "phone": rider.phone,
        });
      }else{debugPrint("Update with new image");
      await riderRef.doc(uId).update({
        "name": rider.name,
        "address": rider.address,
        "phone": rider.phone,
        "imageUrl": rider.imageUrl,
      });
      }
      return true;
    } catch (e) {
      debugPrint("Error occurred in updating driver details");
      return false;
    }
  }
}
