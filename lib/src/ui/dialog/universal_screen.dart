import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../static/app_colors.dart';

class UniversalScreen extends StatefulWidget {
  final String title;
  final String uri;

  UniversalScreen({
    required this.title,
    required this.uri,
  });

  @override
  State<StatefulWidget> createState() {
    return _UniversalScreenState();
  }
}

class _UniversalScreenState extends State<UniversalScreen> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
        backgroundColor: AppColors.white,
        leading: GestureDetector(
          child: Container(
            height: 56,
            width: 56,
            color: AppColors.white,
            padding: EdgeInsets.all(13),
            child: SvgPicture.asset("assets/icons/arrow_left_blue.svg"),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontFamily: AppColors.fontRubik,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.2,
                color: AppColors.text_dark,
              ),
            ),
          ],
        ), systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: WebView(
            initialUrl: widget.uri,
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: true,
          ),
        ),
      ),
    );
  }
}
