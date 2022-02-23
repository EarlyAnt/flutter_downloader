import 'dart:io';

import 'package:down_loader/downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:install_plugin/install_plugin.dart';

void main() {
  Fimber.plantTree(DebugTree());
  runApp(const MyApp());
  Fimber.i("----App Run----");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'App下载与安装'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _messageNotifier = ValueNotifier<String>("点击按钮，下载并安装文件");
  final _pageStateNotifier = ValueNotifier<PageStates>(PageStates.ready);
  File? _file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10),
          Text("build: 2022-02-23 18:00:00",
              style: Theme.of(context).textTheme.bodyText1),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '本地测试版本',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      ?.copyWith(fontSize: 20),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.075),
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
      ),
      floatingActionButton: ValueListenableBuilder<PageStates>(
        valueListenable: _pageStateNotifier,
        builder: (context, value, child) => Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: value == PageStates.ready ? _download : null,
              backgroundColor:
                  value == PageStates.ready ? Colors.blue : Colors.grey,
              tooltip: 'Download',
              child: const Icon(Icons.download),
            ),
            const SizedBox(width: 5),
            FloatingActionButton(
              onPressed: value == PageStates.ready ? _install : null,
              backgroundColor:
                  value == PageStates.ready ? Colors.blue : Colors.grey,
              tooltip: 'Install',
              child: const Icon(Icons.app_registration),
            ),
            const SizedBox(width: 5),
            FloatingActionButton(
              onPressed: value == PageStates.ready ? _delete : null,
              backgroundColor:
                  value == PageStates.ready ? Colors.blue : Colors.grey,
              tooltip: 'Delete',
              child: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }

  void _download() async {
    _pageStateNotifier.value = PageStates.downloading;
    _messageNotifier.value = "";

    var result = await Downloader.instance
        .download("https://rex-qn.gululu-a.com/houji/yoyo.apk",
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
    } else {
      _messageNotifier.value = "文件不存在";
    }
  }
}

enum PageStates { ready, downloading, installing, deleting }
