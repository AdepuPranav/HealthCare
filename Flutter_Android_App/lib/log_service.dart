import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LogService {
  static Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _getLogFile() async {
    final path = await _getLocalPath();
    return File('$path/chat_log.txt');
  }

  static Future<void> appendLog(String message) async {
    final file = await _getLogFile();
    final now = DateTime.now().toLocal().toString();
    await file.writeAsString("[$now] $message\n", mode: FileMode.append);
  }

  static Future<String> readLogs() async {
    final file = await _getLogFile();
    return await file.readAsString();
  }

  static Future<void> clearLogs() async {
    final file = await _getLogFile();
    await file.writeAsString("");
  }
}
