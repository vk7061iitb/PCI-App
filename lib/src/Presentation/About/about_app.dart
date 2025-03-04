import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.05 * w),
          child: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                    fontSize: 16.0, color: Colors.black, height: 1.5),
                children: [
                  TextSpan(
                    text: 'Welcome to the PCI App\n\n',
                    style: GoogleFonts.inter(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                        'Being developed jointly by Unnat Maharashtra Abhiyan, IIT Bombay and Zilla Parishad, Ratnagiri.\n\n',
                  ),
                  TextSpan(
                    text: 'Overview\n',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                        'The project uses the Android smartphone as its basic platform. By utilizing in-built smartphone sensors such as accelerometers and GPS, along with textual inputs like pothole counts, PCI App aims to compute the Pavement Condition Index (PCI). The PCI will serve as a crucial parameter for informing both the engineer as well as the citizen about the quality of the road.\n\n',
                  ),
                  TextSpan(
                    text: 'Goals\n',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildBulletPoint(
                      'Develop software to gather sensor data systematically.'),
                  _buildBulletPoint(
                      'Formulate a data model to relate raw sensor data to the PCI.'),
                  _buildBulletPoint(
                      'Automate the assessment of road pavement conditions.'),
                  _buildBulletPoint(
                      'Develop a mobile app for data collection.'),
                  _buildBulletPoint(
                      'Create a central database for storage and analysis.'),
                  TextSpan(
                    text: '\nHow it Works\n',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildSubheading('Data Collection:'),
                  const TextSpan(
                    text:
                        ' The mobile app will utilize smartphone sensors to collect data on road conditions. This includes accelerometer data for detecting vibrations and GPS data for location tracking.\n',
                  ),
                  _buildSubheading(
                      'Pavement Condition Index (PCI) Computation:'),
                  const TextSpan(
                    text:
                        ' By processing the collected data, SmartRoads will compute the PCI, providing a quantitative measure of road pavement conditions.\n',
                  ),
                  _buildSubheading('Database Management:'),
                  const TextSpan(
                    text:
                        ' A central database will be created to store the collected data. This database will facilitate analysis and decision-making processes.\n',
                  ),
                  _buildSubheading('Analysis and Decision Making:'),
                  const TextSpan(
                    text:
                        ' With the computed PCI, authorities can make informed decisions regarding budget allocation and road maintenance strategies. This will lead to more efficient and effective road infrastructure management.\n\n',
                  ),
                  TextSpan(
                    text: 'Benefits\n',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildBulletPoint(
                      'Efficiency: Automation streamlines the assessment process, saving time and resources.'),
                  _buildBulletPoint(
                      'Accuracy: Utilizing smartphone sensors ensures accurate data collection and analysis.'),
                  _buildBulletPoint(
                      'Informed Decision Making: The PCI serves as a reliable metric for prioritizing road maintenance efforts.'),
                  _buildBulletPoint(
                    'Cost-Effectiveness: By targeting areas with the highest PCI, resources can be allocated more effectively, maximizing impact while minimizing costs.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static TextSpan _buildBulletPoint(String text) {
    return TextSpan(
      text: '\u2022 $text\n',
      style: GoogleFonts.inter(fontSize: 16.0, height: 1.5),
    );
  }

  static TextSpan _buildSubheading(String text) {
    return TextSpan(
      text: '$text ',
      style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.bold),
    );
  }
}
