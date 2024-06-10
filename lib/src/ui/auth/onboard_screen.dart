import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:pharmacy/src/static/app_colors.dart';
import 'package:pharmacy/src/ui/login_region_screen.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoarding extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OnBoardingState();
  }
}

class _OnBoardingState extends State<OnBoarding> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  PageController controller = PageController();
  var currentPageValue = 0.0;
  int currentIndex = 0;

  List<String> image = [
    "1.png",
    "2.png",
    "3.png",
    "4.png",
    "5.png",
  ];

  @override
  void initState() {
    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page!;
        if (controller.page! >= 0.0 && controller.page! < 0.5) {
          currentIndex = 0;
        } else if (controller.page! >= 0.5 && controller.page! < 1.5) {
          currentIndex = 1;
        } else if (controller.page! >= 1.5 && controller.page! < 2.5) {
          currentIndex = 2;
        } else if (controller.page! >= 2.5 && controller.page! < 3.5) {
          currentIndex = 3;
        } else if (controller.page! >= 3.5 && controller.page! < 4.5) {
          currentIndex = 4;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initPlatformState(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              right: 24,
              top: 42,
            ),
            child: GestureDetector(
              onTap: () {
                Utils.saveFirstOpen("yes");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginRegionScreen(),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Пропустить",
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.2,
                      color: AppColors.textGray,
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/icons/arrow_right_grey.svg",
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 32,
              left: 24,
              right: 24,
            ),
            width: double.infinity,
            child: currentIndex == 0
                ? Text(
                    "Добро пожаловать",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                      height: 1.2,
                      color: AppColors.text_dark,
                    ),
                  )
                : currentIndex == 1
                    ? Text(
                        "Широкий ассортимент ",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      )
                    : currentIndex == 2
                        ? Text(
                            "Быстрая доставка",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                              height: 1.2,
                              color: AppColors.text_dark,
                            ),
                          )
                        : currentIndex == 3
                            ? Text(
                                "Поиск аптек",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24,
                                  height: 1.2,
                                  color: AppColors.text_dark,
                                ),
                              )
                            : Text(
                                "Бонусная программа",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 24,
                                  height: 1.2,
                                  color: AppColors.text_dark,
                                ),
                              ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 16,
              left: 24,
              right: 24,
            ),
            width: double.infinity,
            child: currentIndex == 0
                ? Text(
                    "В GoPharm - интернет аптека с доставкой по Узбекистану",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      height: 1.6,
                      color: AppColors.textGray,
                    ),
                  )
                : currentIndex == 1
                    ? Text(
                        "Более 12 000 видов препаратов находятся в онлайн аптеке Go Pharm",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          height: 1.6,
                          color: AppColors.textGray,
                        ),
                      )
                    : currentIndex == 2
                        ? Text(
                            "Заказ доставляется до вашего дома или офиса в кратчайщие сроки",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              height: 1.6,
                              color: AppColors.textGray,
                            ),
                          )
                        : currentIndex == 3
                            ? Text(
                                "Благодаря приложению, вы легко можете определить ближайщую аптеку для вас",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  height: 1.6,
                                  color: AppColors.textGray,
                                ),
                              )
                            : Text(
                                "Зарабатывай баллы от каждой сделанной покупки через наше приложение",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  height: 1.6,
                                  color: AppColors.textGray,
                                ),
                              ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 16),
              child: PageView.builder(
                controller: controller,
                itemBuilder: (context, position) {
                  if (position == currentPageValue.floor()) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..rotateX(currentPageValue - position),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.asset(
                            "assets/img/${image[position]}",
                            width: MediaQuery.of(context).size.width - 48,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    );
                  } else if (position == currentPageValue.floor() + 1) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..rotateX(currentPageValue - position),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.asset(
                            "assets/img/${image[position]}",
                            width: MediaQuery.of(context).size.width - 48,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
                itemCount: 5,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              bottom: 24,
              top: 24,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildIndicator(),
            ),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.background,
          ),
          GestureDetector(
            onTap: () {
              if (currentIndex == 0) {
                setState(() {
                  currentIndex = 1;
                  controller.animateToPage(
                    1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  // _pageController.jumpToPage(1);
                });
              } else if (currentIndex == 1) {
                setState(() {
                  currentIndex = 2;
                  controller.animateToPage(
                    2,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  //_pageController.jumpToPage(2);
                });
              } else if (currentIndex == 2) {
                setState(() {
                  currentIndex = 3;
                  controller.animateToPage(
                    3,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  //_pageController.jumpToPage(2);
                });
              } else if (currentIndex == 3) {
                setState(() {
                  currentIndex = 4;
                  controller.animateToPage(
                    4,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  //_pageController.jumpToPage(2);
                });
              } else if (currentIndex == 4) {
                Utils.saveFirstOpen("yes");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginRegionScreen(),
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.only(bottom: 24, left: 22, right: 22, top: 12),
              height: 44,
              width: double.infinity,
              child: Center(
                child: Text(
                  currentIndex == 4 ? "Начать поиск" : "Продолжить",
                  style: TextStyle(
                    fontFamily: AppColors.fontRubik,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    height: 1.25,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget makePage({image, title, content, index}) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Image.asset(
              image,
              fit: BoxFit.fitWidth,
              width: index == 0 ? 190 : MediaQuery.of(context).size.width,
              height: index == 0 ? 141 : MediaQuery.of(context).size.width,
            ),
          ),
        ),
        SizedBox(
          height: 53,
        ),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppColors.fontRubik,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            height: 1.1,
            color: AppColors.text_dark,
          ),
        ),
        Container(
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppColors.fontRubik,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
              fontSize: 14,
              height: 1.3,
              color: Color(0xFF6E80B0),
            ),
          ),
          margin: EdgeInsets.only(
            top: 16,
            left: 42,
            right: 42,
          ),
        ),
      ],
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 300),
      height: 6,
      width: isActive ? 20 : 6,
      margin: EdgeInsets.only(right: 6, left: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.blue : AppColors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  List<Widget> _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < 5; i++) {
      if (currentIndex == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }

    return indicators;
  }

  Future<void> _initPlatformState(BuildContext context) async {
    Map<String, dynamic> deviceData = {};

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("deviceData") == null) {
      try {
        if (Platform.isAndroid) {
          deviceData = _readAndroidBuildData(
            await deviceInfoPlugin.androidInfo,
            context,
          );
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(
            await deviceInfoPlugin.iosInfo,
            context,
            await FlutterUdid.udid,
          );
        }
        Utils.saveDeviceData(deviceData);
      } on PlatformException {
        deviceData = <String, dynamic>{
          'Error:': 'Failed to get platform version.'
        };
      }
    }

    if (!mounted) return;
  }

  Map<String, dynamic> _readAndroidBuildData(
      AndroidDeviceInfo build, BuildContext context) {
    return <String, dynamic>{
      'platform': "Android",
      'model': build.model,
      'systemVersion': build.version.release,
      'brand': build.brand,
      'isPhysicalDevice': build.isPhysicalDevice,
      'identifierForVendor': build.id,
      'device': build.device,
      'product': build.product,
      'version.incremental': build.version.incremental,
      'displaySize': MediaQuery.of(context).size.width.toString() +
          "x" +
          MediaQuery.of(context).size.height.toString(),
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(
    IosDeviceInfo data,
    BuildContext context,
    String udid,
  ) {
    return <String, dynamic>{
      'platform': "IOS",
      'model': data.name,
      'systemVersion': data.systemVersion,
      'brand': data.model,
      'isPhysicalDevice': data.isPhysicalDevice,
      'identifierForVendor': udid,
      'systemName': data.systemName,
      'displaySize': MediaQuery.of(context).size.width.toString() +
          "x" +
          MediaQuery.of(context).size.height.toString(),
    };
  }
}
