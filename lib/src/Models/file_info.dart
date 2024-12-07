// ignore: dangling_library_doc_comments
///
/// This file contains the definition of the `FileInfo` class, which is used to store
/// metadata about saved data (raw data) in the PCI App.
///
/// The `FileInfo` class includes properties such as file name, file size, creation date,
/// and other relevant metadata that describe the saved data.
///

class FileInfo {
  final String fileName;
  String dataType;
  final String time;
  final String vehicleType;

  FileInfo({
    required this.fileName,
    required this.dataType,
    required this.time,
    required this.vehicleType,
  });
}
