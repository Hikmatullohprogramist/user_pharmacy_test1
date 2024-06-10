import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/static/app_colors.dart';
import 'package:pharmacy/src/blocs/card_bloc.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/model/api/check_order_model_new.dart';
import 'package:pharmacy/src/model/create_order_status_model.dart';
import 'package:pharmacy/src/model/send/create_order_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/dialog/top_dialog.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/ui/shopping_curer/order_card_curer.dart';

class StoreListScreen extends StatefulWidget {
  final CreateOrderModel createOrder;
  final CheckOrderModelNew checkOrderModel;

  StoreListScreen({
    required this.createOrder,
    required this.checkOrderModel,
  });

  @override
  State<StatefulWidget> createState() {
    return _StoreListScreenState();
  }
}

class _StoreListScreenState extends State<StoreListScreen> {
  DatabaseHelper dataBase = new DatabaseHelper();
  bool loading = false;
  ScrollController _scrollController = new ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              translate("card.choose_store"),
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
      body: widget.checkOrderModel.data.stores.length == 0
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/img/empty_store.png",
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                      Text(
                        translate("address.not_store_delivery"),
                        style: TextStyle(
                          fontFamily: AppColors.fontRubik,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.2,
                          color: AppColors.text_dark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        translate("address.not_store_message"),
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
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 44,
                          margin: EdgeInsets.only(top: 16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              translate("address.back"),
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
              ],
            )
          : Stack(
              children: [
                ListView(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: widget.checkOrderModel.data.stores.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return GestureDetector(
                          onTap: () async {
                            widget.createOrder.storeId =
                                widget.checkOrderModel.data.stores[index].id;
                            setState(() {
                              loading = true;
                            });
                            var response = await Repository()
                                .fetchCreateOrder(widget.createOrder);

                            if (response.isSuccess) {
                              var result = CreateOrderStatusModel.fromJson(
                                  response.result);
                              if (result.status == 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderCardCurerScreen(
                                      orderId: result.data.orderId,
                                      total: result.data.total,
                                      cashBack: result.data.cash,
                                      deliveryPrice: result.data.isUserPay
                                          ? result.data.deliverySum
                                          : 0.0,
                                      isHistory: false,
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
                          },
                          child: Container(
                            margin:
                                EdgeInsets.only(top: 16, left: 16, right: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.only(
                              top: 16,
                              bottom: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.checkOrderModel.data
                                                .stores[index].name,
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
                                            widget.checkOrderModel.data
                                                .stores[index].address,
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
                                      priceFormat.format(widget.checkOrderModel
                                              .data.stores[index].total) +
                                          translate("sum"),
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
                                      translate("card.price_delivery"),
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
                                      widget.checkOrderModel.data.stores[index]
                                                  .deliverySum ==
                                              0.0
                                          ? translate("free")
                                          : priceFormat.format(widget
                                                  .checkOrderModel
                                                  .data
                                                  .stores[index]
                                                  .deliverySum) +
                                              translate("sum"),
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
                                      translate("card.type_price"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        height: 1.3,
                                        color: AppColors.textGray,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          widget.checkOrderModel.data
                                              .stores[index].text,
                                          style: TextStyle(
                                            fontFamily: AppColors.fontRubik,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            height: 1.6,
                                            color: AppColors.text_dark,
                                          ),
                                        ),
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
                                      translate("card.all"),
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
                                      priceFormat.format(widget
                                                  .checkOrderModel
                                                  .data
                                                  .stores[index]
                                                  .deliverySum +
                                              widget.checkOrderModel.data
                                                  .stores[index].total) +
                                          translate("sum"),
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
                                SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  height: 44,
                                  margin: EdgeInsets.only(left: 16, right: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      translate("card.choose_store_del"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        height: 1.2,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                loading
                    ? Container(
                        color: AppColors.white.withOpacity(0.6),
                        child: Align(
                          alignment: Alignment.center,
                          child: Lottie.asset(
                            'assets/anim/blue.json',
                            height: 120,
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
    );
  }
}
