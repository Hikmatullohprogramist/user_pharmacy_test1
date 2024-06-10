import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/blocs/history_bloc.dart';
import 'package:pharmacy/src/model/api/cash_back_model.dart';
import 'package:pharmacy/src/model/api/history_model.dart';
import 'package:pharmacy/src/model/check_error_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/dialog/bottom_dialog.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/ui/shopping_curer/order_card_curer.dart';
import 'package:pharmacy/src/ui/shopping_pickup/order_card_pickup.dart';
import 'package:pharmacy/src/ui/sub_menu/order_number.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../static/app_colors.dart';

class HistoryOrderScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HistoryOrderScreenState();
  }
}

int pageHistory = 1;

class _HistoryOrderScreenState extends State<HistoryOrderScreen> {
  bool isLoading = false;

  ScrollController _sc = new ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    _registerBus();
    _getMoreData(1);
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(pageHistory);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    RxBus.destroy();
    _sc.dispose();
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
              translate("history.name"),
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
      body: RefreshIndicator(
        backgroundColor: AppColors.white,
        color: AppColors.blue,
        key: _refreshIndicatorKey,
        onRefresh: _refreshRegion,
        child: StreamBuilder(
          stream: blocHistory.allHistory,
          builder: (context, AsyncSnapshot<HistoryModel> snapshot) {
            if (snapshot.hasData) {
              snapshot.data!.next == "" ? isLoading = true : isLoading = false;
              return snapshot.data!.results.length > 0
                  ? ListView.builder(
                      controller: _sc,
                      itemCount: snapshot.data!.results.length + 1,
                      itemBuilder: (context, index) {
                        if (index == snapshot.data!.results.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Center(
                              child: new Opacity(
                                opacity: isLoading ? 0.0 : 1.0,
                                child: Container(
                                  height: 72,
                                  child: Lottie.asset(
                                      'assets/anim/item_load_animation.json'),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () async {
                              if (snapshot.data!.results[index].status ==
                                  "payment_waiting") {
                                if (snapshot.data!.results[index].type ==
                                    "self") {
                                  var response =
                                      await Repository().fetchCashBack();
                                  if (response.isSuccess) {
                                    var result =
                                        CashBackModel.fromJson(response.result);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderCardPickupScreen(
                                          snapshot.data!.results[index].id,
                                          snapshot.data!.results[index]
                                              .expireSelfOrder,
                                          CashBackData(
                                            total: snapshot
                                                .data!.results[index].total,
                                            cash: result.cash,
                                          ),
                                          true,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Utils.getCashBack().then(
                                      (value) => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OrderCardPickupScreen(
                                              snapshot.data!.results[index].id,
                                              snapshot.data!.results[index]
                                                  .expireSelfOrder,
                                              CashBackData(
                                                total: snapshot
                                                    .data!.results[index].total,
                                                cash: value,
                                              ),
                                              true,
                                            ),
                                          ),
                                        ),
                                      },
                                    );
                                  }
                                } else {
                                  var response =
                                      await Repository().fetchCashBack();
                                  if (response.isSuccess) {
                                    var result =
                                        CashBackModel.fromJson(response.result);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderCardCurerScreen(
                                          orderId:
                                              snapshot.data!.results[index].id,
                                          total: snapshot
                                              .data!.results[index].realTotal,
                                          cashBack: result.cash,
                                          deliveryPrice: snapshot.data!
                                              .results[index].deliveryTotal,
                                          isHistory: true,
                                        ),
                                      ),
                                    );
                                  } else {
                                    Utils.getCashBack().then(
                                      (value) => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OrderCardCurerScreen(
                                              orderId: snapshot
                                                  .data!.results[index].id,
                                              total: snapshot.data!
                                                  .results[index].realTotal,
                                              cashBack: value,
                                              deliveryPrice: snapshot.data!
                                                  .results[index].deliveryTotal,
                                              isHistory: true,
                                            ),
                                          ),
                                        ),
                                      },
                                    );
                                  }
                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderNumber(
                                      snapshot.data!.results[index],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              margin:
                                  EdgeInsets.only(top: 16, left: 16, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      top: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          translate("history.order") +
                                              snapshot.data!.results[index].id
                                                  .toString(),
                                          style: TextStyle(
                                            fontFamily: AppColors.fontRubik,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            height: 1.2,
                                            color: AppColors.textGray,
                                          ),
                                        ),
                                        Expanded(child: Container()),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: colorStatus(snapshot.data!
                                                    .results[index].status)
                                                .withOpacity(0.1),
                                          ),
                                          padding: EdgeInsets.all(8),
                                          child: Center(
                                            child: Text(
                                              translate(
                                                  "history.${snapshot.data!.results[index].status}"),
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: colorStatus(snapshot
                                                    .data!
                                                    .results[index]
                                                    .status),
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    color: AppColors.background,
                                    margin:
                                        EdgeInsets.only(top: 16, bottom: 16),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 16),
                                      Text(
                                        translate("history.type"),
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
                                        snapshot.data!.results[index].type ==
                                                "self"
                                            ? translate("history.pickup")
                                            : translate("history.delivery"),
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
                                        translate("history.count"),
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
                                        snapshot
                                            .data!.results[index].items.length
                                            .toString(),
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
                                        translate("history.price"),
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
                                        priceFormat.format(snapshot
                                                .data!.results[index].total) +
                                            translate("sum"),
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
                                  snapshot.data!.results[index].type != "self"
                                      ? SizedBox(height: 16)
                                      : Container(),
                                  snapshot.data!.results[index].type != "self"
                                      ? Row(
                                          children: [
                                            SizedBox(width: 16),
                                            Text(
                                              translate(
                                                  "history.price_delivery"),
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
                                              snapshot.data!.results[index]
                                                          .deliveryTotal ==
                                                      0.0
                                                  ? translate("free")
                                                  : priceFormat.format(snapshot
                                                          .data!
                                                          .results[index]
                                                          .deliveryTotal) +
                                                      translate("sum"),
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
                                        )
                                      : Container(),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      SizedBox(width: 16),
                                      Text(
                                        translate("history.phone"),
                                        style: TextStyle(
                                          fontFamily: AppColors.fontRubik,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          height: 1.2,
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                      Expanded(child: Container()),
                                      GestureDetector(
                                        onTap: () async {
                                          var url = "tel:" +
                                              snapshot.data!.results[index]
                                                  .store.phone
                                                  .replaceAll("+", "")
                                                  .replaceAll(" ", "")
                                                  .replaceAll("-", "")
                                                  .replaceAll(")", "")
                                                  .replaceAll("(", "");
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        },
                                        child: Text(
                                          Utils.numberFormat(snapshot.data!
                                              .results[index].store.phone),
                                          style: TextStyle(
                                            fontFamily: AppColors.fontRubik,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            height: 1.2,
                                            color: AppColors.text_dark,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                    ],
                                  ),
                                  snapshot.data!.results[index].bonus == 0
                                      ? Container()
                                      : SizedBox(height: 16),
                                  snapshot.data!.results[index].bonus == 0
                                      ? Container()
                                      : Row(
                                          children: [
                                            SizedBox(width: 16),
                                            Text(
                                              translate("menu.get_ball"),
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
                                              snapshot.data!.results[index]
                                                      .bonus
                                                      .toString() +
                                                  translate("ball"),
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
                                  snapshot.data!.results[index].bookingLabel
                                              .length >
                                          0
                                      ? Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 8,
                                          ),
                                          margin: EdgeInsets.only(
                                            top: 16,
                                            left: 16,
                                            right: 16,
                                          ),
                                          decoration: BoxDecoration(
                                              color: AppColors.red
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/attention.svg",
                                                width: 24,
                                                height: 24,
                                                color: AppColors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  snapshot.data!.results[index]
                                                      .bookingLabel,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppColors.fontRubik,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                    height: 1.67,
                                                    color: AppColors.red,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  Container(
                                    height: 1,
                                    margin: EdgeInsets.only(top: 16),
                                    width: double.infinity,
                                    color: AppColors.background,
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(16),
                                    height: 44,
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                        translate("history.about"),
                                        style: TextStyle(
                                          fontFamily: AppColors.fontRubik,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          height: 1.25,
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    )
                  : Container(
                      margin: EdgeInsets.all(16),
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
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.yellow,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Image.asset(
                              "assets/img/card_empty.png",
                              height: 32,
                              width: 32,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              top: 16,
                              left: 16,
                              right: 16,
                            ),
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                translate("history.empty_title"),
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
                            margin: EdgeInsets.only(
                              top: 8,
                              left: 16,
                              right: 16,
                            ),
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                translate("history.empty_message"),
                                textAlign: TextAlign.center,
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
                              Navigator.pop(context);
                              RxBus.post(BottomViewModel(1),
                                  tag: "EVENT_BOTTOM_VIEW");
                            },
                            child: Container(
                              margin:
                                  EdgeInsets.only(left: 16, right: 16, top: 16),
                              height: 44,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  translate("history.empty_button"),
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
                    );
            }
            return Shimmer.fromColors(
              baseColor: AppColors.shimmerBase,
              highlightColor: AppColors.shimmerHighlight,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                    height: 260,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<Null> _refreshRegion() async {
    isLoading = false;
    pageHistory = 1;
    _getMoreData(1);
  }

  void _getMoreData(int index) async {
    if (!isLoading) {
      setState(() {
        blocHistory.fetchAllHistory(index);
        pageHistory++;
      });
    }
  }

  void _registerBus() {
    RxBus.register<BottomView>(tag: "HOME_VIEW_ERROR_HISTORY").listen(
      (event) {
        BottomDialog.showNetworkError(context, () {
          isLoading = false;
          blocHistory.fetchAllHistory(1);
          pageHistory = 2;
        });
      },
    );
  }

  Color colorStatus(String status) {
    switch (status) {
      case "pending":
        {
          return Color(0xFF0A6CFF);
        }
      case "accept":
        {
          return Color(0xFF3F8AE0);
        }
      case "cancelled_by_store":
        {
          return Color(0xFF5F4B18);
        }
      case "waiting_deliverer":
        {
          return Color(0xFFEDCC57);
        }
      case "delivering":
        {
          return Color(0xFFE4E75B);
        }
      case "delivered":
        {
          return Color(0xFF4BB34B);
        }
      case "cancelled_by_admin":
        {
          return Color(0xFF818C99);
        }
      case "pick_up":
        {
          return Color(0xFF00B0DC);
        }
      case "picked_up":
        {
          return Color(0xFF4BB34B);
        }
      case "payment_waiting":
        {
          return Color(0xFFF94FB5);
        }
      case "cancelled_by_user":
        {
          return Color(0xFF1C1C1E);
        }
      case "not_paid":
        {
          return Color(0xFF1C1C1E);
        }

      default:
        {
          return Color(0xFF4CAF50);
        }
    }
  }
}
