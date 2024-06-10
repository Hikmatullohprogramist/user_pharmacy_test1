import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/blocs/order_options_bloc.dart';
import 'package:pharmacy/src/model/api/order_options_model.dart';
import 'package:pharmacy/src/model/api/order_status_model.dart';
import 'package:pharmacy/src/model/check_error_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view_model.dart';
import 'package:pharmacy/src/model/eventBus/card_item_change_model.dart';
import 'package:pharmacy/src/model/send/create_payment_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/dialog/top_dialog.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../static/app_colors.dart';

class OrderCardPickupScreen extends StatefulWidget {
  final int orderId;
  final String message;
  final CashBackData cashBackData;
  final bool isHistory;

  OrderCardPickupScreen(
    this.orderId,
    this.message,
    this.cashBackData,
    this.isHistory,
  );

  @override
  State<StatefulWidget> createState() {
    return _OrderCardPickupScreenState();
  }
}

class _OrderCardPickupScreenState extends State<OrderCardPickupScreen> {
  double cashBackPrice = 0.0;
  int? paymentType;
  bool loading = false;

  TextEditingController cashPriceController = TextEditingController();
  static const platform = const MethodChannel('payment_launch');

  @override
  void initState() {
    blocOrderOptions.fetchOrderOptions();
    cashPriceController.addListener(() {
      try {
        if (cashPriceController.text == "") {
          setState(() {
            cashBackPrice = 0.0;
          });
        } else {
          double cashBack =
              double.parse(cashPriceController.text.replaceAll(" ", ""));
          if (cashBack > widget.cashBackData.cash ||
              cashBack > widget.cashBackData.total) {
            setState(() {
              cashPriceController.text =
                  (min(widget.cashBackData.cash, widget.cashBackData.total)
                          .toInt())
                      .toString();
              cashPriceController.selection = TextSelection.fromPosition(
                TextPosition(
                  offset: cashPriceController.text.length,
                ),
              );
              cashBackPrice =
                  min(widget.cashBackData.cash, widget.cashBackData.total);
            });
          } else {
            setState(() {
              cashBackPrice = cashBack;
            });
          }
        }
      } on Exception catch (_) {
        setState(() {
          cashPriceController.text = "";
          cashBackPrice = 0.0;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
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
              if (widget.isHistory) {
                Navigator.pop(context);
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
                RxBus.post(BottomViewModel(1),
                    tag: "EVENT_BOTTOM_CLOSE_HISTORY");
              }
            },
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                translate("payment.name"),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Text(
                            translate("payment.type"),
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
                        StreamBuilder(
                          stream: blocOrderOptions.orderOptions,
                          builder: (context,
                              AsyncSnapshot<OrderOptionsModel> snapshot) {
                            if (snapshot.hasData) {
                              return new ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.paymentTypes.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (snapshot
                                              .data!.paymentTypes[index].id !=
                                          paymentType) {
                                        setState(() {
                                          paymentType = snapshot
                                              .data!.paymentTypes[index].id;
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        top: 16,
                                        left: 16,
                                        right: 16,
                                      ),
                                      height: 48,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 8),
                                          snapshot.data!.paymentTypes[index]
                                                      .type ==
                                                  "cash"
                                              ? SvgPicture.asset(
                                                  "assets/icons/cash.svg")
                                              : snapshot
                                                          .data!
                                                          .paymentTypes[index]
                                                          .type ==
                                                      "card"
                                                  ? SvgPicture.asset(
                                                      "assets/icons/card.svg")
                                                  : SvgPicture.asset(
                                                      "assets/icons/wallet.svg"),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              snapshot.data!.paymentTypes[index]
                                                  .name
                                                  .toString(),
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
                                            duration:
                                                Duration(milliseconds: 270),
                                            curve: Curves.easeInOut,
                                            height: 16,
                                            width: 16,
                                            padding: EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: paymentType ==
                                                        snapshot
                                                            .data!
                                                            .paymentTypes[index]
                                                            .id
                                                    ? AppColors.blue
                                                    : AppColors.gray,
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
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: paymentType ==
                                                          snapshot
                                                              .data!
                                                              .paymentTypes[
                                                                  index]
                                                              .id
                                                      ? AppColors.blue
                                                      : AppColors.background,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            return Shimmer.fromColors(
                              baseColor: AppColors.shimmerBase,
                              highlightColor: AppColors.shimmerHighlight,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                itemBuilder: (_, __) => Container(
                                  height: 48,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                      top: 16, left: 16, right: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                itemCount: 4,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 16),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Text(
                            translate("payment.create"),
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
                        Container(
                          margin: EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                          ),
                          child: Row(
                            children: [
                              Text(
                                translate("payment.price_order"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.2,
                                  color: AppColors.textGray,
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Text(
                                priceFormat.format(widget.cashBackData.total) +
                                    translate(translate("sum")),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.2,
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
                        Container(
                          margin: EdgeInsets.only(
                            top: 16,
                            left: 16,
                            right: 16,
                          ),
                          child: Row(
                            children: [
                              Text(
                                translate("history.all_price"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.2,
                                  color: AppColors.textGray,
                                ),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              Text(
                                priceFormat.format(widget.cashBackData.total -
                                        cashBackPrice) +
                                    translate(translate("sum")),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  height: 1.2,
                                  color: AppColors.text_dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  widget.message.length > 1
                      ? Container(
                          margin: EdgeInsets.only(left: 16, right: 16, top: 24),
                          child: Text(
                            widget.message,
                            maxLines: 5,
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontSize: 15,
                              height: 1.2,
                              color: AppColors.blue,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            Container(
              color: AppColors.white,
              child: GestureDetector(
                onTap: () async {
                  if (paymentType != null) {
                    if (!loading) {
                      setState(() {
                        loading = true;
                      });
                      PaymentOrderModel addModel = new PaymentOrderModel(
                        orderId: widget.orderId,
                        cashPay: cashBackPrice.toInt(),
                        paymentType: paymentType!,
                        paymentRedirect: true,
                      );
                      var response = await Repository().fetchPayment(addModel);
                      if (response.isSuccess) {
                        var result = OrderStatusModel.fromJson(response.result);
                        if (result.status == 1) {
                          if (result.paymentRedirectUrl.length > 0) {
                            if (Platform.isIOS) {
                              var click = await platform.invokeMethod(
                                'click',
                                result.paymentRedirectUrl,
                              );
                              if (click == 2) {
                                await launch(result.paymentRedirectUrl);
                              }
                            } else {
                              await launch(result.paymentRedirectUrl);
                            }
                          }
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          if (!widget.isHistory) {
                            RxBus.post(
                              CardItemChangeModel(true),
                              tag: "EVENT_CARD_BOTTOM",
                            );
                          }
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
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 270),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: paymentType == null ? AppColors.gray : AppColors.blue,
                  ),
                  height: 44,
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    top: 12,
                    bottom: 24,
                    left: 22,
                    right: 22,
                  ),
                  child: Center(
                    child: loading
                        ? Lottie.asset(
                            'assets/anim/white.json',
                            height: 40,
                          )
                        : Text(
                            translate("payment.pay"),
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
      ),
      onWillPop: () async {
        if (widget.isHistory) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
          RxBus.post(BottomViewModel(1), tag: "EVENT_BOTTOM_CLOSE_HISTORY");
        }
        return false;
      },
    );
  }
}
