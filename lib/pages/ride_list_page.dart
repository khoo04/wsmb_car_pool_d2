import 'package:car_pool_rider/services/ride_service.dart';
import 'package:car_pool_rider/widgets/ride_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RideListPage extends StatefulWidget {
  const RideListPage({super.key});

  @override
  State<RideListPage> createState() => _RideListPageState();
}

class _RideListPageState extends State<RideListPage> {
  final originTextController = TextEditingController();
  final destinationTextController = TextEditingController();
  final pickedDateTimeTextController = TextEditingController();
  DateTime? pickedDateToSearch;

  Future<void> _chooseDate() async {
    final pickedDate = await showDatePicker(
        context: context, firstDate: DateTime(1800), lastDate: DateTime(2200));

    if (pickedDate == null) {
      return;
    }

    final pickedTime =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime == null) {
      return;
    }
    pickedDateToSearch =
        pickedDate.copyWith(hour: pickedTime.hour, minute: pickedTime.minute);
    setState(() {
      pickedDateTimeTextController.text =
      "${pickedDateToSearch!.day}/${pickedDateToSearch!.month}/${pickedDateToSearch!.year} ${pickedDateToSearch!.hour.toString().padLeft(2, '0')}:${pickedDateToSearch!.minute.toString().padLeft(2, '0')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Column(
          children: [
            const Text(
              "All Available Rides",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Divider(),
            const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: originTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Origin",
                      labelText: "Origin",
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextFormField(
                    controller: destinationTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Destination",
                      labelText: "Destination",
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: pickedDateTimeTextController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Rides after selected date",
                      labelText: "Rides after selected date",
                      isDense: true,
                    ),
                    onTap: () async {
                      await _chooseDate();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: () {
                    setState(() {

                    });
                  },
                  child: const Text("Search"),),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: FutureBuilder(
                  future: RideService.fetchRideList(
                      origin: originTextController.text.trim(),
                      destination: destinationTextController.text.trim(),
                      dateTime: pickedDateToSearch),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      debugPrint(snapshot.error.toString());
                      return const Center(
                          child: Text("Error in fetching rides list"));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    List<Map<String, dynamic>> rideList = snapshot.data!;
                    if (rideList.isEmpty){
                      return const Center(child: Text("Rides not found"),);
                    }
                    return ListView.builder(
                      itemBuilder: (context, index) => RideCard(
                          ride: rideList[index]["ride"],
                          rideId: rideList[index]["rideId"]),
                      itemCount: rideList.length,
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
