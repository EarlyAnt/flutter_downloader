import 'package:package_info/package_info.dart';

class PackageInfoUtil {
  static Future<PackageInfo> getPackageInfo() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    return info;
  }

  static Future<bool> isNewVersion(String targetVersion) async {
    if (targetVersion.isEmpty) {
      return false;
    }

    var targetVersionParts = targetVersion.split('.');
    if (targetVersionParts.length != 3) {
      return false;
    }

    String currentVersion = (await PackageInfo.fromPlatform()).version;
    var currentVersionParts = currentVersion.split('.');
    if (currentVersionParts.length != 3) {
      return false;
    }

    for (int i = 0; i < targetVersionParts.length; i++) {
      if (int.parse(targetVersionParts[i]) >
          int.parse(currentVersionParts[i])) {
        return true;
      } else if (int.parse(targetVersionParts[i]) >
          int.parse(currentVersionParts[i])) {
        return false;
      }
    }
    return false;
  }
}
