import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/model/api/auth/login_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/dialog/top_dialog.dart';
import 'package:pharmacy/src/ui/main/card/card_screen.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:pharmacy/src/widget/date_picker/data/i18n_model.dart';
import 'package:pharmacy/src/widget/date_picker/flutter_datetime_picker.dart';

import '../../static/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  final int id;
  final String token;
  final String number;

  RegisterScreen(
    this.id,
    this.token,
    this.number,
  );

  @override
  State<StatefulWidget> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  var loading = false;
  var isNext = false;

  TextEditingController surNameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();

  int id = 1;
  String birthday = "";
  DateTime dateTime = new DateTime.now();

  @override
  void initState() {
    var number = "+";
    for (int i = 0; i < widget.number.length; i++) {
      number += widget.number[i];
      if (i == 2 || i == 4 || i == 7 || i == 9) {
        number += " ";
      }
    }
    numberController.text = number;
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
            translate("auth.register_title"),
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
        children: [
          ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Text(
                  translate("auth.name"),
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
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontFamily: AppColors.fontRubik,
                    fontWeight: FontWeight.normal,
                    color: AppColors.text_dark,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  maxLength: 35,
                  controller: nameController,
                  onChanged: (value) {
                    if (birthday.length > 0 &&
                        nameController.text.length > 0 &&
                        surNameController.text.length > 0) {
                      setState(() {
                        isNext = true;
                      });
                    } else {
                      setState(() {
                        isNext = false;
                      });
                    }
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
                  top: 16,
                ),
                child: Text(
                  translate("auth.last_name"),
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
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontFamily: AppColors.fontRubik,
                    fontWeight: FontWeight.normal,
                    color: AppColors.text_dark,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  maxLength: 35,
                  controller: surNameController,
                  onChanged: (value) {
                    if (birthday.length > 0 &&
                        nameController.text.length > 0 &&
                        surNameController.text.length > 0) {
                      setState(() {
                        isNext = true;
                      });
                    } else {
                      setState(() {
                        isNext = false;
                      });
                    }
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
                  top: 16,
                ),
                child: Text(
                  translate("auth.number"),
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
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  keyboardType: TextInputType.phone,
                  readOnly: true,
                  style: TextStyle(
                    fontFamily: AppColors.fontRubik,
                    fontWeight: FontWeight.normal,
                    color: AppColors.text_dark,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  maxLength: 35,
                  controller: numberController,
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
                  top: 16,
                ),
                child: Text(
                  translate("auth.birthday"),
                  style: TextStyle(
                    fontFamily: AppColors.fontRubik,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    height: 1.2,
                    color: AppColors.textGray,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: DateTime(1900, 2, 16),
                    maxTime: DateTime.now(),
                    onConfirm: (date) {
                      dateTime = date;
                      var month = date.month < 10
                          ? "0" + date.month.toString()
                          : date.month.toString();
                      var day = date.day < 10
                          ? "0" + date.day.toString()
                          : date.day.toString();
                      birthdayController.text =
                          day + "." + month + "." + date.year.toString();

                      birthday = date.year.toString() + "-" + month + "-" + day;
                      if (birthday.length > 0 &&
                          nameController.text.length > 0 &&
                          surNameController.text.length > 0) {
                        setState(() {
                          isNext = true;
                        });
                      } else {
                        setState(() {
                          isNext = false;
                        });
                      }
                    },
                    currentTime: dateTime,
                    locale: LocaleType.ru,
                  );
                },
                child: Container(
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
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IgnorePointer(
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      readOnly: true,
                      style: TextStyle(
                        fontFamily: AppColors.fontRubik,
                        fontWeight: FontWeight.normal,
                        color: AppColors.text_dark,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLength: 35,
                      controller: birthdayController,
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
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Text(
                  translate("auth.gender"),
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
                width: double.infinity,
                margin: EdgeInsets.only(
                  top: 12,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (id != 1)
                            setState(() {
                              id = 1;
                            });
                        },
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 270),
                              curve: Curves.easeInOut,
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                color: Color(0xFFF4F5F7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      id == 1 ? AppColors.blue : AppColors.gray,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 270),
                                  curve: Curves.easeInOut,
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: id == 1
                                        ? AppColors.blue
                                        : Color(0xFFF4F5F7),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              translate("auth.male"),
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                fontFamily: AppColors.fontRubik,
                                color: AppColors.text_dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (id != 2)
                            setState(() {
                              id = 2;
                            });
                        },
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 270),
                              curve: Curves.easeInOut,
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                color: Color(0xFFF4F5F7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      id == 2 ? AppColors.blue : AppColors.gray,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 270),
                                  curve: Curves.easeInOut,
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: id == 2
                                        ? AppColors.blue
                                        : Color(0xFFF4F5F7),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              translate("auth.female"),
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                fontFamily: AppColors.fontRubik,
                                color: AppColors.text_dark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(child: Container()),
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
                String gender = id == 1 ? "man" : "woman";
                if (nameController.text.isNotEmpty &&
                    surNameController.text.isNotEmpty &&
                    birthday.isNotEmpty) {
                  setState(() {
                    loading = true;
                  });
                  var response = await Repository().fetchRegister(
                    nameController.text.toString(),
                    surNameController.text.toString(),
                    birthday,
                    gender,
                    widget.token,
                    fcToken,
                  );

                  if (response.isSuccess) {
                    var result = LoginModel.fromJson(response.result);
                    if (result.status == 1) {
                      isLogin = true;
                      Utils.saveData(
                        widget.id,
                        nameController.text.toString(),
                        surNameController.text.toString(),
                        birthday,
                        gender,
                        widget.token,
                        widget.number,
                      );
                      RxBus.post(true, tag: "LOGIN_PROFILE");
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      setState(() {
                        loading = false;
                      });
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
                      loading = false;
                      TopDialog.errorMessage(
                        context,
                        translate("internet_error"),
                      );
                    });
                  } else {
                    setState(() {
                      loading = false;
                      TopDialog.errorMessage(
                        context,
                        response.result["msg"],
                      );
                    });
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
                          translate("auth.sign_up"),
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppColors.fontRubik,
                            fontSize: 17,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
