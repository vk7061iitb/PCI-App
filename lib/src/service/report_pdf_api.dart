import 'dart:io';
import 'package:pciapp/Objects/data.dart';
import 'package:share_plus/share_plus.dart';
import '../config/config.dart';
import 'package:http/http.dart' as http;

/// A class responsible for generating reports in PDF format.
///
/// This class provides methods to create and manage PDF reports
/// for the PCI App. It handles the formatting, content generation,
/// and saving of the PDF files.
///
class GenerateReport {
  GenerateReport() : sendBaseURL = Config.getAuthBaseURL();
  final String sendBaseURL;
  int statusCode = 0;
  Future<String> generateReport({
    required String filename,
  }) async {
    String url = "$sendBaseURL${Config.reportPdfEndPoint}";
    try {
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Roadname': filename,
          'Accept': '*/*',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          return http.Response('Server took too long to respond', 408);
        },
      );

      statusCode = response.statusCode;

      if (response.statusCode == 200) {
        final responseData = response.bodyBytes;
        _saveNshareReport(
          filename: filename,
          responseData: responseData,
        );
        return 'Report generated successfully';
      } else {
        logger.f('Failed to send data. Status code: ${response.statusCode}');
        logger.d('Response body: ${response.body}');
        return 'Failed to generate report : ${response.body}';
      }
    } catch (e) {
      logger.f(e.toString());
      return 'Failed to generate report : $e';
    }
  }
}

void _saveNshareReport({
  required String filename,
  required List<int> responseData,
}) async {
  try {
    final reportDirectory = await localDatabase.getReportDir();
    final file = File('$reportDirectory/$filename.pdf');
    await file.writeAsBytes(responseData);
    logger.i('PDF file saved to: ${file.path}');
    XFile fileToShare = XFile(file.path);
    fileToShare.readAsBytes();
    final shareResult = await Share.shareXFiles([fileToShare]);
    if (shareResult.status == ShareResultStatus.success) {
      logger.i('PDF file shared');
    } else {
      logger.e('Failed to share PDF file');
    }
  } catch (e) {
    logger.e(e.toString());
  }
}
