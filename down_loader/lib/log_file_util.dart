import 'package:path_provider/path_provider.dart';

Future<String> getLogFileName() async {
  var storageDir = await getApplicationDocumentsDirectory();
  var logFileName = "${storageDir.path}/my-Log-File.txt";
  return logFileName;
}
