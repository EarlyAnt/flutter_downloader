class VersionInfo {
  String? version;
  int? versionNumber;
  String? channel;
  String? apkFile;

  VersionInfo(
      {required this.version,
      this.versionNumber,
      this.channel,
      required this.apkFile});

  Map toJson() {
    Map map = {};
    map["version"] = version;
    map["versionNumber"] = versionNumber;
    map["channel"] = channel;
    map["apkFile"] = apkFile;
    return map;
  }

  factory VersionInfo.fromJson(Map json) {
    return VersionInfo(
        version: json["version"],
        versionNumber: json["versionNumber"],
        channel: json["channel"],
        apkFile: json["apkFile"]);
  }

  static VersionInfo get empty => VersionInfo(
      version: "1.0.0", versionNumber: 1, channel: "CN", apkFile: "");
}
