import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pharmacy/src/blocs/menu_bloc.dart';
import 'package:pharmacy/src/model/api/cash_back_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/ui/main/card/card_screen.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../static/app_colors.dart';

class MenuScreen extends StatefulWidget {
  final Function onChat;
  final Function onMyInfo;
  final Function onLogin;
  final Function onHistory;
  final Function onAddress;
  final Function onLanguage;
  final Function onRate;
  final Function onFaq;
  final Function onAbout;
  final Function onExit;

  MenuScreen({
    required this.onChat,
    required this.onLogin,
    required this.onHistory,
    required this.onAddress,
    required this.onLanguage,
    required this.onRate,
    required this.onFaq,
    required this.onAbout,
    required this.onMyInfo,
    required this.onExit,
  });

  @override
  State<StatefulWidget> createState() {
    return _MenuScreenState();
  }
}

class _MenuScreenState extends State<MenuScreen> {
  String language = "";
  String languageData = "";
  String fullName = "";
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    _registerBus();
    _getInfo();
    super.initState();
  }

  @override
  void dispose() {
    RxBus.destroy();
    super.dispose();
  }

  CashBackModel? cashBackOptions;

  @override
  Widget build(BuildContext context) {
    Utils.isLogin().then((value) => isLogin = value);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4.0,
        shadowColor: Color.fromRGBO(110, 120, 146, 0.1),
        backgroundColor: AppColors.white,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              translate("menu.name"),
              style: TextStyle(
                fontFamily: AppColors.fontRubik,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.2,
                color: AppColors.text_dark,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          isLogin
              ? StreamBuilder(
                  stream: menuBack.cashBackOptions,
                  builder: (context, AsyncSnapshot<CashBackModel> snapshot) {
                    if (snapshot.hasData || cashBackOptions != null) {
                      if (snapshot.hasData) {
                        cashBackOptions = snapshot.data;
                      }
                      Utils.saveCashBack(cashBackOptions!.cash);
                      return Container(
                        margin: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              color: AppColors.white,
                              child: Image.asset(
                                "assets/img/menu_image.png",
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    translate("menu.my_ball"),
                                    style: TextStyle(
                                      fontFamily: AppColors.fontRubik,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                      height: 1.2,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    priceFormat.format(cashBackOptions!.bonus) +
                                        translate("ball"),
                                    style: TextStyle(
                                      fontFamily: AppColors.fontRubik,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      height: 1.2,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container(
                      margin: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            color: AppColors.white,
                            child: Image.asset(
                              "assets/img/menu_image.png",
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  translate("menu.my_ball"),
                                  style: TextStyle(
                                    fontFamily: AppColors.fontRubik,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    height: 1.2,
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "",
                                  style: TextStyle(
                                    fontFamily: AppColors.fontRubik,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    height: 1.2,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Container(
                  margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF70B2FF),
                          Color(0xFF5C9CE6),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          translate("menu.login_title"),
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.onLogin();
                          },
                          child: Container(
                            height: 44,
                            margin: EdgeInsets.only(top: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                translate("menu.login"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  height: 1.42,
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
          Container(
            margin: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                    left: 24,
                    right: 24,
                  ),
                  child: Text(
                    translate("menu.all"),
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.2,
                      color: AppColors.text_dark,
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: AppColors.background,
                ),
                GestureDetector(
                  onTap: () {
                    if (isLogin) {
                      widget.onMyInfo();
                    } else {
                      widget.onLogin();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/profile.svg",
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translate("menu.user_info"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.43,
                                  color: AppColors.text_dark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                isLogin ? fullName : translate("menu.user"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  height: 1.67,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        SvgPicture.asset(
                          "assets/icons/arrow_right_grey.svg",
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                isLogin
                    ? GestureDetector(
                        onTap: () {
                          widget.onHistory();
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/history.svg",
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translate("menu.history_title"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        height: 1.43,
                                        color: AppColors.text_dark,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      translate("menu.history_message"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        height: 1.67,
                                        color: AppColors.textGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              SvgPicture.asset(
                                "assets/icons/arrow_right_grey.svg",
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                isLogin
                    ? GestureDetector(
                        onTap: () {
                          widget.onAddress();
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/location.svg",
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translate("menu.my_address_title"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        height: 1.43,
                                        color: AppColors.text_dark,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      translate("menu.my_address_message"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        height: 1.67,
                                        color: AppColors.textGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              SvgPicture.asset(
                                "assets/icons/arrow_right_grey.svg",
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 16),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                    left: 24,
                    right: 24,
                  ),
                  child: Text(
                    translate("menu.settings"),
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.2,
                      color: AppColors.text_dark,
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: AppColors.background,
                ),
                GestureDetector(
                  onTap: () {
                    widget.onLanguage();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/language.svg",
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translate("menu.language"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.43,
                                  color: AppColors.text_dark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                language,
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  height: 1.67,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        SvgPicture.asset(
                          "assets/icons/arrow_right_grey.svg",
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                    left: 24,
                    right: 24,
                  ),
                  child: Text(
                    translate("menu.other"),
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.2,
                      color: AppColors.text_dark,
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: AppColors.background,
                ),
                GestureDetector(
                  onTap: () {
                    widget.onRate();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/rate.svg",
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translate("menu.feedback_title"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.43,
                                  color: AppColors.text_dark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                translate("menu.feedback_message"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  height: 1.67,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        SvgPicture.asset(
                          "assets/icons/arrow_right_grey.svg",
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                isLogin
                    ? GestureDetector(
                        onTap: () {
                          widget.onChat();
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/faq.svg",
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translate("menu.chat"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        height: 1.43,
                                        color: AppColors.text_dark,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      translate("menu.chat_title"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        height: 1.67,
                                        color: AppColors.textGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              SvgPicture.asset(
                                "assets/icons/arrow_right_grey.svg",
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                GestureDetector(
                  onTap: () {
                    widget.onFaq();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/info_circle.svg",
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translate("menu.qus_title"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.43,
                                  color: AppColors.text_dark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                translate("menu.qus_message"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  height: 1.67,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        SvgPicture.asset(
                          "assets/icons/arrow_right_grey.svg",
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.onAbout();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/about_app.svg",
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translate("menu.about_title"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.43,
                                  color: AppColors.text_dark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                translate("menu.about_message"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  height: 1.67,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        SvgPicture.asset(
                          "assets/icons/arrow_right_grey.svg",
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    var url = "tel:712050888";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/phone_grey.svg",
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "+998 (71) 205-0-888",
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.43,
                                  color: AppColors.text_dark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                translate("menu.call_center"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  height: 1.67,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        SvgPicture.asset(
                          "assets/icons/arrow_right_grey.svg",
                          width: 24,
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          isLogin
              ? Container(
                  margin: EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.onExit();
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/exit.svg",
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translate("menu.exit"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        height: 1.43,
                                        color: AppColors.text_dark,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      translate("menu.exit_message"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        height: 1.67,
                                        color: AppColors.textGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              SvgPicture.asset(
                                "assets/icons/arrow_right_grey.svg",
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                )
              : Container(),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _setLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var lan = prefs.getString('language') ?? "ru";
    setState(() {
      var localizationDelegate = LocalizedApp.of(context).delegate;
      localizationDelegate.changeLocale(Locale(lan));
    });
  }

  void _registerBus() {
    RxBus.register<bool>(tag: "LOGIN_PROFILE").listen((event) {
      _getInfo();
      menuBack.fetchCashBack();
    });

    RxBus.register<BottomView>(tag: "MENU_VIEW").listen((event) {
      if (event.title) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 270),
          curve: Curves.easeInOut,
        );
      }
    });

    RxBus.register<BottomView>(tag: "MENU_VIEW_NOTIFY_SCREEN").listen((event) {
      if (event.title) {
        _getInfo();
        _setLanguage();
      }
    });
  }

  Future<void> _getInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var lan = prefs.getString('language') ?? "ru";
      if (lan == "ru")
        language = "Русский";
      else if (lan == "uz")
        language = "O'zbekcha";
      else if (lan == "en") language = "English";
      var name = prefs.getString("name");
      var surName = prefs.getString("surname");
      if (name != null && surName != null) {
        fullName = name + " " + surName;
      }
    });
  }
}
