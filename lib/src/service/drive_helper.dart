import 'package:googleapis/drive/v3.dart';
import 'package:pciapp/src/service/google_drive_api.dart' as gdrive;
import 'package:googleapis/drive/v3.dart' as googleapi;
import 'package:http/http.dart' as http;
import '../../Objects/data.dart';
import 'dart:io' as io;

class DriveHelper {
  gdrive.GoogleDriveApiService googleDriveApiService =
      gdrive.GoogleDriveApiService();

  Future<void> listFiles() async {
    final http.Client? client = await googleDriveApiService.getClient();
    if (client == null) {
      return;
    }
    final DriveApi driveApi = DriveApi(client);
    var response = await driveApi.files.list(
      q: "trashed = false",
      spaces: 'drive',
      $fields: 'id, name',
    );
    logger.d(response.toJson());
    for (var file in response.files!) {
      logger.d('File: ${file.name} (${file.id})');
    }
  }

  // create the pciapp folder to store the data
  Future<String?> createAppFolder() async {
    final http.Client? client = await googleDriveApiService.getClient();
    if (client == null) {
      return null;
    }
    String? folderID;
    String folderName = "pciapp";
    final DriveApi driveApi = DriveApi(client);
    try {
      final driveFiles = await driveApi.files.list(
        q: "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
        $fields: 'files(id, name)',
      );
      if (driveFiles.files != null && driveFiles.files!.isNotEmpty) {
        folderID = driveFiles.files!.first.id;
      }
      if (folderID != null && folderID.isNotEmpty) {
        logger.i("Folder $folderName already exists!");
        logger.d("Folder ID : $folderID");
        return folderID;
      }

      final folder = googleapi.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder';
      folder.parents = ['root'];
      googleapi.File file = await driveApi.files.create(
        folder,
        enforceSingleParent: true,
        $fields: 'id, name',
      );
      return file.driveId;
    } catch (error, stackTrace) {
      logger.f(error);
      logger.d(stackTrace);
      return folderID;
    }
  }

  // create other folder with parent
  Future<String?> createFolder(String folderName, String parentID) async {
    final http.Client? client = await googleDriveApiService.getClient();
    if (client == null) {
      return null;
    }
    String? folderID;
    final DriveApi driveApi = DriveApi(client);
    final driveFiles = await driveApi.files.list(
      q: "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      $fields: 'files(id, name)',
    );
    if (driveFiles.files != null && driveFiles.files!.isNotEmpty) {
      folderID = driveFiles.files!.first.id;
    }
    if (folderID != null && folderID.isNotEmpty) {
      logger.i("Folder $folderName already exists!");
      logger.d("Folder ID : $folderID");
      return folderID;
    }

    final folder = googleapi.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';
    folder.parents = [parentID];
    googleapi.File file = await driveApi.files.create(
      folder,
      enforceSingleParent: true,
      $fields: 'id, name',
    );
    return file.driveId;
  }

  Future<String?> uploadJourneyData(
      io.File journeyFile, String parentID, String fileName) async {
    final http.Client? client = await googleDriveApiService.getClient();
    if (client == null) {
      return null;
    }
    if (parentID.isEmpty || fileName.isEmpty) {
      return null;
    }
    googleapi.File file = googleapi.File();
    try {
      final DriveApi driveApi = DriveApi(client);
      googleapi.File jFile = googleapi.File();
      jFile.parents = [parentID];
      jFile.name = '$fileName.json';
      file = await driveApi.files.create(
        jFile,
        uploadMedia: googleapi.Media(
          journeyFile.openRead(),
          journeyFile.lengthSync(),
        ),
      );
      logger.i("Journey $fileName added to drive. with 'id' : ${file.id}");
      return file.id;
    } catch (error, stackTrace) {
      logger.f(error);
      logger.d(stackTrace);
    }
    return file.driveId;
  }
}
