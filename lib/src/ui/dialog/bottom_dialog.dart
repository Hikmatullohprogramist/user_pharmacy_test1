import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/static/app_colors.dart';
import 'package:pharmacy/src/blocs/card_bloc.dart';
import 'package:pharmacy/src/blocs/items_bloc.dart';
import 'package:pharmacy/src/blocs/store_block.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/database/database_helper_address.dart';
import 'package:pharmacy/src/database/database_helper_fav.dart';
import 'package:pharmacy/src/database/database_helper_history.dart';
import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/model/api/items_all_model.dart';
import 'package:pharmacy/src/model/api/location_model.dart';
import 'package:pharmacy/src/model/database/address_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view_model.dart';
import 'package:pharmacy/src/model/location_address_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/ui/shopping_curer/address/show_map_address.dart';
import 'package:pharmacy/src/utils/mask/number_mask.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:pharmacy/src/widget/date_picker/data/i18n_model.dart';
import 'package:pharmacy/src/widget/date_picker/flutter_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class BottomDialog {
  static void showWinner(BuildContext context, String text) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 375,
          padding: EdgeInsets.only(bottom: 4, left: 8, right: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
              color: AppColors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 16,
                    bottom: 8,
                  ),
                  height: 150,
                  width: 150,
                  child: Image.asset("assets/images/winner.png"),
                ),
                Text(
                  translate("winner.title"),
                  style: TextStyle(
                    fontFamily: AppColors.fontRubik,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    height: 1.65,
                    color: AppColors.text_dark,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 24, right: 24, top: 8),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textGray,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 20,
                    ),
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        translate("winner.button"),
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          height: 1.3,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static void showEditInfo(
    BuildContext context,
    String firstName,
    String lastName,
    String number,
    Function(
      String firstName,
      String lastName,
      String number,
    )
        onChanges,
  ) async {
    TextEditingController lastNameController =
        TextEditingController(text: lastName);
    TextEditingController numberController =
        TextEditingController(text: number);
    TextEditingController firstNameController =
        TextEditingController(text: firstName);

    final PhoneNumberTextInputFormatter _phoneNumber =
        new PhoneNumberTextInputFormatter();
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                height: 326,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    topLeft: Radius.circular(24),
                  ),
                  color: AppColors.white,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      height: 4,
                      width: 64,
                      decoration: BoxDecoration(
                        color: AppColors.text_dark.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Center(
                        child: Text(
                          translate("card.choose_info"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 1.2,
                            color: AppColors.text_dark,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 44,
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: 24,
                      ),
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
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
                        controller: lastNameController,
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 44,
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
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
                        controller: firstNameController,
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 44,
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: 15,
                      ),
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
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
                        controller: numberController,
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    GestureDetector(
                      onTap: () async {
                        if (numberController.text.length == 17 &&
                            firstNameController.text.length > 0 &&
                            lastNameController.text.length > 0) {
                          Navigator.pop(context);
                          onChanges(firstNameController.text,
                              lastNameController.text, numberController.text);
                        }
                      },
                      child: Container(
                        height: 44,
                        margin: EdgeInsets.only(
                          bottom: 24,
                          top: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            translate("card.save"),
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void editAddress(
    BuildContext context,
    AddressModel addressModel,
  ) async {
    TextEditingController addressController =
        TextEditingController(text: addressModel.street);
    TextEditingController domController =
        TextEditingController(text: addressModel.dom);
    TextEditingController podezController =
        TextEditingController(text: addressModel.en);
    TextEditingController kvController =
        TextEditingController(text: addressModel.kv);
    TextEditingController commentController =
        TextEditingController(text: addressModel.comment);
    double lat = double.parse(addressModel.lat),
        lng = double.parse(addressModel.lng);
    bool isSave = true;
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                height: 525,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    topLeft: Radius.circular(24),
                  ),
                  color: AppColors.white,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      height: 4,
                      width: 64,
                      decoration: BoxDecoration(
                        color: AppColors.text_dark.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Center(
                        child: Text(
                          translate("address.edit_address"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 1.2,
                            color: AppColors.text_dark,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ShowMapAddress(
                                lng: lng,
                                lat: lat,
                                onChooseLocation: (Point point) {
                                  lat = point.latitude;
                                  lng = point.longitude;
                                  if (addressController.text.length > 0) {
                                    setState(() {
                                      isSave = true;
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.green,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/location.svg",
                              width: 24,
                              height: 24,
                              color: AppColors.green,
                            ),
                            SizedBox(width: 10),
                            Text(
                              translate("address.add_loc"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.25,
                                color: AppColors.green,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          color: AppColors.text_dark,
                          fontSize: 16,
                          height: 1.2,
                        ),
                        controller: addressController,
                        onChanged: (value) {
                          if (value.length > 0) {
                            setState(() {
                              isSave = false;
                            });
                          } else {
                            setState(() {
                              isSave = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: translate("address.address"),
                          hintStyle: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.normal,
                            color: AppColors.gray,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 44,
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      padding: EdgeInsets.only(
                        top: 12,
                        left: 12,
                        right: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          color: AppColors.text_dark,
                          fontSize: 16,
                          height: 1.2,
                        ),
                        controller: domController,
                        maxLength: 35,
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: translate("address.dom"),
                          hintStyle: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.normal,
                            color: AppColors.gray,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            width: double.infinity,
                            margin: EdgeInsets.only(
                              top: 16,
                            ),
                            padding: EdgeInsets.only(
                              top: 12,
                              left: 12,
                              right: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                color: AppColors.text_dark,
                                fontSize: 16,
                                height: 1.2,
                              ),
                              controller: podezController,
                              maxLength: 10,
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: translate("address.en"),
                                hintStyle: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.gray,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 44,
                            width: double.infinity,
                            margin: EdgeInsets.only(
                              top: 16,
                            ),
                            padding: EdgeInsets.only(
                              top: 12,
                              left: 12,
                              right: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                color: AppColors.text_dark,
                                fontSize: 16,
                                height: 1.2,
                              ),
                              controller: kvController,
                              maxLength: 10,
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: translate("address.kv"),
                                hintStyle: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.gray,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          top: 16,
                        ),
                        padding: EdgeInsets.only(
                          left: 12,
                          right: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.normal,
                            color: AppColors.text_dark,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          controller: commentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: translate("address.comment"),
                            hintStyle: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              color: AppColors.gray,
                              fontSize: 16,
                              height: 1.2,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 0,
                                color: AppColors.background,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 0,
                                color: AppColors.background,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (isSave) {
                          DatabaseHelperAddress database =
                              DatabaseHelperAddress();
                          var data = AddressModel(
                            id: addressModel.id,
                            street: addressController.text,
                            dom: domController.text,
                            en: podezController.text,
                            kv: kvController.text,
                            comment: commentController.text,
                            lat: lat.toString(),
                            lng: lng.toString(),
                            type: addressModel.type,
                          );
                          database.updateProduct(data).then((value) {
                            blocStore.fetchAddress();
                            blocStore.fetchAllAddress();
                            blocStore.fetchAddressHome();
                            blocStore.fetchAddressWork();
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        height: 44,
                        margin: EdgeInsets.only(top: 16, bottom: 24),
                        decoration: BoxDecoration(
                          color: isSave ? AppColors.blue : AppColors.gray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            translate("address.edit_change"),
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void addAddress(
    BuildContext context,
    int type,
    Function(AddressModel last) onSelected,
  ) async {
    TextEditingController addressController = TextEditingController();
    TextEditingController domController = TextEditingController();
    TextEditingController podezController = TextEditingController();
    TextEditingController kvController = TextEditingController();
    TextEditingController commentController = TextEditingController();
    double? lat, lng;
    bool isSave = false;
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                height: 525,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    topLeft: Radius.circular(24),
                  ),
                  color: AppColors.white,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      height: 4,
                      width: 64,
                      decoration: BoxDecoration(
                        color: AppColors.text_dark.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Center(
                        child: Text(
                          translate("address.new_address"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 1.2,
                            color: AppColors.text_dark,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ShowMapAddress(
                                lng: lng ?? 69.240562,
                                lat: lat ?? 41.311081,
                                onChooseLocation: (Point point) async {
                                  if (addressController.text.length > 0) {
                                    setState(() {
                                      isSave = true;
                                      lat = point.latitude;
                                      lng = point.longitude;
                                    });
                                  } else {
                                    lat = point.latitude;
                                    lng = point.longitude;
                                    var response =
                                        await Repository().fetchLocationAddress(
                                      lat ?? 41.311081,
                                      lng ?? 69.240562,
                                    );
                                    if (response.isSuccess) {
                                      var result =
                                          LocationAddressModel.fromJson(
                                              response.result);
                                      if (result.response.geoObjectCollection
                                              .featureMember.length >
                                          0) {
                                        setState(() {
                                          addressController.text = result
                                              .response
                                              .geoObjectCollection
                                              .featureMember[0]
                                              .geoObject
                                              .name;
                                          if (addressController.text.length >
                                              0) {
                                            isSave = true;
                                          }
                                        });
                                      } else {
                                        setState(() {});
                                      }
                                    } else {
                                      setState(() {});
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: lat == null
                                ? AppColors.textGray
                                : AppColors.green,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/location.svg",
                              width: 24,
                              height: 24,
                              color: lat == null
                                  ? AppColors.textGray
                                  : AppColors.green,
                            ),
                            SizedBox(width: 10),
                            Text(
                              lat == null
                                  ? translate("address.see_map")
                                  : translate("address.add_loc"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.25,
                                color: lat == null
                                    ? AppColors.textGray
                                    : AppColors.green,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          color: AppColors.text_dark,
                          fontSize: 16,
                          height: 1.2,
                        ),
                        controller: addressController,
                        onChanged: (value) {
                          if (value.length > 0) {
                            if (lat != null) {
                              setState(() {
                                isSave = true;
                              });
                            } else {
                              setState(() {
                                isSave = false;
                              });
                            }
                          } else {
                            setState(() {
                              isSave = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: translate("address.address"),
                          hintStyle: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.normal,
                            color: AppColors.gray,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 44,
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      padding: EdgeInsets.only(
                        top: 12,
                        left: 12,
                        right: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          color: AppColors.text_dark,
                          fontSize: 16,
                          height: 1.2,
                        ),
                        controller: domController,
                        maxLength: 35,
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: translate("address.dom"),
                          hintStyle: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.normal,
                            color: AppColors.gray,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            width: double.infinity,
                            margin: EdgeInsets.only(
                              top: 16,
                            ),
                            padding: EdgeInsets.only(
                              top: 12,
                              left: 12,
                              right: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                color: AppColors.text_dark,
                                fontSize: 16,
                                height: 1.2,
                              ),
                              controller: podezController,
                              maxLength: 10,
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: translate("address.en"),
                                hintStyle: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.gray,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 44,
                            width: double.infinity,
                            margin: EdgeInsets.only(
                              top: 16,
                            ),
                            padding: EdgeInsets.only(
                              top: 12,
                              left: 12,
                              right: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                color: AppColors.text_dark,
                                fontSize: 16,
                                height: 1.2,
                              ),
                              controller: kvController,
                              maxLength: 10,
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: translate("address.kv"),
                                hintStyle: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.gray,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          top: 16,
                        ),
                        padding: EdgeInsets.only(
                          left: 12,
                          right: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.normal,
                            color: AppColors.text_dark,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          controller: commentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: translate("address.comment"),
                            hintStyle: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              color: AppColors.gray,
                              fontSize: 16,
                              height: 1.2,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 0,
                                color: AppColors.background,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 0,
                                color: AppColors.background,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (isSave) {
                          DatabaseHelperAddress database =
                              DatabaseHelperAddress();
                          var data = AddressModel(
                            street: addressController.text,
                            dom: domController.text,
                            en: podezController.text,
                            kv: kvController.text,
                            comment: commentController.text,
                            lat: lat.toString(),
                            lng: lng.toString(),
                            type: type,
                            id: -1,
                          );
                          database.saveProducts(data).then((value) {
                            AddressModel data = AddressModel(
                              id: value,
                              street: addressController.text,
                              dom: domController.text,
                              en: podezController.text,
                              kv: kvController.text,
                              comment: commentController.text,
                              lat: lat.toString(),
                              lng: lng.toString(),
                              type: type,
                            );
                            blocStore.fetchAddress();
                            blocStore.fetchAllAddress();
                            blocStore.fetchAddressHome();
                            blocStore.fetchAddressWork();
                            onSelected(data);
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        height: 44,
                        margin: EdgeInsets.only(top: 16, bottom: 24),
                        decoration: BoxDecoration(
                          color: isSave ? AppColors.blue : AppColors.gray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            translate("address.add_address"),
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void showChangeLanguage(
    BuildContext context,
    String language,
    Function() onTap,
  ) async {
    var duration = Duration(milliseconds: 270);
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 342,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("menu.language"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      if (language != "uz") {
                        setState(() {
                          language = "uz";
                        });
                      }
                    },
                    child: Container(
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/img/uz.png",
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "O'zbek tili",
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                height: 1.2,
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          AnimatedContainer(
                            duration: duration,
                            curve: Curves.easeInOut,
                            height: 16,
                            width: 16,
                            child: Center(
                              child: AnimatedContainer(
                                duration: duration,
                                curve: Curves.easeInOut,
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: language == "uz"
                                      ? AppColors.blue
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: language == "uz"
                                    ? AppColors.blue
                                    : AppColors.gray,
                                width: 1,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      if (language != "ru") {
                        setState(() {
                          language = "ru";
                        });
                      }
                    },
                    child: Container(
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/img/ru.png",
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Русский язык",
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                height: 1.2,
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          AnimatedContainer(
                            duration: duration,
                            curve: Curves.easeInOut,
                            height: 16,
                            width: 16,
                            child: Center(
                              child: AnimatedContainer(
                                duration: duration,
                                curve: Curves.easeInOut,
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: language == "ru"
                                      ? AppColors.blue
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: language == "ru"
                                    ? AppColors.blue
                                    : AppColors.gray,
                                width: 1,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      if (language != "en") {
                        setState(() {
                          language = "en";
                        });
                      }
                    },
                    child: Container(
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/img/en.png",
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "English",
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                height: 1.2,
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          AnimatedContainer(
                            duration: duration,
                            curve: Curves.easeInOut,
                            height: 16,
                            width: 16,
                            child: Center(
                              child: AnimatedContainer(
                                duration: duration,
                                curve: Curves.easeInOut,
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: language == "en"
                                      ? AppColors.blue
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: language == "en"
                                    ? AppColors.blue
                                    : AppColors.gray,
                                width: 1,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('language', language);
                      var localizationDelegate =
                          LocalizedApp.of(context).delegate;
                      localizationDelegate.changeLocale(Locale(language));
                      RxBus.post(BottomView(true),
                          tag: "MENU_VIEW_NOTIFY_SCREEN");
                      Navigator.pop(context);
                      onTap();
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        top: 16,
                        bottom: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("menu.save"),
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showCancelOrder(
    BuildContext context,
    int id,
    Function onTap,
  ) async {
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("history.cancel_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/img/cancel_img.png",
                        height: 32,
                        width: 32,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 16,
                      left: 12,
                      right: 12,
                    ),
                    child: Center(
                      child: Text(
                        translate("history.cancel_message"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  GestureDetector(
                    onTap: () {
                      onTap();
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("history.cancel_no"),
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
                  Container(
                    height: 44,
                    margin: EdgeInsets.only(
                      bottom: 24,
                      top: 16,
                    ),
                    child: Material(
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              translate("history.cancel_yes"),
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.25,
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void historyCancelOrderCash(
    BuildContext context,
  ) async {
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("history.message_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/img/msg_img.png",
                        height: 32,
                        width: 32,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 16,
                      left: 12,
                      right: 12,
                    ),
                    child: Center(
                      child: Text(
                        translate("item.cash_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("item.detail"),
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
                  Container(
                    height: 44,
                    margin: EdgeInsets.only(
                      bottom: 24,
                      top: 16,
                    ),
                    child: Material(
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              translate("history.close"),
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.25,
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void historyCancelOrderOnline(
    BuildContext context,
  ) async {
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("history.message_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/img/msg_img.png",
                        height: 32,
                        width: 32,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 16,
                      left: 12,
                      right: 12,
                    ),
                    child: Center(
                      child: Text(
                        translate("history.message_msg"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  GestureDetector(
                    onTap: () async {
                      var url = "tel:712050888";
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("history.call"),
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
                  Container(
                    height: 44,
                    margin: EdgeInsets.only(
                      bottom: 24,
                      top: 16,
                    ),
                    child: Material(
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              translate("history.close"),
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.25,
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showClearHistory(
    BuildContext context,
    Function() onClear,
  ) async {
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("search.clear_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE8E2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/img/clear_history.png",
                            height: 32,
                            width: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    translate("search.cleat_msg"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      onClear();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        bottom: 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("search.clear"),
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
                  Material(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 44,
                        color: AppColors.white.withOpacity(0.01),
                        child: Center(
                          child: Text(
                            translate("search.cancel"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.25,
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showDeleteItem(
    BuildContext context,
    int itemId,
  ) async {
    DatabaseHelper dataBase = new DatabaseHelper();
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("card.clear_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE8E2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/img/clear.png",
                            height: 32,
                            width: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    translate("card.clear_message"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      dataBase.deleteProducts(itemId).then((value) {
                        blocCard.fetchAllCard();
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        bottom: 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("card.delete"),
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
                  Material(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 44,
                        color: AppColors.white.withOpacity(0.01),
                        child: Center(
                          child: Text(
                            translate("card.cancel"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.25,
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showDeleteAddress(
    BuildContext context,
    int addressId,
    Function() onTap,
  ) async {
    DatabaseHelperAddress dataBase = new DatabaseHelperAddress();
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("address.delete_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE8E2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/img/clear.png",
                            height: 32,
                            width: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    translate("address.delete_mes"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await dataBase.deleteProducts(addressId);
                      Navigator.pop(context);
                      // blocStore.fetchAddress();
                      // blocStore.fetchAddressHome();
                      // blocStore.fetchAddressWork();
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        bottom: 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("address.delete"),
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
                  Material(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 44,
                        color: AppColors.white.withOpacity(0.1),
                        child: Center(
                          child: Text(
                            translate("address.cancel"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.25,
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void historyClosePayment(
    BuildContext context,
    Function onHistory,
  ) async {
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("card.order_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/img/best.png",
                            height: 32,
                            width: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    translate("card.can_msg"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      RxBus.post(BottomViewModel(4), tag: "EVENT_BOTTOM_VIEW");
                      onHistory();
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        bottom: 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("card.can_btn"),
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
                  Material(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        RxBus.post(BottomViewModel(4),
                            tag: "EVENT_BOTTOM_VIEW");
                        onHistory();
                      },
                      child: Container(
                        height: 44,
                        color: AppColors.white.withOpacity(0.01),
                        child: Center(
                          child: Text(
                            translate("card.order_history"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.25,
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showUpdate(
    BuildContext context,
    String text,
    bool optional,
  ) async {
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      isDismissible: optional,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: optional ? 365 : 321,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("home.update_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/img/update_image.png",
                            height: 32,
                            width: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      if (Platform.isAndroid) {
                        var url =
                            'https://play.google.com/store/apps/details?id=uz.go.pharm';
                        await launch(url);
                      } else if (Platform.isIOS) {
                        var url =
                            'https://apps.apple.com/uz/app/gopharm-online/id1527930423';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        bottom: 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("home.update_button"),
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
                  optional
                      ? Material(
                          child: InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 44,
                              color: AppColors.white.withOpacity(0.01),
                              child: Center(
                                child: Text(
                                  translate("home.skip"),
                                  style: TextStyle(
                                    fontFamily: AppColors.fontRubik,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    height: 1.25,
                                    color: AppColors.textGray,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 24,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showNetworkError(BuildContext context, Function reload) async {
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("network.network_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/img/network_error_image.png",
                            height: 32,
                            width: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    translate("network.network_message"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      reload();
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        bottom: 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("network.reload_screen"),
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
                  Material(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 44,
                        color: AppColors.white.withOpacity(0.01),
                        child: Center(
                          child: Text(
                            translate("network.close"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.25,
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showCommentService({
    required BuildContext context,
    required int orderId,
  }) async {
    int _stars = 5;
    TextEditingController commentController = TextEditingController();
    var loading = false;
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) => Container(
              height: 534,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Text(
                      translate("comment.title"),
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
                    height: 80,
                    width: 80,
                    margin: EdgeInsets.only(top: 24, bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/img/note_image.png",
                        height: 32,
                        width: 32,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                      translate("comment.message"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppColors.fontRubik,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textGray,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          child: _stars >= 1
                              ? SvgPicture.asset("assets/icons/star_select.svg")
                              : SvgPicture.asset(
                                  "assets/icons/star_un_select.svg"),
                          onTap: () {
                            setState(() {
                              _stars = 1;
                            });
                          },
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          child: _stars >= 2
                              ? SvgPicture.asset("assets/icons/star_select.svg")
                              : SvgPicture.asset(
                                  "assets/icons/star_un_select.svg"),
                          onTap: () {
                            setState(() {
                              _stars = 2;
                            });
                          },
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          child: _stars >= 3
                              ? SvgPicture.asset("assets/icons/star_select.svg")
                              : SvgPicture.asset(
                                  "assets/icons/star_un_select.svg"),
                          onTap: () {
                            setState(() {
                              _stars = 3;
                            });
                          },
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          child: _stars >= 4
                              ? SvgPicture.asset("assets/icons/star_select.svg")
                              : SvgPicture.asset(
                                  "assets/icons/star_un_select.svg"),
                          onTap: () {
                            setState(() {
                              _stars = 4;
                            });
                          },
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          child: _stars >= 5
                              ? SvgPicture.asset("assets/icons/star_select.svg")
                              : SvgPicture.asset(
                                  "assets/icons/star_un_select.svg"),
                          onTap: () {
                            setState(() {
                              _stars = 5;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        translate("comment.comment"),
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.2,
                          color: AppColors.textGray,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.only(left: 16, right: 16, top: 8),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.text_dark,
                        ),
                        controller: commentController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.background,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (commentController.text.length > 0 || _stars > 0) {
                        setState(() {
                          loading = true;
                        });
                        if (orderId != -1) {
                          Repository()
                              .fetchOrderItemReview(
                                commentController.text,
                                _stars,
                                orderId,
                              )
                              .then(
                                (value) => {
                                  setState(() {
                                    loading = false;
                                  }),
                                  Navigator.of(context).pop(),
                                },
                              );
                        } else {
                          Repository()
                              .fetchSendRating(commentController.text, _stars)
                              .then(
                                (value) => {
                                  setState(() {
                                    loading = false;
                                  }),
                                  Navigator.of(context).pop(),
                                },
                              );
                        }
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 24,
                      ),
                      height: 44,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.blue,
                      ),
                      child: Center(
                        child: loading
                            ? Lottie.asset(
                                'assets/anim/white.json',
                                height: 40,
                              )
                            : Text(
                                translate("comment.send"),
                                style: TextStyle(
                                  fontStyle: FontStyle.normal,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppColors.fontRubik,
                                  color: AppColors.white,
                                  height: 1.29,
                                ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showExitProfile(BuildContext context) async {
    DatabaseHelper dataBaseCard = new DatabaseHelper();
    DatabaseHelperFav dataBaseFav = new DatabaseHelperFav();
    DatabaseHelperHistory dataBaseHis = new DatabaseHelperHistory();
    DatabaseHelperAddress dataBaseAddress = new DatabaseHelperAddress();
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("menu.exit"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/img/exit.png",
                            height: 32,
                            width: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    translate("menu.exit_title"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Utils.clearData();
                      dataBaseAddress.clear();
                      dataBaseCard.clear();
                      dataBaseFav.clear();
                      dataBaseHis.clear().then((value) {
                        if (Platform.isIOS) {
                          exit(0);
                        } else {
                          SystemNavigator.pop();
                        }
                      });
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        bottom: 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("menu.exit_yes"),
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
                  Material(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 44,
                        color: AppColors.white.withOpacity(0.1),
                        child: Center(
                          child: Text(
                            translate("menu.exit_no"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.25,
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showEditProfile(
    BuildContext context, {
    required String firstName,
    required String lastName,
    required String number,
    required String birthday,
    required DateTime dateTime,
    required int gender,
    required String token,
  }) async {
    TextEditingController firstNameController =
        TextEditingController(text: firstName);
    TextEditingController lastNameController =
        TextEditingController(text: lastName);
    TextEditingController numberController =
        TextEditingController(text: number);
    TextEditingController birthdayController =
        TextEditingController(text: birthday);
    var loading = false;
    var errorText = "";
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                height: 580,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    topLeft: Radius.circular(24),
                  ),
                  color: AppColors.white,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      height: 4,
                      width: 64,
                      decoration: BoxDecoration(
                        color: AppColors.text_dark.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16, bottom: 24),
                      child: Center(
                        child: Text(
                          translate("menu.user_info"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 1.2,
                            color: AppColors.text_dark,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: 16,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
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
                          ),
                          Container(
                            height: 44,
                            width: double.infinity,
                            margin: EdgeInsets.only(
                              top: 8,
                            ),
                            padding: EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
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
                              controller: firstNameController,
                              decoration: InputDecoration(
                                counterText: "",
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 16,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
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
                          ),
                          Container(
                            height: 44,
                            width: double.infinity,
                            margin: EdgeInsets.only(
                              top: 8,
                            ),
                            padding: EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
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
                              controller: lastNameController,
                              decoration: InputDecoration(
                                counterText: "",
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 16,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
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
                          ),
                          Container(
                            height: 44,
                            width: double.infinity,
                            margin: EdgeInsets.only(
                              top: 8,
                            ),
                            padding: EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
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
                                    color: AppColors.background,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 16,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
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
                                  birthdayController.text =
                                      Utils.format(date.day) +
                                          "/" +
                                          Utils.format(date.month) +
                                          "/" +
                                          date.year.toString();

                                  birthday = Utils.format(date.day) +
                                      "/" +
                                      Utils.format(date.month) +
                                      "/" +
                                      date.year.toString();
                                },
                                currentTime: dateTime,
                                locale: LocaleType.ru,
                              );
                            },
                            child: Container(
                              height: 44,
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                top: 8,
                              ),
                              padding: EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.background,
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
                                        color: AppColors.background,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 0,
                                        color: AppColors.background,
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
                            child: Align(
                              alignment: Alignment.centerLeft,
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
                                      if (gender != 1)
                                        setState(() {
                                          gender = 1;
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
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: gender == 1
                                                  ? AppColors.blue
                                                  : AppColors.gray,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 270),
                                              curve: Curves.easeInOut,
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                color: gender == 1
                                                    ? AppColors.blue
                                                    : Color(0xFFF4F5F7),
                                                borderRadius:
                                                    BorderRadius.circular(16),
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
                                      if (gender != 2)
                                        setState(() {
                                          gender = 2;
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
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: gender == 2
                                                  ? AppColors.blue
                                                  : AppColors.gray,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 270),
                                              curve: Curves.easeInOut,
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                color: gender == 2
                                                    ? AppColors.blue
                                                    : Color(0xFFF4F5F7),
                                                borderRadius:
                                                    BorderRadius.circular(16),
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
                          errorText != ""
                              ? Container(
                                  margin: EdgeInsets.only(top: 4),
                                  width: double.infinity,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      errorText,
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
                                        color: AppColors.red,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        String gen = gender == 1 ? "man" : "woman";
                        if (firstNameController.text.isNotEmpty &&
                            lastNameController.text.isNotEmpty &&
                            birthday.isNotEmpty) {
                          setState(() {
                            loading = true;
                          });
                          var birth = birthday.split("/")[2] +
                              "-" +
                              birthday.split("/")[1] +
                              "-" +
                              birthday.split("/")[0];

                          var response = await Repository().fetchRegister(
                            firstNameController.text.toString(),
                            lastNameController.text.toString(),
                            birth,
                            gen,
                            token,
                            fcToken,
                          );
                          if (response.isSuccess) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            Utils.saveData(
                              prefs.getInt("userId") ?? 0,
                              firstNameController.text.toString(),
                              lastNameController.text.toString(),
                              birth,
                              gen,
                              token,
                              number.replaceAll(" ", "").replaceAll("+", ""),
                            );
                            RxBus.post(BottomView(true),
                                tag: "MENU_VIEW_NOTIFY_SCREEN");
                            Navigator.pop(context);
                          } else if (response.status == -1) {
                            setState(() {
                              errorText = translate("network.network_title");
                              loading = false;
                            });
                          } else {
                            setState(() {
                              errorText = response.result["msg"];
                              loading = false;
                            });
                          }
                        }
                      },
                      child: Container(
                        height: 44,
                        margin: EdgeInsets.only(
                          bottom: 24,
                          top: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: loading
                              ? Lottie.asset(
                                  'assets/anim/white.json',
                                  height: 40,
                                )
                              : Text(
                                  translate("menu.save"),
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void showFilter(
    BuildContext context,
    String ordering,
    String maxPrice,
    Function(String ordering, String maxPrice) onChange,
  ) {
    PageController _pageController = PageController(initialPage: 0);
    var duration = Duration(milliseconds: 270);
    int currentIndex = 0;
    double _sliderDiscreteValue = maxPrice == "" ? 0.0 : double.parse(maxPrice);

    showModalBottomSheet(
      context: context,
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Container(
              height: 432,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 16),
                    color: AppColors.background,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (currentIndex != 0) {
                                setState(() {
                                  currentIndex = 0;
                                  _pageController.jumpToPage(currentIndex);
                                });
                              }
                            },
                            child: Container(
                              color: AppColors.white,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        translate("item.sort"),
                                        style: TextStyle(
                                          fontFamily: AppColors.fontRubik,
                                          fontWeight: currentIndex == 0
                                              ? FontWeight.w500
                                              : FontWeight.w400,
                                          fontSize: 14,
                                          height: 1.2,
                                          color: currentIndex == 0
                                              ? AppColors.text_dark
                                              : AppColors.textGray,
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 270),
                                    curve: Curves.easeInOut,
                                    height: currentIndex == 0 ? 2 : 1,
                                    width: double.infinity,
                                    color: currentIndex == 0
                                        ? AppColors.blue
                                        : AppColors.background,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (currentIndex != 1) {
                                setState(() {
                                  currentIndex = 1;
                                  _pageController.jumpToPage(currentIndex);
                                });
                              }
                            },
                            child: Container(
                              color: AppColors.white,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        translate("item.price_title"),
                                        style: TextStyle(
                                          fontFamily: AppColors.fontRubik,
                                          fontWeight: currentIndex == 1
                                              ? FontWeight.w500
                                              : FontWeight.w400,
                                          fontSize: 14,
                                          height: 1.2,
                                          color: currentIndex == 1
                                              ? AppColors.text_dark
                                              : AppColors.textGray,
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 270),
                                    curve: Curves.easeInOut,
                                    height: currentIndex == 1 ? 2 : 1,
                                    width: double.infinity,
                                    color: currentIndex == 1
                                        ? AppColors.blue
                                        : AppColors.background,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.all(16),
                        child: PageView(
                          physics: NeverScrollableScrollPhysics(),
                          pageSnapping: false,
                          onPageChanged: (int page) {
                            setState(() {
                              currentIndex = page;
                            });
                          },
                          controller: _pageController,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                top: 4,
                                left: 8,
                                right: 8,
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (ordering != "name") {
                                        setState(() {
                                          ordering = "name";
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        top: 12,
                                        bottom: 12,
                                      ),
                                      color: AppColors.white,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              translate("item.name"),
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                height: 1.2,
                                                color: AppColors.text_dark,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          AnimatedContainer(
                                            duration: duration,
                                            curve: Curves.easeInOut,
                                            height: 16,
                                            width: 16,
                                            padding: EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: ordering == "name"
                                                    ? AppColors.blue
                                                    : AppColors.gray,
                                              ),
                                            ),
                                            child: AnimatedContainer(
                                              duration: duration,
                                              curve: Curves.easeInOut,
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                color: ordering == "name"
                                                    ? AppColors.blue
                                                    : AppColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (ordering != "-name") {
                                        setState(() {
                                          ordering = "-name";
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        top: 12,
                                        bottom: 12,
                                      ),
                                      color: AppColors.white,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              translate("item.un_name"),
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                height: 1.2,
                                                color: AppColors.text_dark,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          AnimatedContainer(
                                            duration: duration,
                                            curve: Curves.easeInOut,
                                            height: 16,
                                            width: 16,
                                            padding: EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: ordering == "-name"
                                                    ? AppColors.blue
                                                    : AppColors.gray,
                                              ),
                                            ),
                                            child: AnimatedContainer(
                                              duration: duration,
                                              curve: Curves.easeInOut,
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                color: ordering == "-name"
                                                    ? AppColors.blue
                                                    : AppColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (ordering != "price") {
                                        setState(() {
                                          ordering = "price";
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        top: 12,
                                        bottom: 12,
                                      ),
                                      color: AppColors.white,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              translate("item.price"),
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                height: 1.2,
                                                color: AppColors.text_dark,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          AnimatedContainer(
                                            duration: duration,
                                            curve: Curves.easeInOut,
                                            height: 16,
                                            width: 16,
                                            padding: EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: ordering == "price"
                                                    ? AppColors.blue
                                                    : AppColors.gray,
                                              ),
                                            ),
                                            child: AnimatedContainer(
                                              duration: duration,
                                              curve: Curves.easeInOut,
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                color: ordering == "price"
                                                    ? AppColors.blue
                                                    : AppColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (ordering != "-price") {
                                        setState(() {
                                          ordering = "-price";
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        top: 12,
                                        bottom: 12,
                                      ),
                                      color: AppColors.white,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              translate("item.un_price"),
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                height: 1.2,
                                                color: AppColors.text_dark,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          AnimatedContainer(
                                            duration: duration,
                                            curve: Curves.easeInOut,
                                            height: 16,
                                            width: 16,
                                            padding: EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: ordering == "-price"
                                                    ? AppColors.blue
                                                    : AppColors.gray,
                                              ),
                                            ),
                                            child: AnimatedContainer(
                                              duration: duration,
                                              curve: Curves.easeInOut,
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                color: ordering == "-price"
                                                    ? AppColors.blue
                                                    : AppColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                top: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    translate("item.max"),
                                    style: TextStyle(
                                      fontFamily: AppColors.fontRubik,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      height: 1.2,
                                      color: AppColors.text_dark,
                                    ),
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 16, bottom: 16),
                                    margin: EdgeInsets.only(top: 16),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(width: 16),
                                            Text(
                                              "0" + translate("sum"),
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                height: 1.2,
                                                color: AppColors.text_dark,
                                              ),
                                            ),
                                            Expanded(child: Container()),
                                            _sliderDiscreteValue == 0.0
                                                ? Container()
                                                : Text(
                                                    priceFormat.format(
                                                            _sliderDiscreteValue
                                                                .toInt()) +
                                                        translate("sum"),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppColors.fontRubik,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16,
                                                      height: 1.2,
                                                      color: AppColors.text_dark,
                                                    ),
                                                  ),
                                            SizedBox(width: 16),
                                          ],
                                        ),
                                        SliderTheme(
                                          data: SliderThemeData(
                                              trackHeight: 3,
                                              valueIndicatorShape:
                                                  PaddleSliderValueIndicatorShape(),
                                              activeTrackColor: AppColors.blue,
                                              inactiveTrackColor: AppColors.gray,
                                              overlayColor: AppColors.blue
                                                  .withOpacity(0.1),
                                              thumbColor: AppColors.blue),
                                          child: Slider(
                                            value: _sliderDiscreteValue,
                                            min: 0,
                                            max: 10000000,
                                            onChanged: (value) {
                                              setState(() {
                                                _sliderDiscreteValue = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: AppColors.background,
                  ),
                  GestureDetector(
                    onTap: () {
                      onChange(
                          ordering, _sliderDiscreteValue.toInt().toString());
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 12,
                        left: 22,
                        right: 22,
                        bottom: 24,
                      ),
                      height: 44,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("item.result"),
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            height: 1.2,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showStoreInfo(
    BuildContext context,
    LocationModel data,
    Function(LocationModel choose) choose,
  ) async {
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 16),
                      Image.asset(
                        "assets/img/store.png",
                        height: 64,
                        width: 64,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                height: 1.2,
                                color: AppColors.text_dark,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              data.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                height: 1.6,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: AppColors.background,
                    margin: EdgeInsets.symmetric(vertical: 16),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 16),
                      Text(
                        translate("card.distance"),
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.2,
                          color: AppColors.textGray,
                        ),
                      ),
                      Expanded(child: Container()),
                      data.distance == 0.0
                          ? Container()
                          : Text(
                              ((data.distance ~/ 100) / 10.0).toString() +
                                  translate("km"),
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                height: 1.2,
                                color: AppColors.text_dark,
                              ),
                            ),
                      SizedBox(width: 16),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 16),
                      Text(
                        translate("card.mode"),
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.2,
                          color: AppColors.textGray,
                        ),
                      ),
                      Expanded(child: Container()),
                      Text(
                        data.mode.toString(),
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 16),
                      Text(
                        translate("card.phone"),
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.2,
                          color: AppColors.textGray,
                        ),
                      ),
                      Expanded(child: Container()),
                      Text(
                        Utils.numberFormat(data.phone),
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 16),
                      Text(
                        translate("card.price"),
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.2,
                          color: AppColors.textGray,
                        ),
                      ),
                      Expanded(child: Container()),
                      Text(
                        priceFormat.format(data.total) + translate("sum"),
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: AppColors.background,
                  ),
                  GestureDetector(
                    onTap: () async {
                      choose(data);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("card.choose_store_info"),
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
                  SizedBox(
                    height: 24,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showItemDrug(BuildContext context, int id, int position) async {
    blocItem.fetchAllInfoItem(id.toString());

    DatabaseHelper dataBase = new DatabaseHelper();
    DatabaseHelperFav dataBaseFav = new DatabaseHelperFav();
    int currentIndex = 0;
    ScrollController? scrollController;
    var onClose = true;

    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        scrollController = ScrollController()
          ..addListener(() {
            if (scrollController!.offset < -150 && onClose) {
              scrollController!.dispose();
              onClose = false;
              Navigator.pop(context);
            }
          });
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height - 60,
              margin: EdgeInsets.only(top: 60),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: StreamBuilder(
                stream: blocItem.allItems,
                builder: (context, AsyncSnapshot<ItemsAllModel> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Container(
                          height: 28,
                          padding: EdgeInsets.only(top: 8, bottom: 16),
                          child: Container(
                            height: 4,
                            width: 64,
                            color: AppColors.text_dark.withOpacity(0.05),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            children: [
                              Container(
                                height: 190,
                                margin: EdgeInsets.only(left: 16, right: 16),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: CachedNetworkImage(
                                        imageUrl: snapshot.data!.image,
                                        placeholder: (context, url) =>
                                            SvgPicture.asset(
                                          "assets/icons/default_image.svg",
                                        ),
                                        errorWidget: (context, url, error) =>
                                            SvgPicture.asset(
                                          "assets/icons/default_image.svg",
                                        ),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          snapshot.data!.favourite =
                                              !snapshot.data!.favourite;
                                          if (snapshot.data!.favourite) {
                                            dataBaseFav
                                                .saveProducts(
                                              ItemResult(
                                                id: snapshot.data!.id,
                                                name: snapshot.data!.name,
                                                barcode: snapshot.data!.barcode,
                                                image: snapshot.data!.image,
                                                imageThumbnail: snapshot
                                                    .data!.imageThumbnail,
                                                price: snapshot.data!.price,
                                                basePrice:
                                                    snapshot.data!.basePrice,
                                                isComing:
                                                    snapshot.data!.isComing,
                                                maxCount:
                                                    snapshot.data!.maxCount,
                                                manufacturer: Manufacturer(
                                                  name: snapshot
                                                      .data!.manufacturer.name,
                                                ),
                                                favourite: true,
                                                cardCount: 0,
                                                msg: "",
                                              ),
                                            )
                                                .then((value) {
                                              blocItem
                                                  .fetchItemUpdate(position);
                                            });
                                          } else {
                                            dataBaseFav
                                                .deleteProducts(
                                                    snapshot.data!.id)
                                                .then((value) {
                                              blocItem
                                                  .fetchItemUpdate(position);
                                            });
                                          }
                                        },
                                        child: snapshot.data!.favourite
                                            ? SvgPicture.asset(
                                                "assets/icons/fav_select.svg",
                                                width: 32,
                                                height: 32,
                                              )
                                            : SvgPicture.asset(
                                                "assets/icons/fav_unselect.svg",
                                                width: 32,
                                                height: 32,
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.blue,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                                "assets/icons/icon_rating.svg"),
                                            SizedBox(width: 4),
                                            Text(
                                              snapshot.data!.rating.toString(),
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                height: 1.2,
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      top: 0,
                                      left: 0,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: 16, left: 16, right: 16),
                                child: Text(
                                  snapshot.data!.manufacturer.name,
                                  style: TextStyle(
                                    fontFamily: AppColors.fontRubik,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    height: 1.2,
                                    color: AppColors.textGray,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: 10, left: 16, right: 16),
                                child: Text(
                                  snapshot.data!.name,
                                  style: TextStyle(
                                    fontFamily: AppColors.fontRubik,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                    height: 1.5,
                                    color: AppColors.text_dark,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 8,
                                  left: 16,
                                  right: 16,
                                  bottom: 16,
                                ),
                                child: snapshot.data!.price >=
                                        snapshot.data!.basePrice
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          translate("lan") != "2"
                                              ? Text(
                                                  translate("from"),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppColors.fontRubik,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 20,
                                                    height: 1.5,
                                                    color: AppColors.text_dark,
                                                  ),
                                                )
                                              : Container(),
                                          Text(
                                            priceFormat.format(
                                                    snapshot.data!.price) +
                                                translate("sum"),
                                            style: TextStyle(
                                              fontFamily: AppColors.fontRubik,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                              height: 1.5,
                                              color: AppColors.text_dark,
                                            ),
                                          ),
                                          translate("lan") == "2"
                                              ? Text(
                                                  translate("from"),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppColors.fontRubik,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 20,
                                                    height: 1.5,
                                                    color: AppColors.text_dark,
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      )
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          translate("lan") != "2"
                                              ? Text(
                                                  translate("from"),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppColors.fontRubik,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 20,
                                                    height: 1.5,
                                                    color: AppColors.red,
                                                  ),
                                                )
                                              : Container(),
                                          Text(
                                            priceFormat.format(
                                                    snapshot.data!.price) +
                                                translate("sum"),
                                            style: TextStyle(
                                              fontFamily: AppColors.fontRubik,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                              height: 1.5,
                                              color: AppColors.red,
                                            ),
                                          ),
                                          translate("lan") == "2"
                                              ? Text(
                                                  translate("from"),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppColors.fontRubik,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 20,
                                                    height: 1.5,
                                                    color: AppColors.red,
                                                  ),
                                                )
                                              : Container(),
                                          SizedBox(width: 12),
                                          RichText(
                                            text: new TextSpan(
                                              text: priceFormat.format(snapshot
                                                      .data!.basePrice) +
                                                  translate("sum"),
                                              style: new TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                height: 1.5,
                                                color: AppColors.textGray,
                                                decoration:
                                                    TextDecoration.lineThrough,
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
                              Container(
                                margin: EdgeInsets.only(left: 16, right: 16),
                                height: 50,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (currentIndex != 0) {
                                            setState(() {
                                              currentIndex = 0;
                                            });
                                          }
                                        },
                                        child: Container(
                                          color: AppColors.white,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Center(
                                                  child: Text(
                                                    translate(
                                                        "item.description"),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppColors.fontRubik,
                                                      fontWeight:
                                                          currentIndex == 0
                                                              ? FontWeight.w500
                                                              : FontWeight.w400,
                                                      fontSize: 14,
                                                      height: 1.2,
                                                      color: currentIndex == 0
                                                          ? AppColors.text_dark
                                                          : AppColors.textGray,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 270),
                                                curve: Curves.easeInOut,
                                                height:
                                                    currentIndex == 0 ? 2 : 1,
                                                width: double.infinity,
                                                color: currentIndex == 0
                                                    ? AppColors.blue
                                                    : AppColors.background,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (currentIndex != 1) {
                                            setState(() {
                                              currentIndex = 1;
                                            });
                                          }
                                        },
                                        child: Container(
                                          color: AppColors.white,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Center(
                                                  child: Text(
                                                    translate("item.analog"),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppColors.fontRubik,
                                                      fontWeight:
                                                          currentIndex == 1
                                                              ? FontWeight.w500
                                                              : FontWeight.w400,
                                                      fontSize: 14,
                                                      height: 1.2,
                                                      color: currentIndex == 1
                                                          ? AppColors.text_dark
                                                          : AppColors.textGray,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              AnimatedContainer(
                                                duration:
                                                    Duration(milliseconds: 270),
                                                curve: Curves.easeInOut,
                                                height:
                                                    currentIndex == 1 ? 2 : 1,
                                                width: double.infinity,
                                                color: currentIndex == 1
                                                    ? AppColors.blue
                                                    : AppColors.background,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              currentIndex == 0
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(16),
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          width: double.infinity,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                translate("item.substance"),
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  height: 1.2,
                                                  color: AppColors.textGray,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                snapshot.data!.internationalName
                                                    .name,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  height: 1.6,
                                                  color: AppColors.text_dark,
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                translate("item.release"),
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  height: 1.2,
                                                  color: AppColors.textGray,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                snapshot.data!.unit.name,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  height: 1.6,
                                                  color: AppColors.text_dark,
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                translate("item.category"),
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  height: 1.2,
                                                  color: AppColors.textGray,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                snapshot.data!.category.name,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  height: 1.6,
                                                  color: AppColors.text_dark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                          ),
                                          child: Text(
                                            translate("item.info"),
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
                                          margin: EdgeInsets.only(
                                            top: 12,
                                            left: 16,
                                            right: 16,
                                          ),
                                          child: RichText(
                                            text: HTML.toTextSpan(
                                              context,
                                              snapshot.data!.description,
                                              defaultTextStyle: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                height: 1.6,
                                                color: AppColors.textGray,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : snapshot.data!.analog.length == 0
                                      ? Container(
                                          padding: EdgeInsets.only(
                                            left: 32,
                                            right: 32,
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 16, bottom: 16),
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  color: AppColors.yellow,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                    "assets/img/empty_store.png",
                                                    height: 32,
                                                    width: 32,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                translate(
                                                    "category.analog_empty_title"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  height: 1.2,
                                                  color: AppColors.text_dark,
                                                ),
                                              ),
                                              Text(
                                                translate(
                                                    "category.analog_empty_msg"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  height: 1.6,
                                                  color: AppColors.textGray,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          height: 190,
                                          margin: EdgeInsets.only(top: 16),
                                          child: ListView.builder(
                                            padding: const EdgeInsets.only(
                                              top: 0,
                                              bottom: 0,
                                              right: 16,
                                              left: 16,
                                            ),
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) =>
                                                Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 0.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  showItemDrug(
                                                    context,
                                                    snapshot
                                                        .data!.analog[index].id,
                                                    position,
                                                  );
                                                },
                                                child: Container(
                                                  width: 148,
                                                  height: 189,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  margin: EdgeInsets.only(
                                                    right: 16,
                                                  ),
                                                  padding: EdgeInsets.all(8),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Stack(
                                                          children: [
                                                            Center(
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: snapshot
                                                                    .data!
                                                                    .analog[
                                                                        index]
                                                                    .imageThumbnail,
                                                                placeholder: (context,
                                                                        url) =>
                                                                    SvgPicture
                                                                        .asset(
                                                                  "assets/icons/default_image.svg",
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    SvgPicture
                                                                        .asset(
                                                                  "assets/icons/default_image.svg",
                                                                ),
                                                                fit: BoxFit
                                                                    .fitHeight,
                                                              ),
                                                            ),
                                                            Positioned(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  snapshot
                                                                          .data!
                                                                          .analog[
                                                                              index]
                                                                          .favourite =
                                                                      !snapshot
                                                                          .data!
                                                                          .analog[
                                                                              index]
                                                                          .favourite;
                                                                  if (snapshot
                                                                      .data!
                                                                      .analog[
                                                                          index]
                                                                      .favourite) {
                                                                    dataBaseFav
                                                                        .saveProducts(snapshot
                                                                            .data!
                                                                            .analog[index])
                                                                        .then((value) {
                                                                      blocItem
                                                                          .fetchAnalogUpdate();
                                                                    });
                                                                  } else {
                                                                    dataBaseFav
                                                                        .deleteProducts(snapshot
                                                                            .data!
                                                                            .analog[
                                                                                index]
                                                                            .id)
                                                                        .then(
                                                                            (value) {
                                                                      blocItem
                                                                          .fetchAnalogUpdate();
                                                                    });
                                                                  }
                                                                },
                                                                child: snapshot
                                                                        .data!
                                                                        .analog[
                                                                            index]
                                                                        .favourite
                                                                    ? SvgPicture
                                                                        .asset(
                                                                            "assets/icons/fav_select.svg")
                                                                    : SvgPicture
                                                                        .asset(
                                                                            "assets/icons/fav_unselect.svg"),
                                                              ),
                                                              top: 0,
                                                              right: 0,
                                                            ),
                                                            Positioned(
                                                              child: snapshot
                                                                          .data!
                                                                          .analog[
                                                                              index]
                                                                          .price >=
                                                                      snapshot
                                                                          .data!
                                                                          .analog[
                                                                              index]
                                                                          .basePrice
                                                                  ? Container()
                                                                  : Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              4),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: AppColors
                                                                            .red
                                                                            .withOpacity(0.1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        "-" +
                                                                            (((snapshot.data!.analog[index].basePrice - snapshot.data!.analog[index].price) * 100) ~/ snapshot.data!.analog[index].basePrice).toString() +
                                                                            "%",
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              AppColors.fontRubik,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontSize:
                                                                              12,
                                                                          height:
                                                                              1.2,
                                                                          color:
                                                                              AppColors.red,
                                                                        ),
                                                                      ),
                                                                    ),
                                                              top: 0,
                                                              left: 0,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        snapshot.data!
                                                            .analog[index].name,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily: AppColors
                                                              .fontRubik,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 12,
                                                          height: 1.5,
                                                          color: AppColors
                                                              .text_dark,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        snapshot
                                                            .data!
                                                            .analog[index]
                                                            .manufacturer
                                                            .name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily: AppColors
                                                              .fontRubik,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 10,
                                                          height: 1.2,
                                                          color:
                                                              AppColors.textGray,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      snapshot
                                                              .data!
                                                              .analog[index]
                                                              .isComing
                                                          ? Container(
                                                              height: 29,
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppColors
                                                                    .blue,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: Center(
                                                                child: RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: translate(
                                                                            "fast"),
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              AppColors.fontRubik,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontSize:
                                                                              14,
                                                                          height:
                                                                              1.2,
                                                                          color:
                                                                              AppColors.white,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : snapshot
                                                                      .data!
                                                                      .analog[
                                                                          index]
                                                                      .cardCount >
                                                                  0
                                                              ? Container(
                                                                  height: 29,
                                                                  width: double
                                                                      .infinity,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: AppColors
                                                                        .blue
                                                                        .withOpacity(
                                                                            0.12),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          if (snapshot.data!.analog[index].cardCount >
                                                                              1) {
                                                                            snapshot.data!.analog[index].cardCount =
                                                                                snapshot.data!.analog[index].cardCount - 1;
                                                                            dataBase.updateProduct(snapshot.data!.analog[index]).then((value) {
                                                                              blocItem.fetchAnalogUpdate();
                                                                            });
                                                                          } else if (snapshot.data!.analog[index].cardCount ==
                                                                              1) {
                                                                            dataBase.deleteProducts(snapshot.data!.analog[index].id).then((value) {
                                                                              blocItem.fetchAnalogUpdate();
                                                                            });
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              29,
                                                                          width:
                                                                              29,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                AppColors.blue,
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              "assets/icons/remove.svg",
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            snapshot.data!.analog[index].cardCount.toString() +
                                                                                " " +
                                                                                translate("sht"),
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: AppColors.fontRubik,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: 12,
                                                                              height: 1.2,
                                                                              color: AppColors.text_dark,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          if (snapshot.data!.analog[index].cardCount <
                                                                              snapshot.data!.analog[index].maxCount)
                                                                            snapshot.data!.analog[index].cardCount =
                                                                                snapshot.data!.analog[index].cardCount + 1;
                                                                          dataBase
                                                                              .updateProduct(snapshot.data!.analog[index])
                                                                              .then((value) {
                                                                            blocItem.fetchAnalogUpdate();
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              29,
                                                                          width:
                                                                              29,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                AppColors.blue,
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              "assets/icons/add.svg",
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : GestureDetector(
                                                                  onTap: () {
                                                                    snapshot
                                                                        .data!
                                                                        .analog[
                                                                            index]
                                                                        .cardCount = 1;
                                                                    dataBase
                                                                        .saveProducts(snapshot
                                                                            .data!
                                                                            .analog[index])
                                                                        .then((value) {
                                                                      blocItem
                                                                          .fetchAnalogUpdate();
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 29,
                                                                    width: double
                                                                        .infinity,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppColors
                                                                          .blue,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          RichText(
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: priceFormat.format(snapshot.data!.analog[index].price),
                                                                              style: TextStyle(
                                                                                fontFamily: AppColors.fontRubik,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 14,
                                                                                height: 1.2,
                                                                                color: AppColors.white,
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: translate("sum"),
                                                                              style: TextStyle(
                                                                                fontFamily: AppColors.fontRubik,
                                                                                fontWeight: FontWeight.w400,
                                                                                fontSize: 14,
                                                                                height: 1.2,
                                                                                color: AppColors.white,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            itemCount:
                                                snapshot.data!.analog.length,
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
                        Container(
                          padding: EdgeInsets.only(
                            top: 12,
                            left: 22,
                            right: 22,
                            bottom: 24,
                          ),
                          color: AppColors.white,
                          child: snapshot.data!.isComing
                              ? Container(
                                  height: 44,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      translate("fast"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        height: 1.25,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : snapshot.data!.cardCount > 0
                                  ? Container(
                                      height: 44,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.blue.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (snapshot.data!.cardCount >
                                                  1) {
                                                snapshot.data!.cardCount =
                                                    snapshot.data!.cardCount -
                                                        1;
                                                dataBase
                                                    .updateProduct(
                                                  ItemResult(
                                                    id: snapshot.data!.id,
                                                    name: snapshot.data!.name,
                                                    barcode:
                                                        snapshot.data!.barcode,
                                                    image: snapshot.data!.image,
                                                    imageThumbnail: snapshot
                                                        .data!.imageThumbnail,
                                                    price: snapshot.data!.price,
                                                    basePrice: snapshot
                                                        .data!.basePrice,
                                                    isComing:
                                                        snapshot.data!.isComing,
                                                    maxCount:
                                                        snapshot.data!.maxCount,
                                                    manufacturer: Manufacturer(
                                                      name: snapshot.data!
                                                          .manufacturer.name,
                                                    ),
                                                    favourite: true,
                                                    cardCount: snapshot
                                                        .data!.cardCount,
                                                    msg: "",
                                                  ),
                                                )
                                                    .then((value) {
                                                  blocItem.fetchItemUpdate(
                                                      position);
                                                });
                                              } else if (snapshot
                                                      .data!.cardCount ==
                                                  1) {
                                                dataBase
                                                    .deleteProducts(
                                                        snapshot.data!.id)
                                                    .then((value) {
                                                  blocItem.fetchItemUpdate(
                                                      position);
                                                });
                                              }
                                            },
                                            child: Container(
                                              height: 44,
                                              width: 44,
                                              decoration: BoxDecoration(
                                                color: AppColors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  "assets/icons/remove.svg",
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                snapshot.data!.cardCount
                                                        .toString() +
                                                    " " +
                                                    translate("sht"),
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20,
                                                  height: 1.2,
                                                  color: AppColors.text_dark,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (snapshot.data!.cardCount <
                                                  snapshot.data!.maxCount)
                                                snapshot.data!.cardCount =
                                                    snapshot.data!.cardCount +
                                                        1;
                                              dataBase
                                                  .updateProduct(
                                                ItemResult(
                                                  id: snapshot.data!.id,
                                                  name: snapshot.data!.name,
                                                  barcode:
                                                      snapshot.data!.barcode,
                                                  image: snapshot.data!.image,
                                                  imageThumbnail: snapshot
                                                      .data!.imageThumbnail,
                                                  price: snapshot.data!.price,
                                                  basePrice:
                                                      snapshot.data!.basePrice,
                                                  isComing:
                                                      snapshot.data!.isComing,
                                                  maxCount:
                                                      snapshot.data!.maxCount,
                                                  manufacturer: Manufacturer(
                                                    name: snapshot.data!
                                                        .manufacturer.name,
                                                  ),
                                                  favourite: true,
                                                  cardCount:
                                                      snapshot.data!.cardCount,
                                                  msg: "",
                                                ),
                                              )
                                                  .then((value) {
                                                blocItem
                                                    .fetchItemUpdate(position);
                                              });
                                            },
                                            child: Container(
                                              height: 44,
                                              width: 44,
                                              decoration: BoxDecoration(
                                                color: AppColors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  "assets/icons/add.svg",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        dataBase
                                            .saveProducts(
                                          ItemResult(
                                            id: snapshot.data!.id,
                                            name: snapshot.data!.name,
                                            barcode: snapshot.data!.barcode,
                                            image: snapshot.data!.image,
                                            imageThumbnail:
                                                snapshot.data!.imageThumbnail,
                                            price: snapshot.data!.price,
                                            basePrice: snapshot.data!.basePrice,
                                            isComing: snapshot.data!.isComing,
                                            maxCount: snapshot.data!.maxCount,
                                            manufacturer: Manufacturer(
                                              name: snapshot
                                                  .data!.manufacturer.name,
                                            ),
                                            favourite: true,
                                            cardCount: 1,
                                            msg: "",
                                          ),
                                        )
                                            .then((value) {
                                          blocItem.fetchItemUpdate(position);
                                        });
                                      },
                                      child: Container(
                                        height: 44,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppColors.blue,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            translate("item.card"),
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
                    );
                  }
                  return Shimmer.fromColors(
                    baseColor: AppColors.shimmerBase,
                    highlightColor: AppColors.shimmerHighlight,
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 8,
                            left: (MediaQuery.of(context).size.width - 60) / 2,
                            right: (MediaQuery.of(context).size.width - 60) / 2,
                          ),
                          height: 4,
                          width: 60,
                          color: AppColors.white,
                        ),
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 24, bottom: 24),
                            height: 240,
                            width: 240,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16, right: 16),
                          height: 15,
                          width: 250,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16, right: 16),
                          height: 22,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 24.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16, right: 16),
                          height: 22,
                          width: 125,
                          color: Colors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 40.0),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: EdgeInsets.only(left: 16, right: 16),
                          height: 40,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  static void bottomDialogOrder(
    BuildContext context,
    Function onHistory,
  ) async {
    showModalBottomSheet(
      barrierColor: Color.fromRGBO(23, 43, 77, 0.3),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              height: 365,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
                color: AppColors.white,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.text_dark.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        translate("card.order_title"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/img/best.png",
                            height: 32,
                            width: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    translate("card.order_message"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textGray,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 44,
                      margin: EdgeInsets.only(
                        bottom: 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          translate("card.order_close"),
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
                  Material(
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        RxBus.post(BottomViewModel(4),
                            tag: "EVENT_BOTTOM_VIEW");
                        onHistory();
                      },
                      child: Container(
                        height: 44,
                        color: AppColors.white,
                        child: Center(
                          child: Text(
                            translate("card.order_history"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.25,
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
