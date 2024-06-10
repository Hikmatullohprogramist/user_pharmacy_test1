import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/blocs/card_bloc.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/model/api/location_model.dart';
import 'package:pharmacy/src/model/check_error_model.dart';
import 'package:pharmacy/src/model/create_order_status_model.dart';
import 'package:pharmacy/src/model/send/access_store.dart';
import 'package:pharmacy/src/model/send/create_order_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/dialog/bottom_dialog.dart';
import 'package:pharmacy/src/ui/dialog/top_dialog.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/ui/shopping_pickup/order_card_pickup.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../static/app_colors.dart';
import 'address/choose_store_screen.dart';

class CheckoutOrderScreen extends StatefulWidget {
  final List<ProductsStore> drugs;
  final CashBackData cashBackData;

  CheckoutOrderScreen({
    required this.drugs,
    required this.cashBackData,
  });

  @override
  State<StatefulWidget> createState() {
    return _CheckoutOrderScreenState();
  }
}

class _CheckoutOrderScreenState extends State<CheckoutOrderScreen> {
  LocationModel? storeInfo;
  String firstName = "", lastName = "", number = "";
  var loading = false;
  DatabaseHelper dataBase = new DatabaseHelper();

  @override
  void initState() {
    _getFullName();
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
              translate("card.order"),
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                storeInfo == null
                    ? Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              child: Text(
                                translate("card.data_store"),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChooseStoreScreen(
                                        drugs: widget.drugs,
                                        chooseStore: (LocationModel store) {
                                          setState(() {
                                            storeInfo = store;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                );

                                // BottomDialog.showChooseStore(
                                //   context,
                                //   widget.drugs,
                                //   (value) {
                                //     setState(() {
                                //       storeInfo = value;
                                //     });
                                //   },
                                // );
                              },
                              child: Container(
                                margin: EdgeInsets.all(16),
                                height: 44,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    translate("card.choose_store"),
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
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              child: Text(
                                translate("card.data_store"),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        storeInfo!.name,
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
                                        storeInfo!.address,
                                        maxLines: 2,
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
                            SizedBox(height: 16),
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: AppColors.background,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                SizedBox(width: 16),
                                Text(
                                  translate("card.distance"),
                                  style: TextStyle(
                                    fontFamily: AppColors.fontRubik,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    height: 1.3,
                                    color: AppColors.textGray,
                                  ),
                                ),
                                Expanded(child: Container()),
                                storeInfo!.distance == 0.0
                                    ? Container()
                                    : Text(
                                        ((storeInfo!.distance ~/ 100) / 10.0)
                                                .toString() +
                                            translate("km"),
                                        style: TextStyle(
                                          fontFamily: AppColors.fontRubik,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          height: 1.6,
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
                                    height: 1.3,
                                    color: AppColors.textGray,
                                  ),
                                ),
                                Expanded(child: Container()),
                                Text(
                                  storeInfo!.mode,
                                  style: TextStyle(
                                    fontFamily: AppColors.fontRubik,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    height: 1.6,
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
                                    height: 1.3,
                                    color: AppColors.textGray,
                                  ),
                                ),
                                Expanded(child: Container()),
                                Text(
                                  Utils.numberFormat(storeInfo!.phone),
                                  style: TextStyle(
                                    fontFamily: AppColors.fontRubik,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    height: 1.6,
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChooseStoreScreen(
                                        drugs: widget.drugs,
                                        chooseStore: (LocationModel store) {
                                          setState(() {
                                            storeInfo = store;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                );

                                // BottomDialog.showChooseStore(
                                //   context,
                                //   widget.drugs,
                                //   (value) {
                                //     setState(() {
                                //       storeInfo = value;
                                //     });
                                //   },
                                // );
                              },
                              child: Container(
                                margin: EdgeInsets.all(16),
                                height: 44,
                                color: AppColors.white,
                                child: Center(
                                  child: Text(
                                    translate("card.edit"),
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
                            )
                          ],
                        ),
                      ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Text(
                          translate("card.detail_user"),
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
                      SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(width: 16),
                          Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/icons/profile.svg",
                                height: 48,
                                width: 48,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  firstName + " " + lastName,
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
                                  number,
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
                      SizedBox(height: 16),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: AppColors.background,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(width: 16),
                          Text(
                            translate("card.all_order"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              height: 1.3,
                              color: AppColors.textGray,
                            ),
                          ),
                          Expanded(child: Container()),
                          Text(
                            widget.drugs.length.toString(),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              height: 1.6,
                              color: AppColors.text_dark,
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                      storeInfo == null
                          ? Container()
                          : Container(
                              margin: EdgeInsets.only(
                                top: 16,
                                left: 16,
                                right: 16,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    translate("card.price"),
                                    style: TextStyle(
                                      fontFamily: AppColors.fontRubik,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      height: 1.3,
                                      color: AppColors.textGray,
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  Text(
                                    priceFormat.format(storeInfo!.total) +
                                        translate("sum"),
                                    style: TextStyle(
                                      fontFamily: AppColors.fontRubik,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      height: 1.6,
                                      color: AppColors.text_dark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(height: 16),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: AppColors.background,
                      ),
                      GestureDetector(
                        onTap: () {
                          BottomDialog.showEditInfo(
                            context,
                            firstName,
                            lastName,
                            number,
                            (valueFirstName, valueLastName, valueNumber) {
                              setState(() {
                                firstName = valueFirstName;
                                lastName = valueLastName;
                                number = valueNumber;
                              });
                            },
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(16),
                          height: 44,
                          color: AppColors.white,
                          child: Center(
                            child: Text(
                              translate("card.edit"),
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
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (storeInfo != null) {
                setState(() {
                  loading = true;
                });
                List<Drugs> drugs = <Drugs>[];
                var data = await dataBase.getProdu(true);
                for (int i = 0; i < data.length; i++) {
                  drugs.add(
                    Drugs(
                      drug: data[i].id,
                      qty: data[i].cardCount,
                    ),
                  );
                }
                CreateOrderModel createOrder = new CreateOrderModel(
                  device: Platform.isIOS ? "IOS" : "Android",
                  type: "self",
                  storeId: storeInfo!.id,
                  drugs: drugs,
                  fullName: firstName + " " + lastName,
                  phone: number.replaceAll(" ", "").replaceAll("+", ""),
                  shippingTime: 0,
                  address: '',
                  location: '',
                );
                var response = await Repository().fetchCreateOrder(createOrder);
                if (response.isSuccess) {
                  var result = CreateOrderStatusModel.fromJson(response.result);
                  if (result.status == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderCardPickupScreen(
                          result.data.orderId,
                          result.data.expireSelfOrder,
                          widget.cashBackData,
                          false,
                        ),
                      ),
                    );
                    setState(() {
                      loading = false;
                    });
                    dataBase.clear();
                    blocCard.fetchAllCard();
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
                      translate("network.network_title"),
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
              color: AppColors.white,
              child: Container(
                margin:
                    EdgeInsets.only(top: 12, left: 22, right: 22, bottom: 24),
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: storeInfo == null ? AppColors.gray : AppColors.blue,
                ),
                child: Center(
                  child: loading
                      ? Lottie.asset(
                          'assets/anim/white.json',
                          height: 40,
                        )
                      : Text(
                          translate("card.payment"),
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
          ),
        ],
      ),
    );
  }

  Future<void> _getFullName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('name') ?? "";
      lastName = prefs.getString('surname') ?? "";
      number = Utils.numberFormat(prefs.getString('number') ?? "");
    });
  }
}
