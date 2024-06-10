import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/blocs/order_options_bloc.dart';
import 'package:pharmacy/src/blocs/store_block.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/model/api/check_order_model_new.dart';
import 'package:pharmacy/src/model/api/order_options_model.dart';
import 'package:pharmacy/src/model/database/address_model.dart';
import 'package:pharmacy/src/model/send/create_order_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/dialog/bottom_dialog.dart';
import 'package:pharmacy/src/ui/dialog/top_dialog.dart';
import 'package:pharmacy/src/ui/shopping_curer/store_list_screen.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../static/app_colors.dart';

class CurerAddressCardScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CurerAddressCardScreenState();
  }
}

class _CurerAddressCardScreenState extends State<CurerAddressCardScreen> {
  int shippingId = 0;
  AddressModel myAddress = AddressModel(id: -1);
  bool isFirst = true;
  var duration = Duration(milliseconds: 270);
  String firstName = "", lastName = "", number = "";
  bool loading = false;

  DatabaseHelper dataBase = new DatabaseHelper();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    _getFullName();
    _getOrderOption();
    blocOrderOptions.fetchOrderOptions();
    blocStore.fetchAllAddress();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<AddressModel>? allAddressInfo;
  OrderOptionsModel? orderOptions;

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
              padding: EdgeInsets.all(16),
              controller: _scrollController,
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
                        stream: blocStore.allAddressInfo,
                        builder: (context,
                            AsyncSnapshot<List<AddressModel>> snapshot) {
                          if (snapshot.hasData || allAddressInfo != null) {
                            if (snapshot.hasData) {
                              allAddressInfo = snapshot.data;
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.all(0),
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: allAddressInfo!.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      myAddress = allAddressInfo![index];
                                    });
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
                                        allAddressInfo![index].type == 1
                                            ? SvgPicture.asset(
                                                "assets/icons/home.svg",
                                                color: AppColors.textGray,
                                              )
                                            : allAddressInfo![index].type == 2
                                                ? SvgPicture.asset(
                                                    "assets/icons/work.svg",
                                                    color: AppColors.textGray,
                                                  )
                                                : SvgPicture.asset(
                                                    "assets/icons/location.svg",
                                                    color: AppColors.textGray,
                                                  ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            allAddressInfo![index].type == 1
                                                ? translate("address.home")
                                                : allAddressInfo![index].type ==
                                                        2
                                                    ? translate("address.work")
                                                    : allAddressInfo![index]
                                                        .street,
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
                                        allAddressInfo![index].type == 0
                                            ? GestureDetector(
                                                child: SvgPicture.asset(
                                                    "assets/icons/edit.svg"),
                                                onTap: () {
                                                  BottomDialog.editAddress(
                                                    context,
                                                    allAddressInfo![index],
                                                  );
                                                },
                                              )
                                            : Container(),
                                        allAddressInfo![index].type == 0
                                            ? SizedBox(width: 8)
                                            : Container(),
                                        AnimatedContainer(
                                          curve: Curves.easeInOut,
                                          duration: duration,
                                          height: 16,
                                          width: 16,
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: myAddress.id ==
                                                      allAddressInfo![index].id
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
                                              color: myAddress.id ==
                                                      allAddressInfo![index].id
                                                  ? AppColors.blue
                                                  : AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          padding: EdgeInsets.all(3),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                    ),
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
                            (value) {
                              setState(() {
                                myAddress = value;
                              });
                            },
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
                orderOptions == null
                    ? Container()
                    : Container(
                        margin: EdgeInsets.only(top: 16),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                left: 24,
                                right: 24,
                              ),
                              child: Text(
                                translate("card.type"),
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
                              margin: EdgeInsets.only(top: 16),
                              height: 1,
                              width: double.infinity,
                              color: AppColors.background,
                            ),
                            ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.only(left: 16, right: 16),
                              itemCount: orderOptions!.shippingTimes.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    if (orderOptions!.shippingTimes[index].id !=
                                        shippingId) {
                                      setState(() {
                                        shippingId = orderOptions!
                                            .shippingTimes[index].id;
                                      });
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 16),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 8,
                                    ),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                            "assets/icons/time.svg"),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            orderOptions!
                                                .shippingTimes[index].name,
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
                                          curve: Curves.easeInOut,
                                          duration: duration,
                                          height: 16,
                                          width: 16,
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: shippingId ==
                                                      orderOptions!
                                                          .shippingTimes[index]
                                                          .id
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
                                              color: shippingId ==
                                                      orderOptions!
                                                          .shippingTimes[index]
                                                          .id
                                                  ? AppColors.blue
                                                  : AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          padding: EdgeInsets.all(3),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
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
          Container(
            color: AppColors.white,
            padding: EdgeInsets.only(
              top: 12,
              left: 22,
              right: 22,
              bottom: 24,
            ),
            child: GestureDetector(
              onTap: () async {
                if (!loading && myAddress.id != -1) {
                  var uy = myAddress.dom == ""
                      ? ""
                      : "Дом/Офис: " + myAddress.dom + ", ";

                  var en = myAddress.en == ""
                      ? ""
                      : "Подъзд: " + myAddress.en + ", ";
                  var kv = myAddress.kv == ""
                      ? ""
                      : "kavartira: " + myAddress.kv + ", ";

                  var comment = myAddress.comment == ""
                      ? ""
                      : "Comment: " + myAddress.comment;

                  setState(() {
                    loading = true;
                  });

                  List<Drugs> drugs = <Drugs>[];

                  var cardItem = await dataBase.getProdu(true);
                  for (int i = 0; i < cardItem.length; i++) {
                    drugs.add(Drugs(
                      drug: cardItem[i].id,
                      qty: cardItem[i].cardCount,
                    ));
                  }
                  CreateOrderModel createOrder = new CreateOrderModel(
                    location: myAddress.lat + "," + myAddress.lng,
                    device: Platform.isIOS ? "IOS" : "Android",
                    address: myAddress.street + ", " + uy + en + kv + comment,
                    type: "shipping",
                    shippingTime: shippingId,
                    drugs: drugs,
                    fullName: firstName + " " + lastName,
                    phone: number.replaceAll(" ", "").replaceAll("+", ""),
                    storeId: 0,
                  );
                  var response =
                      await Repository().fetchCheckOrder(createOrder);
                  if (response.isSuccess) {
                    var result = CheckOrderModelNew.fromJson(response.result);
                    if (result.status == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoreListScreen(
                            createOrder: createOrder,
                            checkOrderModel: result,
                          ),
                        ),
                      );
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: myAddress.id == -1 ? AppColors.gray : AppColors.blue,
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
                          translate("card.next"),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: AppColors.fontRubik,
                            fontSize: 17,
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

  Future<void> _getFullName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('name') ?? "";
      lastName = prefs.getString('surname') ?? "";
      number = Utils.numberFormat(prefs.getString('number') ?? "");
    });
  }

  Future<void> _getOrderOption() async {
    var responseBlog = await blocOrderOptions.orderOptions.first;
    if (responseBlog.shippingTimes.length > 0) {
      setState(() {
        orderOptions = responseBlog;
        if (isFirst) {
          isFirst = false;
          shippingId = orderOptions!.shippingTimes[0].id;
        }
      });
    }
  }
}
