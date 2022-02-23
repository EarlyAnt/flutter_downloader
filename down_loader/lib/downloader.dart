import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Downloader {
  static Downloader? _instance;
  static Downloader get instance {
    _instance ??= Downloader();
    return _instance!;
  }

  Dio? _dio;

  Downloader() {
    _dio = Dio();
  }

  Future<DownloadResult> download(String url,
      {Function(int, int)? progressCallback}) async {
    try {
      var storageDir = await getExternalStorageDirectory();

      if (await Permission.storage.request().isGranted) {
        //权限通过
        Fimber.i("storage permission granted");
      } else {
        Fimber.e("storage permission not granted");
      }

      Fimber.i("url: $url");
      String savePath = "${storageDir?.path}/yoyo.apk";
      Fimber.i("savePath: $savePath");

      int downloadedBytes = 0, totalBytes = 0;
      var response = await _dio?.download(url, savePath,
          onReceiveProgress: (count, total) {
        downloadedBytes = count;
        totalBytes = total;
        _refreshProgress(progressCallback, count, total);
        Fimber.w("<><Downloader.download>progress: $count, $total");
      });
      Fimber.i(
          "<><Downloader.download>code: ${response?.statusCode}, message: ${response?.statusMessage}, data: ${response?.data}, downloadedBytes: $downloadedBytes, totalBytes: $totalBytes");

      if (downloadedBytes == totalBytes) {
        return DownloadResult(success: true, file: File(savePath));
      } else {
        return DownloadResult(success: false, message: "未下载完成");
      }
    } on DioError catch (e) {
      Fimber.e("<><Downloader.download>dio error: $e");
      return DownloadResult(success: false, message: e.toString());
    } catch (e) {
      Fimber.e("<><Downloader.download>unknown error: $e");
      return DownloadResult(success: false, message: e.toString());
    }
  }

  void _refreshProgress(
      Function(int, int)? progressCallback, int count, int total) {
    try {
      progressCallback?.call(count, total);
    } catch (e) {
      Fimber.e("<><Downloader.download>progress callback error: $e");
    }
  }
}

class DownloadResult {
  bool success;
  String? message;
  File? file;

  DownloadResult({required this.success, this.message, this.file});
}
