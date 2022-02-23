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
    Fimber.plantTree(DebugTree());
  }

  Future<File?> download(String url) async {
    try {
      var storageDir = await getExternalStorageDirectory();
      // String storagePath = storageDir!.path;
      // File file = File('$storagePath/houji.apk');

      // if (!file.existsSync()) {
      //   file.createSync();
      // }

      if (await Permission.storage.request().isGranted) {
        //权限通过
        Fimber.i("permission granted");
      } else {
        Fimber.e("permission not granted");
      }

      Fimber.i("url: $url");
      // String savePath = "${storageDir?.path}/houji.apk";
      String savePath = "${storageDir?.path}/bgm.mp3";
      Fimber.i("savePath: $savePath");
      var response = await _dio?.download(url, savePath,
          // options:
          //     Options(responseType: ResponseType.bytes, followRedirects: false),
          onReceiveProgress: (count, total) {
        Fimber.w("<><Downloader.download>progress: $count, $total");
      });

      File file = File(savePath);
      if (await file.exists()) {
        file.delete();
        Fimber.i("<><Downloader.download>file deleted");
      }

      Fimber.i(
          "<><Downloader.download>code: ${response?.statusCode}, message: ${response?.statusMessage}, data: ${response?.data}");

      // file.writeAsBytesSync(response!.data);
      // return file;
      return null;
    } on DioError catch (e) {
      Fimber.e("<><Downloader.download>dio error: $e");
      return null;
    } catch (e) {
      Fimber.e("<><Downloader.download>unknown error: $e");
      return null;
    }
  }
}
