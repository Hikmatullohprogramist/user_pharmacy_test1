import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/blocs/items_list_block.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/database/database_helper_fav.dart';
import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view_model.dart';
import 'package:pharmacy/src/ui/dialog/bottom_dialog.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:shimmer/shimmer.dart';

import '../../static/app_colors.dart';

class ItemListScreen extends StatefulWidget {
  final String name;
  final int type;
  final String id;

  ItemListScreen({
    required this.name,
    required this.type,
    required this.id,
  });

  @override
  State<StatefulWidget> createState() {
    return _ItemListScreenState();
  }
}

class _ItemListScreenState extends State<ItemListScreen>
    with SingleTickerProviderStateMixin {
  int page = 1;
  String priceMax = "";
  String ordering = "name";
  DatabaseHelper dataBase = new DatabaseHelper();
  DatabaseHelperFav dataBaseFav = new DatabaseHelperFav();
  bool isLoading = false;
  int lastPosition = 0;
  ScrollController _sc = new ScrollController();
  AnimationController? controller;
  Animation<Offset>? offset;
  var duration = Duration(milliseconds: 270);

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: duration,
    );
    offset = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.0, 1.0),
    ).animate(controller!);
    super.initState();
    _registerBus();
    _getMoreData(1);
    _sc.addListener(() {
      if (_sc.offset ~/ 10 > 0) {
        if (_sc.offset ~/ 10 < lastPosition) {
          controller!.reverse();
          lastPosition = _sc.offset ~/ 10;
        } else if (_sc.offset ~/ 10 != lastPosition) {
          controller!.forward();
          lastPosition = _sc.offset ~/ 10;
        }
      }
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page);
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
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
              widget.name,
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
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(110, 120, 146, 0.05),
                offset: Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 0,
              )
            ]),
          ),
          Expanded(
            child: StreamBuilder(
              stream: blocItemsList.allItemsList,
              builder: (context, AsyncSnapshot<ItemModel> snapshot) {
                if (snapshot.hasData) {
                  snapshot.data!.next == ""
                      ? isLoading = true
                      : isLoading = false;
                  return snapshot.data!.results.length > 0
                      ? Stack(
                          children: [
                            ListView.builder(
                              controller: _sc,
                              itemCount: snapshot.data!.results.length + 1,
                              itemBuilder: (BuildContext ctxt, int index) {
                                if (index == snapshot.data!.results.length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new Center(
                                      child: new Opacity(
                                        opacity: isLoading ? 0.0 : 1.0,
                                        child: Container(
                                          height: 64,
                                          child: Lottie.asset(
                                              'assets/anim/item_load_animation.json'),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      RxBus.post(
                                          BottomViewModel(
                                            snapshot.data!.results[index].id,
                                          ),
                                          tag: "EVENT_BOTTOM_ITEM_ALL");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      width: double.infinity,
                                      margin: EdgeInsets.only(
                                          top: 16, left: 16, right: 16),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 85,
                                            width: 80,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  child: CachedNetworkImage(
                                                    height: 80,
                                                    width: 80,
                                                    imageUrl: snapshot
                                                        .data!
                                                        .results[index]
                                                        .imageThumbnail,
                                                    placeholder:
                                                        (context, url) =>
                                                            SvgPicture.asset(
                                                      "assets/icons/default_image.svg",
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            SvgPicture.asset(
                                                      "assets/icons/default_image.svg",
                                                    ),
                                                  ),
                                                  bottom: 0,
                                                ),
                                                Positioned(
                                                  child: snapshot
                                                              .data!
                                                              .results[index]
                                                              .price >=
                                                          snapshot
                                                              .data!
                                                              .results[index]
                                                              .basePrice
                                                      ? Container()
                                                      : Container(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors.red,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Text(
                                                            "-" +
                                                                (((snapshot.data!.results[index].basePrice - snapshot.data!.results[index].price) *
                                                                            100) ~/
                                                                        snapshot
                                                                            .data!
                                                                            .results[index]
                                                                            .basePrice)
                                                                    .toString() +
                                                                "%",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppColors
                                                                      .fontRubik,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 12,
                                                              height: 1.2,
                                                              color: AppColors
                                                                  .white,
                                                            ),
                                                          ),
                                                        ),
                                                  top: 0,
                                                  left: 0,
                                                )
                                              ],
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
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot
                                                        .data!
                                                        .results[index]
                                                        .manufacturer
                                                        .name,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppColors.fontRubik,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 10,
                                                      height: 1.2,
                                                      color: AppColors.textGray,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    snapshot.data!
                                                        .results[index].name,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppColors.fontRubik,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 14,
                                                      height: 1.5,
                                                      color: AppColors.text_dark,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                      top: 8,
                                                    ),
                                                    child: Row(
                                                      children: <Widget>[
                                                        snapshot
                                                                    .data!
                                                                    .results[
                                                                        index]
                                                                    .cardCount >
                                                                0
                                                            ? Container(
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
                                                                          color:
                                                                              AppColors.blue,
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
                                                                        if (snapshot.data!.results[index].cardCount >
                                                                            1) {
                                                                          snapshot
                                                                              .data!
                                                                              .results[index]
                                                                              .cardCount = snapshot.data!.results[index].cardCount - 1;
                                                                          dataBase
                                                                              .updateProduct(snapshot.data!.results[index])
                                                                              .then((value) {
                                                                            blocItemsList.update(widget.type);
                                                                          });
                                                                        } else if (snapshot.data!.results[index].cardCount ==
                                                                            1) {
                                                                          dataBase
                                                                              .deleteProducts(snapshot.data!.results[index].id)
                                                                              .then((value) {
                                                                            blocItemsList.update(widget.type);
                                                                          });
                                                                        }
                                                                      },
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          snapshot.data!.results[index].cardCount.toString() +
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
                                                                            .data!
                                                                            .results[
                                                                                index]
                                                                            .cardCount = snapshot
                                                                                .data!.results[index].cardCount +
                                                                            1;
                                                                        dataBase
                                                                            .updateProduct(snapshot.data!.results[index])
                                                                            .then((value) {
                                                                          blocItemsList
                                                                              .update(widget.type);
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
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  snapshot
                                                                      .data!
                                                                      .results[
                                                                          index]
                                                                      .cardCount = 1;

                                                                  dataBase
                                                                      .saveProducts(snapshot
                                                                          .data!
                                                                          .results[index])
                                                                      .then((value) {
                                                                    blocItemsList
                                                                        .update(
                                                                            widget.type);
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 28,
                                                                  width: 147,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .all(
                                                                      Radius
                                                                          .circular(
                                                                              8),
                                                                    ),
                                                                    color:
                                                                        AppColors
                                                                            .blue,
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      translate("lan") !=
                                                                              "2"
                                                                          ? Text(
                                                                              translate("from"),
                                                                              style: TextStyle(
                                                                                fontFamily: AppColors.fontRubik,
                                                                                fontWeight: FontWeight.normal,
                                                                                fontSize: 14,
                                                                                color: AppColors.white,
                                                                              ),
                                                                            )
                                                                          : Container(),
                                                                      Text(
                                                                        priceFormat.format(snapshot.data!.results[index].price) +
                                                                            translate("sum"),
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              AppColors.fontRubik,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              AppColors.white,
                                                                        ),
                                                                      ),
                                                                      translate("lan") ==
                                                                              "2"
                                                                          ? Text(
                                                                              translate("from"),
                                                                              style: TextStyle(
                                                                                fontFamily: AppColors.fontRubik,
                                                                                fontWeight: FontWeight.normal,
                                                                                fontSize: 14,
                                                                                color: AppColors.white,
                                                                              ),
                                                                            )
                                                                          : Container(),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                        Expanded(
                                                          child: Container(),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (snapshot
                                                                .data!
                                                                .results[index]
                                                                .favourite) {
                                                              dataBaseFav
                                                                  .deleteProducts(
                                                                      snapshot
                                                                          .data!
                                                                          .results[
                                                                              index]
                                                                          .id)
                                                                  .then(
                                                                      (value) {
                                                                blocItemsList
                                                                    .update(widget
                                                                        .type);
                                                              });
                                                            } else {
                                                              dataBaseFav
                                                                  .saveProducts(
                                                                      snapshot
                                                                          .data!
                                                                          .results[index])
                                                                  .then((value) {
                                                                blocItemsList
                                                                    .update(widget
                                                                        .type);
                                                              });
                                                            }
                                                          },
                                                          child: snapshot
                                                                  .data!
                                                                  .results[
                                                                      index]
                                                                  .favourite
                                                              ? SvgPicture.asset(
                                                                  "assets/icons/fav_select.svg")
                                                              : SvgPicture.asset(
                                                                  "assets/icons/fav_unselect.svg"),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: SlideTransition(
                                position: offset!,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      BottomDialog.showFilter(
                                        context,
                                        ordering,
                                        priceMax,
                                        (orderingValue, priceMaxValue) {
                                          ordering = orderingValue;
                                          priceMax = priceMaxValue == "0"
                                              ? ""
                                              : priceMaxValue;
                                          page = 1;
                                          isLoading = false;
                                          _getMoreData(1);
                                        },
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right: 24,
                                        bottom: 32,
                                      ),
                                      height: 56,
                                      width: 56,
                                      child: Center(
                                        child: SvgPicture.asset(
                                            "assets/icons/filters.svg"),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(56),
                                        color: AppColors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      : Column(
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
                                    translate("item.empty_title"),
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
                                    translate("item.empty_message"),
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
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
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
                                          translate("item.home"),
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
                        );
                }
                return Shimmer.fromColors(
                  baseColor: AppColors.shimmerBase,
                  highlightColor: AppColors.shimmerHighlight,
                  child: new ListView.builder(
                    itemCount: 20,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return Container(
                        height: 117,
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _registerBus() {
    RxBus.register<BottomView>(tag: "LIST_VIEW_ERROR_NETWORK").listen(
      (event) {
        BottomDialog.showNetworkError(context, () {
          page = 1;
          _getMoreData(page);
        });
      },
    );
  }

  void _getMoreData(int index) async {
    if (!isLoading) {
      switch (widget.type) {
        case 1:
          {
            /// recently
            blocItemsList.fetchAllRecently(
              page,
              ordering,
              priceMax,
            );
            break;
          }
        case 2:
          {
            ///category
            blocItemsList.fetchCategory(
              widget.id,
              page,
              ordering,
              priceMax,
            );
            break;
          }
        case 3:
          {
            ///Best item
            blocItemsList.fetchAllBestItem(
              page,
              ordering,
              priceMax,
            );
            break;
          }

        case 4:
          {
            ///Best item
            blocItemsList.fetchAllCollItem(
              page,
              ordering,
              priceMax,
            );
            break;
          }
        case 5:
          {
            ///IDS
            blocItemsList.fetchAllIdsItem(
              widget.id,
              page,
              ordering,
              priceMax,
            );
            break;
          }
        case 6:
          {
            ///search
            blocItemsList.fetchAllSearchItem(
              widget.id,
              page,
              ordering,
              priceMax,
            );
            break;
          }
      }
      page++;
    }
  }
}
