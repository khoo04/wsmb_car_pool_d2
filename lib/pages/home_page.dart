import 'package:car_pool_rider/pages/history_ride_page.dart';
import 'package:car_pool_rider/pages/profile_page.dart';
import 'package:car_pool_rider/pages/ride_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int indexPage = 0;
  List<Widget> pages = [const RideListPage(), const ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Pools App Rider"),
        actions: [
          IconButton(
            onPressed: ()  {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryRidePage()));
              debugPrint("History Page");
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: pages[indexPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indexPage,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.car_rental_sharp), label: "Rides List"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (value) {
          setState(() {
            indexPage = value;
          });
        },
      ),
    );
  }
}
