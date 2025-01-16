import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geofence_foreground_service/constants/geofence_event_type.dart';
import 'package:geofence_foreground_service/exports.dart';
import 'package:geofence_foreground_service/geofence_foreground_service.dart';
import 'package:geofence_foreground_service/models/notification_icon_data.dart';
import 'package:geofence_foreground_service/models/zone.dart';
import 'package:geofence_foreground_service_example/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';

String portName = 'geofence_port_name';

@pragma('vm:entry-point')
void callbackDispatcher() async {
  GeofenceForegroundService().handleTrigger(
    backgroundTriggerHandler: (zoneID, triggerType) async {
      // // send with isolate
      // SendPort? port = IsolateNameServer.lookupPortByName(portName);
      // if (port != null && triggerType == GeofenceEventType.dwell) {
      //   port.send("$zoneID T:${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}");
      // }
      await StorageService.add("$zoneID T:${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}");
      log(zoneID, name: 'zoneID');
      log(DateTime.now().toString(), name: 'triggerTime');

      if (triggerType == GeofenceEventType.enter) {
        log('enter', name: 'triggerType');
      } else if (triggerType == GeofenceEventType.exit) {
        log('exit', name: 'triggerType');
      } else if (triggerType == GeofenceEventType.dwell) {
        log('dwell', name: 'triggerType');
      } else {
        log('unknown', name: 'triggerType');
      }

      return Future.value(true);
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> locations = [];
  static final LatLng _londonCityCenter = LatLng.degree(40.127543, 65.351606);

  bool _hasServiceStarted = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    locations = await StorageService.getList();
    setState(() {});
    await Permission.location.request();
    await Permission.locationAlways.request();
    await Permission.notification.request();

    _hasServiceStarted = await GeofenceForegroundService().startGeofencingService(
      contentTitle: 'Test app is running in the background',
      contentText: 'Test app will be running to ensure seamless integration with ops team',
      notificationChannelId: 'com.app.geofencing_notifications_channel',
      serviceId: 525600,
      isInDebugMode: true,
      notificationIconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
      callbackDispatcher: callbackDispatcher,
    );
    log(_hasServiceStarted.toString(), name: 'hasServiceStarted');
  }

  Future<void> _createLondonGeofence() async {
    if (!_hasServiceStarted) {
      log('Service has not started yet', name: 'createGeofence');
      return;
    }

    await GeofenceForegroundService().addGeofenceZone(
      zone: Zone(
        id: 'zone#1_id',
        radius: 100, // measured in meters
        coordinates: [_londonCityCenter],
        notificationResponsivenessMs: 15 * 1000, // 15 seconds
      ),
    );
  }

  Future<void> _createTimesSquarePolygonGeofence() async {
    if (!_hasServiceStarted) {
      log('Service has not started yet', name: 'createGeofence');
      return;
    }

    await GeofenceForegroundService().subscribeToLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin'),
          actions: [
            IconButton(
                onPressed: () async {
                  locations = await StorageService.getList();
                  setState(() {});
                },
                icon: const Icon(Icons.electric_bolt)),
            IconButton(onPressed: _createLondonGeofence, icon: const Icon(Icons.add)),
            IconButton(onPressed: _createTimesSquarePolygonGeofence, icon: const Icon(Icons.add_box_outlined)),
          ],
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(locations[index]),
              minVerticalPadding: 0,
              contentPadding: EdgeInsets.zero,
              minTileHeight: 20,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: locations.length,
        ),
      ),
    );
  }
}
