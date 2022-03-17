import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class LogFilePage extends StatelessWidget {
  LogFilePage({Key? key, required this.fileContent}) : super(key: key);

  final String fileContent;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<String> _valueNotifier = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("显示log文件"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: fileContent));
              _showMessage("内容已复制");
            },
          )
        ],
      ),
      body: VsScrollbar(
        controller: _scrollController,
        showTrackOnHover: true,
        // default false
        isAlwaysShown: true,
        // default false
        scrollbarFadeDuration: const Duration(milliseconds: 500),
        // default : Duration(milliseconds: 300)
        scrollbarTimeToFade: const Duration(milliseconds: 800),
        // default : Duration(milliseconds: 600)
        style: VsScrollbarStyle(
            hoverThickness: 20.0, // default 12.0
            radius: const Radius.circular(16), // default Radius.circular(8.0)
            thickness: 20.0, // [ default 8.0 ]
            color: Theme.of(context)
                .colorScheme
                .primary // default ColorScheme Theme
            ),
        child: ListView(
          controller: _scrollController,
          children: [
            ValueListenableBuilder<String>(
                valueListenable: _valueNotifier,
                builder: (context, value, widget) {
                  return Container(
                      color: Colors.black45,
                      child: value.isEmpty
                          ? null
                          : Text(value,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.limeAccent)));
                }),
            Text(fileContent),
          ],
        ),
      ),
    );
  }

  Future<void> _showMessage(String message) async {
    _valueNotifier.value = message;
    await Future.delayed(const Duration(milliseconds: 1500));
    _valueNotifier.value = "";
  }
}
