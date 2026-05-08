import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleDriveService {
  GoogleDriveService(this._driveApi);

  final drive.DriveApi _driveApi;
  static const _fileName = 'sync_data.json.gz';

  Future<drive.File?> _getSyncFile() async {
    final fileList = await _driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_fileName'",
      $fields: 'files(id, name, headRevisionId)',
    );

    return fileList.files?.firstOrNull;
  }

  Future<String?> downloadData() async {
    try {
      final file = await _getSyncFile();
      if (file == null || file.id == null) {
        return null; // File doesn't exist yet
      }

      final mediaStream = await _driveApi.files.get(
        file.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytesBuilder = BytesBuilder();
      await for (final chunk in mediaStream.stream) {
        bytesBuilder.add(chunk);
      }
      final bytes = bytesBuilder.takeBytes();
      
      // Decompress GZIP
      final decodedBytes = GZipDecoder().decodeBytes(bytes);
      final jsonString = utf8.decode(decodedBytes);

      return jsonString;
    } catch (e) {
      // Ignored in prod
      rethrow;
    }
  }

  Future<void> uploadData(String jsonString) async {
    try {
      // Compress with GZIP
      final bytes = utf8.encode(jsonString);
      final compressedBytes = GZipEncoder().encode(bytes);
      final media = drive.Media(
        Stream.value(compressedBytes),
        compressedBytes.length,
      );

      final existingFile = await _getSyncFile();

      if (existingFile != null && existingFile.id != null) {
        // Update existing file
        final file = drive.File()..name = _fileName;
        await _driveApi.files.update(
          file,
          existingFile.id!,
          uploadMedia: media,
        );
      } else {
        // Create new file in appDataFolder
        final file = drive.File()
          ..name = _fileName
          ..parents = ['appDataFolder'];
        await _driveApi.files.create(
          file,
          uploadMedia: media,
        );
      }
    } catch (e) {
      // Ignored in prod
      rethrow;
    }
  }

  Future<bool> deleteData() async {
    final file = await _getSyncFile();
    if (file == null || file.id == null) {
      return false;
    }

    await _driveApi.files.delete(file.id!);
    return true;
  }
}
