import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pharmacy/src/blocs/store_block.dart';
import 'package:pharmacy/src/model/database/address_model.dart';
import 'package:pharmacy/src/ui/dialog/bottom_dialog.dart';

import '../../static/app_colors.dart';

class MyAddressScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAddressScreenState();
  }
}

class _MyAddressScreenState extends State<MyAddressScreen> {
  @override
  void initState() {
    blocStore.fetchAddress();
    blocStore.fetchAddressHome();
    blocStore.fetchAddressWork();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4.0,
        shadowColor: Color.fromRGBO(110, 120, 146, 0.1),
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
              translate("address.name"),
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
        padding: EdgeInsets.all(16),
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 1),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(24),
                topLeft: Radius.circular(24),
              ),
            ),
            child: Text(
              translate("address.delivery_address"),
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
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                StreamBuilder(
                  stream: blocStore.allAddressHome,
                  builder: (context, AsyncSnapshot<AddressModel> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        height: 48,
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            SvgPicture.asset("assets/icons/home.svg"),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                translate("address.home"),
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
                            GestureDetector(
                              onTap: () {
                                BottomDialog.editAddress(
                                  context,
                                  snapshot.data!,
                                );
                              },
                              child: SvgPicture.asset("assets/icons/edit.svg"),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                BottomDialog.showDeleteAddress(
                                  context,
                                  snapshot.data!.id,
                                  () {
                                    blocStore.fetchAddressHome();
                                  },
                                );
                              },
                              child: SvgPicture.asset(
                                "assets/icons/delete_item.svg",
                              ),
                            ),
                            SizedBox(width: 8),
                          ],
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        BottomDialog.addAddress(
                          context,
                          1,
                          (value) {},
                        );
                      },
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            SvgPicture.asset("assets/icons/home.svg"),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                translate("address.home"),
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
                            SvgPicture.asset("assets/icons/edit.svg"),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                StreamBuilder(
                  stream: blocStore.allAddressWork,
                  builder: (context, AsyncSnapshot<AddressModel> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        height: 48,
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            SvgPicture.asset("assets/icons/work.svg"),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                translate("address.work"),
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
                            GestureDetector(
                              onTap: () {
                                BottomDialog.editAddress(
                                    context, snapshot.data!);
                              },
                              child: SvgPicture.asset("assets/icons/edit.svg"),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                BottomDialog.showDeleteAddress(
                                  context,
                                  snapshot.data!.id,
                                  () {
                                    blocStore.fetchAddressWork();
                                  },
                                );
                              },
                              child: SvgPicture.asset(
                                  "assets/icons/delete_item.svg"),
                            ),
                            SizedBox(width: 8),
                          ],
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        BottomDialog.addAddress(
                          context,
                          2,
                          (value) {},
                        );
                      },
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            SvgPicture.asset("assets/icons/work.svg"),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                translate("address.work"),
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
                            SvgPicture.asset("assets/icons/edit.svg"),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                StreamBuilder(
                  stream: blocStore.allAddress,
                  builder:
                      (context, AsyncSnapshot<List<AddressModel>> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 48,
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/location.svg",
                                  color: AppColors.textGray,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    snapshot.data![index].street,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                GestureDetector(
                                  onTap: () {
                                    BottomDialog.editAddress(
                                      context,
                                      snapshot.data![index],
                                    );
                                  },
                                  child:
                                      SvgPicture.asset("assets/icons/edit.svg"),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    BottomDialog.showDeleteAddress(
                                      context,
                                      snapshot.data![index].id,
                                      () {
                                        blocStore.fetchAddress();
                                      },
                                    );
                                  },
                                  child: SvgPicture.asset(
                                      "assets/icons/delete_item.svg"),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return Container();
                  },
                ),
                GestureDetector(
                  onTap: () {
                    BottomDialog.addAddress(
                      context,
                      0,
                      (value) {},
                    );
                  },
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/location.svg",
                          color: AppColors.textGray,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            translate("address.add"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              height: 1.2,
                              color: AppColors.textGray,
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
        ],
      ),
    );
  }
}
