import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String locationAccuracy = 'Low'; // Corrected value: 'Low'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Geolocator Settings
          ExpansionTile(
            title: const Text('Geolocator Settings'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Text('Set Location Accuracy '),
                            const Gap(10), // Set Location Accuracy
                            DropdownButton<String>(
                              value: locationAccuracy,
                              items: const [
                                DropdownMenuItem(
                                  value: '1',
                                  child: Text('Low'),
                                ),
                                DropdownMenuItem(
                                  value: '2',
                                  child: Text('Medium'),
                                ),
                                DropdownMenuItem(
                                  value: '3',
                                  child: Text('High'),
                                ),
                              ],
                              onChanged: (String? value) {
                                setState(() {
                                  locationAccuracy = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Accelerometer Settings
          ExpansionTile(
            title: const Text('Accelerometer Settings'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            children: [
              ListTile(
                title: const Text('Accelerometer Settings'),
                onTap: () {
                  // Navigate to Accelerometer Settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
