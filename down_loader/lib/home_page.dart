import 'dart:convert';
import 'dart:io';

import 'package:down_loader/log_file_page.dart';
import 'package:fimber_io/fimber_io.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:install_plugin/install_plugin.dart';
import 'package:package_info/package_info.dart';

import 'data.dart';
import 'downloader.dart';
import 'log_file_util.dart';
import 'package_info_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _messageNotifier = ValueNotifier<String>("点击按钮，下载并安装文件");
  final _pageStateNotifier = ValueNotifier<PageStates>(PageStates.ready);
  PackageInfo? _packageInfo;
  String? _apkFile;
  File? _file;

  Future<void> _initAsync() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: _initAsync(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10),
                  Text("version: ${_packageInfo!.version}",
                      style: Theme.of(context).textTheme.bodyText1),
                  // const SizedBox(height: 10),
                  // Text("build: 2022-02-23 18:00:00",
                  //     style: Theme.of(context).textTheme.bodyText1),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '本地版本',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              ?.copyWith(fontSize: 20),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.075),
                        Center(
                          child: ValueListenableBuilder<String>(
                            valueListenable: _messageNotifier,
                            builder: (context, value, child) => Text(
                              value,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              );
            }
          }),
      floatingActionButton: ValueListenableBuilder<PageStates>(
        valueListenable: _pageStateNotifier,
        builder: (context, value, child) => Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: value == PageStates.ready ? _compareVersion : null,
              backgroundColor:
                  value == PageStates.ready ? Colors.blue : Colors.grey,
              tooltip: 'Download',
              heroTag: "first",
              child: const Icon(Icons.compare),
            ),
            const SizedBox(width: 5),
            FloatingActionButton(
              onPressed: value == PageStates.ready ? _download : null,
              backgroundColor:
                  value == PageStates.ready ? Colors.blue : Colors.grey,
              tooltip: 'Download',
              heroTag: "second",
              child: const Icon(Icons.download),
            ),
            const SizedBox(width: 5),
            FloatingActionButton(
              onPressed: value == PageStates.ready ? _install : null,
              backgroundColor:
                  value == PageStates.ready ? Colors.blue : Colors.grey,
              tooltip: 'Install',
              heroTag: "third",
              child: const Icon(Icons.app_registration),
            ),
            const SizedBox(width: 5),
            FloatingActionButton(
              onPressed: value == PageStates.ready ? _delete : null,
              backgroundColor:
                  value == PageStates.ready ? Colors.blue : Colors.grey,
              tooltip: 'Delete',
              heroTag: "forth",
              child: const Icon(Icons.delete),
            ),
            const SizedBox(width: 5),
            FloatingActionButton(
              onPressed: _openLogFile,
              backgroundColor:
                  value == PageStates.ready ? Colors.blue : Colors.grey,
              tooltip: 'Log',
              heroTag: "fifth",
              child: const Icon(Icons.bookmark),
            ),
          ],
        ),
      ),
    );
  }

  void _openLogFile() async {
    _pageStateNotifier.value = PageStates.showLog;
    var logFileName = await getLogFileName();
    File file = File(logFileName);
    if (await file.exists()) {
      var contents = await file.readAsString();
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => LogFilePage(fileContent: contents)));
      _pageStateNotifier.value = PageStates.ready;
    }
  }

  void _compareVersion() async {
    _pageStateNotifier.value = PageStates.comparing;
    _messageNotifier.value = "";

    var result = await Downloader.instance.download("version.txt");

    await Future.delayed(const Duration(seconds: 1));
    if (result.success && result.file != null) {
      var fileContent = await result.file!.readAsString();
      var jsonMap = json.decode(fileContent);
      VersionInfo versionInfo = VersionInfo.fromJson(jsonMap);

      var isNewVersion =
          await PackageInfoUtil.isNewVersion(versionInfo.version ?? "");
      if (isNewVersion) {
        _apkFile = versionInfo.apkFile;
        _messageNotifier.value = "发现新版本:${versionInfo.version}";
      } else {
        _messageNotifier.value = "当前已是最新版本";
      }
    } else {
      _messageNotifier.value = "版本比较失败";
    }
    _pageStateNotifier.value = PageStates.ready;
  }

  void _download() async {
    if (_apkFile == null || _apkFile!.isEmpty) {
      _messageNotifier.value = "apk文件名字为空";
    }

    _pageStateNotifier.value = PageStates.downloading;
    _messageNotifier.value = "";

    var result = await Downloader.instance.download(_apkFile!,
        progressCallback: (count, total) {
      _messageNotifier.value =
          "正在下载...(${(count / (total != 0 ? total : 1) * 100).toDouble().toStringAsFixed(0)}%)";
    });

    await Future.delayed(const Duration(seconds: 1));
    if (result.success && result.file != null) {
      _file = result.file;
      _messageNotifier.value = "下载完成";
    } else {
      _messageNotifier.value = "下载失败";
    }
    _pageStateNotifier.value = PageStates.ready;
  }

  void _install() async {
    if (_file != null && await _file!.exists()) {
      _pageStateNotifier.value = PageStates.installing;
      Fimber.e("file path: ${_file!.path}");

      InstallPlugin.installApk(_file!.path, "com.example.down_loader")
          .then((result) {
        _messageNotifier.value = "安装完成";
      }).catchError((error) {
        _messageNotifier.value = "安装失败: $error";
      });
      _pageStateNotifier.value = PageStates.ready;
    } else {
      _messageNotifier.value = "文件不存在";
    }
  }

  void _delete() async {
    if (_file != null && await _file!.exists()) {
      _pageStateNotifier.value = PageStates.deleting;
      await _file!.delete();
      _pageStateNotifier.value = PageStates.ready;
      _messageNotifier.value = "已删除文件";
      Fimber.w("文件已删除");
    } else {
      _messageNotifier.value = "文件不存在";
      Fimber.w("文件不存在");
    }
  }
}

enum PageStates { ready, comparing, downloading, installing, deleting, showLog }
