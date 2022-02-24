import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'home_page.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  _SplashScreenPageState createState() {
    return _SplashScreenPageState();
  }
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final ValueNotifier<PackageInfo?> _notifier =
      ValueNotifier<PackageInfo?>(null);
  bool _fadeOver = false;

  @override
  void initState() {
    super.initState();

    _initAsync();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _fadeOver = true;
        });

        Future.delayed(const Duration(milliseconds: 1500)).then((value) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (subContext) {
            return const HomePage(title: 'App下载与安装');
          }), (route) => false);
        });
      }
    });
  }

  void _initAsync() async {
    _notifier.value = await PackageInfo.fromPlatform();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    double scale = 0.5;
    double width = screenSize.width * scale;
    double height = screenSize.height * scale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
          valueListenable: _notifier,
          builder: (context, value, child) {
            if (value == null) {
              return Container();
            } else {
              return Stack(
                children: [
                  Center(
                    child: FadeTransition(
                      opacity: _animation,
                      child: ClipOval(
                        child: Image.asset(
                          "assets/2.jpg",
                          fit: BoxFit.fill,
                          width: width,
                          height: width,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: height / 2 + 330),
                      child: Visibility(
                        visible: _fadeOver,
                        child: Text(_notifier.value!.version,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade500)),
                      ),
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
