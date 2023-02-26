
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (dynamic error, dynamic stack) {
    developer.log("Something went wrong!", error: error, stackTrace: stack);
  });
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, Map<String, dynamic>> _groupedData = <String,
      Map<String, dynamic>>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    if (Platform.isAndroid) {
      deviceData =
          _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    }

    _groupData(deviceData);

    if (!mounted) return;
  }

  void _groupData(Map<String, dynamic> deviceData) {
    final List<String> categories = <String>[
      'Version',
      'Build',
      'Display',
      'Hardware',
      'Manufacturer',
      'Device',
      'Product',
      'Abis',
      'Display Metrics',
    ];

    final Map<String, Map<String, dynamic>> groupedData =
    <String, Map<String, dynamic>>{};

    for (final category in categories) {
      groupedData[category] = <String, dynamic>{};
    }

    for (final key in deviceData.keys) {
      if (key.startsWith('version.')) {
        groupedData['Version']![key] = deviceData[key];
      } else if (key.startsWith('build.')) {
        groupedData['Build']![key] = deviceData[key];
      } else if (key.startsWith('display.')) {
        groupedData['Display']![key] = deviceData[key];
      } else
      if (key == 'hardware' || key == 'manufacturer' || key == 'device' ||
          key == 'product') {
        groupedData['Hardware']![key] = deviceData[key];
      } else if (key == 'supportedAbis' || key == 'supported32BitAbis' ||
          key == 'supported64BitAbis') {
        groupedData['Abis']![key] = deviceData[key];
      } else if (key.startsWith('displayMetrics.')) {
        groupedData['Display Metrics']![key] = deviceData[key];
      }
    }

    setState(() {
      _groupedData = groupedData;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true, // Align title to the middle
          backgroundColor: Colors.black, // Change background to black
          title: Text(
              'Android Device Info'
          ),
        ),
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset(
                  'asset/gear.png',
                  height: 50,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _groupedData.keys.length,
                itemBuilder: (BuildContext context, int index) {
                  final category = _groupedData.keys.elementAt(index);
                  final data = _groupedData[category]!;
                  return ExpansionTile(
                    title: Text(category),
                    children: data.keys.map((property) {
                      return ListTile(
                        title: Text(property),
                        subtitle: Text('${data[property]}'),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
      ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
      'serialNumber': build.serialNumber,
    };
  }

}
