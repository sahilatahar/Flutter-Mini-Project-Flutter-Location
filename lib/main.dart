import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Location location = Location();
  static bool _serviceEnabled = false;
  static PermissionStatus? _permissionGranted;
  static LocationData? _locationData;
  static List<Placemark>? placemark;
  static double longitude = 0;
  static double latitude = 0;
  static String address = '';

  Future getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    longitude = _locationData!.longitude!;
    latitude = _locationData!.latitude!;
    setState(() {});
  }

  Future getAddress() async {
    await getLocation();
    placemark = await placemarkFromCoordinates(latitude, longitude);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Flutter Location",
          ),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: Text(
                "Coordinates - \nlatitude : ${latitude == 0 ? "Not Available" : latitude} \nlongitude : ${longitude == 0 ? "Not Available" : longitude}",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(
                width: 200.0,
                height: 50.0,
                child: ElevatedButton(
                    onPressed: () async {
                      await getLocation();
                    },
                    child: const Text("Get Location"))),
            SizedBox(
              height: 200.0,
              width: 250.0,
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: placemark != null
                        ? placemark!.map((e) {
                            address += e.street!;
                            address += e.locality!;
                            address += e.administrativeArea!;
                            address += e.country!;
                            address += " (${e.postalCode!})";
                            return Text(
                              "Address: ${address.isEmpty ? "Not Available\n" : '${address}\n'}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            );
                          }).toList()
                        : [const Center(child: Text("Adress : No Address"))]),
              ),
            ),
            SizedBox(
                width: 200.0,
                height: 50.0,
                child: ElevatedButton(
                    onPressed: () async {
                      await getAddress();
                    },
                    child: const Text("Get Address"))),
          ],
        )),
      ),
    );
  }
}
