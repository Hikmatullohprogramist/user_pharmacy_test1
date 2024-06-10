import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/model/api/auth/login_model.dart';
import 'package:pharmacy/src/model/http_result.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/auth/verify_screen.dart';
import 'package:pharmacy/src/ui/dialog/top_dialog.dart';
import 'package:pharmacy/src/utils/mask/number_mask.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../static/app_colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  var loading = false;
  var isNext = false;
  var isPrivacy = false;
  final PhoneNumberTextInputFormatter _phoneNumber =
      new PhoneNumberTextInputFormatter();
  String captchaKey = "", captchaImage = "";
  Uint8List? bytes;

  TextEditingController loginController = TextEditingController(text: "+998 ");
  TextEditingController captchaController = TextEditingController();

  @override
  void initState() {
    _getCaptcha();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F5F7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4.0,
        shadowColor: Color.fromRGBO(110, 120, 146, 0.1),
        backgroundColor: AppColors.white,
        actions: [
          Container(
            height: 56,
            width: 56,
            color: AppColors.white,
          ),
        ],
        leading: Material(
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(56),
            ),
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(56),
              ),
              child: Center(
                child: SvgPicture.asset("assets/icons/arrow_left_blue.svg"),
              ),
            ),
          ),
          color: Colors.transparent,
        ),
        title: Center(
          child: Text(
            translate("auth.login_title"),
            style: TextStyle(
              fontFamily: AppColors.fontRubik,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 1.2,
              color: AppColors.text_dark,
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 120),
                    height: 50,
                    width: 258.0,
                    child: Center(
                      child: Image.asset(
                        "assets/img/logo.png",
                      ),
                    ),
                  ),
                ),
                captchaImage == ""
                    ? Container()
                    : Container(
                        height: 120,
                        margin: EdgeInsets.only(
                          left: 16,
                          right: 16,
                        ),
                        width: MediaQuery.of(context).size.width - 32,
                        child: Stack(
                          children: [
                            Image.memory(
                              bytes!,
                              height: 120,
                              width: MediaQuery.of(context).size.width - 32,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  _getCaptcha();
                                },
                                child: Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.text_dark
                                            .withOpacity(0.24),
                                        blurRadius: 20,
                                        spreadRadius: 0,
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(44),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/icons/refresh_icon.svg",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: Text(
                    translate("captcha"),
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.2,
                      color: AppColors.textGray,
                    ),
                  ),
                ),
                Container(
                  height: 44,
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 24,
                  ),
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      color: AppColors.text_dark,
                      fontSize: 14,
                    ),
                    maxLength: 4,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: captchaController,
                    onChanged: (value) {
                      _update();
                    },
                    decoration: InputDecoration(
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0,
                          color: AppColors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: Text(
                    translate("auth.login_number"),
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.2,
                      color: AppColors.textGray,
                    ),
                  ),
                ),
                Container(
                  height: 44,
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                  ),
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      color: AppColors.text_dark,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLength: 17,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _phoneNumber,
                    ],
                    controller: loginController,
                    onChanged: (value) {
                      _update();
                    },
                    decoration: InputDecoration(
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0,
                          color: AppColors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 0,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(32),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          isPrivacy = !isPrivacy;
                          _update();
                        },
                        child: Container(
                          height: 24,
                          width: 24,
                          color: Color(0xFFF4F5F7),
                          padding: EdgeInsets.all(3),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 270),
                            curve: Curves.easeInOut,
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: isPrivacy
                                      ? AppColors.blue
                                      : AppColors.textGray,
                                  width: 1.5,
                                ),
                                color: isPrivacy
                                    ? AppColors.blue
                                    : Color(0xFFF4F5F7)),
                            child: isPrivacy
                                ? Center(
                                    child: SvgPicture.asset(
                                      "assets/icons/check.svg",
                                    ),
                                  )
                                : Container(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            var _url = "https://gopharm.uz/offer";
                            await canLaunch(_url)
                                ? await launch(_url)
                                : throw " $_url";
                          },
                          child: Text(
                            translate("auth.privacy"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              height: 1.6,
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  width: double.infinity,
                  color: AppColors.background,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 12,
              left: 22,
              right: 22,
              bottom: 24,
            ),
            color: AppColors.white,
            child: GestureDetector(
              onTap: () async {
                if (loginController.text.isNotEmpty && isPrivacy) {
                  var number = loginController.text
                      .replaceAll('(', '')
                      .replaceAll(')', '')
                      .replaceAll('+', '')
                      .replaceAll(' ', '')
                      .replaceAll('-', '');

                  if (number.length == 12) {
                    setState(() {
                      loading = true;
                    });
                    // var response = await Repository().fetchLogin(number);
                    var response = await Repository().fetchLoginCaptcha(
                      number,
                      captchaKey,
                      captchaController.text,
                    );
                    if (response.isSuccess) {
                      var result = LoginModel.fromJson(response.result);
                      if (result.status == 1) {
                        setState(() {
                          loading = false;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyScreen(number),
                          ),
                        );
                      } else {
                        setState(() {
                          loading = false;
                          TopDialog.errorMessage(
                            context,
                            result.msg,
                          );
                        });
                      }
                    } else if (response.status == -1) {
                      setState(() {
                        TopDialog.errorMessage(
                          context,
                          translate("internet_error"),
                        );
                        loading = false;
                      });
                    } else {
                      setState(() {
                        TopDialog.errorMessage(
                          context,
                          response.result["msg"],
                        );
                        loading = false;
                      });
                    }
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: isNext ? AppColors.blue : AppColors.gray,
                ),
                height: 44,
                width: double.infinity,
                child: Center(
                  child: loading
                      ? Lottie.asset(
                          'assets/anim/white.json',
                          height: 40,
                        )
                      : Text(
                          translate("auth.next"),
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
            ),
          )
        ],
      ),
    );
  }

  _update() {
    if (loginController.text.length == 17 &&
        isPrivacy &&
        captchaController.text.length == 4) {
      setState(() {
        isNext = true;
      });
    } else {
      setState(() {
        isNext = false;
      });
    }
  }

  Future<void> _getCaptcha() async {
    HttpResult response = await Repository().fetchGetCaptcha();
    if (response.isSuccess) {
      setState(() {
        captchaImage = response.result["captcha_image"] ?? "";
        captchaKey = response.result["captcha_key"] ?? "";
        bytes = base64.decode(captchaImage);
      });
    }
  }
}
