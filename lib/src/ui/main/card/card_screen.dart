import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/blocs/card_bloc.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/model/api/min_sum.dart';
import 'package:pharmacy/src/model/check_error_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view_model.dart';
import 'package:pharmacy/src/model/send/access_store.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/dialog/top_dialog.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/ui/main/main_screen.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../static/app_colors.dart';

class CardScreen extends StatefulWidget {
  final Function(CashBackData data) onPickup;
  final Function onCurer;
  final Function onLogin;
  final Function(int id) deleteItem;

  CardScreen({
    required this.onPickup,
    required this.onCurer,
    required this.onLogin,
    required this.deleteItem,
  });

  @override
  State<StatefulWidget> createState() {
    return _CardScreenState();
  }
}

bool isLogin = false;

class _CardScreenState extends State<CardScreen> {
  double allPrice = 0;
  var loadingPickup = false;
  var loadingDelivery = false;
  bool isNext = false;
  List<CheckErrorData> errorData = <CheckErrorData>[];
  int minSum = 0;
  DatabaseHelper dataBase = new DatabaseHelper();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    Repository().fetchMinSum().then((value) {
      if (value.isSuccess) {
        setState(() {
          minSum = MinSum.fromJson(value.result).min;
        });
      }
    });
    _registerBus();
    super.initState();
  }

  @override
  void dispose() {
    RxBus.destroy();
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
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              translate("card.name"),
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
      body: StreamBuilder(
        stream: blocCard.allCard,
        builder: (context, AsyncSnapshot<List<ItemResult>> snapshot) {
          if (snapshot.hasData) {
            allPrice = 0.0;
            for (int i = 0; i < snapshot.data!.length; i++) {
              allPrice +=
                  (snapshot.data![i].cardCount * snapshot.data![i].price);
            }

            allPrice.toInt() >= minSum ? isNext = true : isNext = false;

            if (errorData.length > 0) {
              for (int i = 0; i < errorData.length; i++) {
                for (int j = 0; j < snapshot.data!.length; j++) {
                  if (errorData[i].drugId == snapshot.data![j].id) {
                    snapshot.data![j].msg = errorData[i].msg;
                  }
                }
              }
            }
            return Container(
              margin: EdgeInsets.all(16),
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
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: translate("card.choose"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.2,
                              color: AppColors.text_dark,
                            ),
                          ),
                          TextSpan(
                            text: snapshot.data!.length.toString(),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              height: 1.2,
                              color: AppColors.text_dark,
                            ),
                          ),
                          TextSpan(
                            text: translate("card.item"),
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
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: AppColors.background,
                  ),
                  Expanded(
                    child: snapshot.data!.length == 0
                        ? Column(
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
                                    translate("card.empty_title"),
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
                                    translate("card.empty_message"),
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
                                  RxBus.post(BottomViewModel(1),
                                      tag: "EVENT_BOTTOM_VIEW");
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: 16, right: 16, top: 16),
                                  height: 44,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      translate("card.empty_button"),
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
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: ListView(
                              controller: _scrollController,
                              padding: EdgeInsets.only(bottom: 24),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        RxBus.post(
                                            BottomViewModel(
                                              snapshot.data![index].id,
                                            ),
                                            tag: "EVENT_BOTTOM_ITEM_ALL");
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(top: 16),
                                        color: AppColors.white,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(width: 8),
                                                CachedNetworkImage(
                                                  height: 80,
                                                  width: 80,
                                                  imageUrl: snapshot
                                                      .data![index]
                                                      .imageThumbnail,
                                                  placeholder: (context, url) =>
                                                      SvgPicture.asset(
                                                    "assets/icons/default_image.svg",
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          SvgPicture.asset(
                                                    "assets/icons/default_image.svg",
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                      right: 8,
                                                      left: 8,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          snapshot
                                                              .data![index]
                                                              .manufacturer
                                                              .name,
                                                          style: TextStyle(
                                                            fontFamily: AppColors
                                                                .fontRubik,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 10,
                                                            height: 1.2,
                                                            color: AppColors
                                                                .textGray,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          snapshot.data![index]
                                                              .name,
                                                          style: TextStyle(
                                                            fontFamily: AppColors
                                                                .fontRubik,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 14,
                                                            height: 1.5,
                                                            color: AppColors
                                                                .text_dark,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            translate("lan") !=
                                                                    "2"
                                                                ? Text(
                                                                    translate(
                                                                        "from"),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          AppColors
                                                                              .fontRubik,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          14,
                                                                      height:
                                                                          1.5,
                                                                      color: AppColors
                                                                          .text_dark,
                                                                    ),
                                                                  )
                                                                : Container(),
                                                            Text(
                                                              priceFormat.format(snapshot
                                                                      .data![
                                                                          index]
                                                                      .price) +
                                                                  translate(
                                                                      "sum"),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppColors
                                                                        .fontRubik,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                                height: 1.5,
                                                                color: AppColors
                                                                    .text_dark,
                                                              ),
                                                            ),
                                                            translate("lan") ==
                                                                    "2"
                                                                ? Text(
                                                                    translate(
                                                                        "from"),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          AppColors
                                                                              .fontRubik,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          14,
                                                                      height:
                                                                          1.5,
                                                                      color: AppColors
                                                                          .text_dark,
                                                                    ),
                                                                  )
                                                                : Container(),
                                                            Expanded(
                                                                child:
                                                                    Container()),
                                                            SizedBox(
                                                              width: 7,
                                                            ),
                                                            Text(
                                                              snapshot
                                                                  .data![index]
                                                                  .msg,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppColors
                                                                        .fontRubik,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 12,
                                                                color: AppColors
                                                                    .red,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                            top: 8,
                                                          ),
                                                          child: Row(
                                                            children: <Widget>[
                                                              Container(
                                                                height: 29,
                                                                width: 147,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppColors
                                                                      .blue
                                                                      .withOpacity(
                                                                          0.12),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    8,
                                                                  ),
                                                                ),
                                                                child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    GestureDetector(
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            29,
                                                                        width:
                                                                            29,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: snapshot.data![index].cardCount == 1
                                                                              ? AppColors.gray
                                                                              : AppColors.blue,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              SvgPicture.asset("assets/icons/remove.svg"),
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        if (snapshot.data![index].cardCount >
                                                                            1) {
                                                                          snapshot
                                                                              .data![index]
                                                                              .cardCount = snapshot.data![index].cardCount - 1;
                                                                          dataBase
                                                                              .updateProduct(snapshot.data![index])
                                                                              .then((value) {
                                                                            blocCard.fetchAllCard();
                                                                          });
                                                                        }
                                                                      },
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          snapshot.data![index].cardCount.toString() +
                                                                              " " +
                                                                              translate("item.sht"),
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
                                                                                AppColors.text_dark,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        snapshot
                                                                            .data![
                                                                                index]
                                                                            .cardCount = snapshot
                                                                                .data![index].cardCount +
                                                                            1;
                                                                        dataBase
                                                                            .updateProduct(snapshot.data![index])
                                                                            .then((value) {
                                                                          blocCard
                                                                              .fetchAllCard();
                                                                        });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              AppColors.blue,
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                        ),
                                                                        height:
                                                                            29,
                                                                        width:
                                                                            29,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              SvgPicture.asset("assets/icons/add.svg"),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    Container(),
                                                              ),
                                                              Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: InkWell(
                                                                  customBorder:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            56),
                                                                  ),
                                                                  onTap: () {
                                                                    widget.deleteItem(
                                                                        snapshot
                                                                            .data![index]
                                                                            .id);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 56,
                                                                    width: 56,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppColors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.01),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                        56,
                                                                      ),
                                                                    ),
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            16),
                                                                    child: SvgPicture
                                                                        .asset(
                                                                      "assets/icons/delete_item.svg",
                                                                      height:
                                                                          24,
                                                                      width: 24,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 1,
                                              color: AppColors.background,
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (isLogin) {
                                      if (isNext) {
                                        errorData = <CheckErrorData>[];
                                        setState(() {
                                          loadingDelivery = true;
                                        });
                                        AccessStore? addModel;
                                        List<ProductsStore> drugs =
                                            <ProductsStore>[];

                                        var databaseItem =
                                            await dataBase.getProduct();

                                        for (int i = 0;
                                            i < databaseItem.length;
                                            i++) {
                                          drugs.add(
                                            ProductsStore(
                                              drugId: databaseItem[i].id,
                                              qty: databaseItem[i].cardCount,
                                            ),
                                          );
                                        }
                                        addModel = new AccessStore(
                                          lat: lat,
                                          lng: lng,
                                          products: drugs,
                                        );

                                        var response = await Repository()
                                            .fetchCheckErrorDelivery(
                                          addModel,
                                        );
                                        if (response.isSuccess) {
                                          var result = CheckErrorModel.fromJson(
                                              response.result);
                                          if (result.error == 0) {
                                            widget.onCurer();
                                            setState(() {
                                              loadingDelivery = false;
                                            });
                                          } else {
                                            setState(() {
                                              loadingDelivery = false;
                                              errorData.addAll(result.errors);
                                              TopDialog.errorMessage(
                                                context,
                                                result.msg,
                                              );
                                            });
                                          }
                                        } else if (response.status == -1) {
                                          setState(() {
                                            loadingDelivery = false;
                                            TopDialog.errorMessage(
                                              context,
                                              translate(
                                                  "network.network_title"),
                                            );
                                          });
                                        } else {
                                          setState(() {
                                            loadingDelivery = false;
                                            TopDialog.errorMessage(
                                              context,
                                              response.result["msg"],
                                            );
                                          });
                                        }
                                      }
                                    } else {
                                      widget.onLogin();
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isNext
                                          ? AppColors.blue
                                          : AppColors.gray,
                                    ),
                                    height: 44,
                                    width: double.infinity,
                                    margin: EdgeInsets.only(
                                      top: 24,
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: Center(
                                      child: loadingDelivery
                                          ? Lottie.asset(
                                              'assets/anim/white.json',
                                              height: 40,
                                            )
                                          : Text(
                                              translate("card.delivery"),
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
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                    top: 16,
                                    left: 16,
                                    right: 16,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      onTap: () async {
                                        if (isLogin) {
                                          if (isNext) {
                                            errorData = <CheckErrorData>[];
                                            setState(() {
                                              loadingPickup = true;
                                            });
                                            AccessStore? addModel;
                                            List<ProductsStore> drugs =
                                                <ProductsStore>[];

                                            var databaseItem =
                                                await dataBase.getProduct();

                                            for (int i = 0;
                                                i < databaseItem.length;
                                                i++) {
                                              drugs.add(
                                                ProductsStore(
                                                  drugId: databaseItem[i].id,
                                                  qty:
                                                      databaseItem[i].cardCount,
                                                ),
                                              );
                                            }
                                            addModel = new AccessStore(
                                              lat: lat,
                                              lng: lng,
                                              products: drugs,
                                            );

                                            var response = await Repository()
                                                .fetchCheckErrorPickup(
                                              addModel,
                                            );

                                            if (response.isSuccess) {
                                              var result =
                                                  CheckErrorModel.fromJson(
                                                      response.result);
                                              if (result.error == 0) {
                                                errorData = <CheckErrorData>[];
                                                widget.onPickup(result.data);
                                                setState(() {
                                                  loadingPickup = false;
                                                });
                                              } else {
                                                setState(() {
                                                  loadingPickup = false;
                                                  errorData =
                                                      <CheckErrorData>[];
                                                  errorData
                                                      .addAll(result.errors);
                                                  TopDialog.errorMessage(
                                                    context,
                                                    result.msg,
                                                  );
                                                });
                                              }
                                            } else if (response.status == -1) {
                                              setState(() {
                                                loadingPickup = false;
                                                TopDialog.errorMessage(
                                                  context,
                                                  translate(
                                                      "network.network_title"),
                                                );
                                              });
                                            } else {
                                              setState(() {
                                                loadingPickup = false;
                                                TopDialog.errorMessage(
                                                  context,
                                                  response.result["msg"],
                                                );
                                              });
                                            }
                                          }
                                        } else {
                                          widget.onLogin();
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.textGray,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: loadingPickup
                                              ? Lottie.asset(
                                                  'assets/anim/gray.json',
                                                  height: 40,
                                                )
                                              : Text(
                                                  translate("card.take"),
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppColors.fontRubik,
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
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: 10,
              itemBuilder: (_, __) => Container(
                height: 160,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              top: 16,
                              left: 15,
                              right: 14,
                              bottom: 22.5,
                            ),
                            height: 112,
                            width: 112,
                            color: AppColors.white,
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 17),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 18,
                                  ),
                                  Container(
                                    height: 13,
                                    width: double.infinity,
                                    color: AppColors.white,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 3),
                                    height: 11,
                                    width: 120,
                                    color: AppColors.white,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 25),
                                    height: 13,
                                    width: 120,
                                    color: AppColors.white,
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
              ),
            ),
          );
        },
      ),
    );
  }

  void _registerBus() {
    RxBus.register<BottomView>(tag: "CARD_VIEW").listen((event) {
      if (event.title) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 270),
          curve: Curves.easeInOut,
        );
      }
    });
  }
}
