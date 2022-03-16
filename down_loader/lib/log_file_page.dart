import 'package:flutter/material.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class LogFilePage extends StatefulWidget {
  const LogFilePage({Key? key, required this.fileContent}) : super(key: key);

  final String fileContent;

  @override
  State<LogFilePage> createState() => _LogFilePageState();
}

class _LogFilePageState extends State<LogFilePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("显示log文件"), centerTitle: true),
      body: VsScrollbar(
        controller: _scrollController,
        showTrackOnHover: true, // default false
        isAlwaysShown: true, // default false
        scrollbarFadeDuration: const Duration(
            milliseconds: 500), // default : Duration(milliseconds: 300)
        scrollbarTimeToFade: const Duration(
            milliseconds: 800), // default : Duration(milliseconds: 600)
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
            Text(widget.fileContent),
          ],
        ),
      ),
    );
  }
}
