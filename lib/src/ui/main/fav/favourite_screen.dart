import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pharmacy/src/blocs/fav_bloc.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/database/database_helper_fav.dart';
import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view_model.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../static/app_colors.dart';

class FavouriteScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FavouriteScreenState();
  }
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  DatabaseHelper dataBaseCard = new DatabaseHelper();
  DatabaseHelperFav dataBaseFav = new DatabaseHelperFav();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
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
    blocFav.fetchAllFav();
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
              translate("fav.name"),
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
        stream: blocFav.allFav,
        builder: (context, AsyncSnapshot<List<ItemResult>> snapshot) {
          if (snapshot.hasData) {
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
                            text: translate("fav.choose"),
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
                            text: translate("fav.item"),
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
                                  "assets/img/fav_empty.png",
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
                                    translate("fav.empty_title"),
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
                                    translate("fav.empty_message"),
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
                                      translate("fav.empty_button"),
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
                            child: ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data!.length,
                              padding: EdgeInsets.only(bottom: 24),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    RxBus.post(
                                        BottomViewModel(
                                            snapshot.data![index].id),
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
                                                  .data![index].imageThumbnail,
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
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      snapshot.data![index]
                                                          .manufacturer.name,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppColors.fontRubik,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 10,
                                                        height: 1.2,
                                                        color:
                                                            AppColors.textGray,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      snapshot.data![index].name,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppColors.fontRubik,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 14,
                                                        height: 1.5,
                                                        color:
                                                            AppColors.text_dark,
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
                                                        translate("lan") != "2"
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
                                                                  fontSize: 14,
                                                                  height: 1.5,
                                                                  color: AppColors
                                                                      .text_dark,
                                                                ),
                                                              )
                                                            : Container(),
                                                        Text(
                                                          priceFormat.format(
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .price) +
                                                              translate("sum"),
                                                          style: TextStyle(
                                                            fontFamily: AppColors
                                                                .fontRubik,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14,
                                                            height: 1.5,
                                                            color: AppColors
                                                                .text_dark,
                                                          ),
                                                        ),
                                                        translate("lan") == "2"
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
                                                                  fontSize: 14,
                                                                  height: 1.5,
                                                                  color: AppColors
                                                                      .text_dark,
                                                                ),
                                                              )
                                                            : Container(),
                                                        Expanded(
                                                            child: Container()),
                                                      ],
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        bottom: 16,
                                                        top: 8,
                                                      ),
                                                      child: Row(
                                                        children: <Widget>[
                                                          snapshot.data![index]
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
                                                                          if (snapshot.data![index].cardCount >
                                                                              1) {
                                                                            snapshot.data![index].cardCount =
                                                                                snapshot.data![index].cardCount - 1;
                                                                            dataBaseCard.updateProduct(snapshot.data![index]).then((value) {
                                                                              blocFav.fetchAllFav();
                                                                            });
                                                                          } else if (snapshot.data![index].cardCount ==
                                                                              1) {
                                                                            dataBaseCard.deleteProducts(snapshot.data![index].id).then((value) {
                                                                              blocFav.fetchAllFav();
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
                                                                          snapshot
                                                                              .data![index]
                                                                              .cardCount = snapshot.data![index].cardCount + 1;
                                                                          dataBaseCard
                                                                              .updateProduct(snapshot.data![index])
                                                                              .then((value) {
                                                                            blocFav.fetchAllFav();
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
                                                                        .data![
                                                                            index]
                                                                        .cardCount = 1;

                                                                    dataBaseCard
                                                                        .saveProducts(snapshot.data![
                                                                            index])
                                                                        .then(
                                                                            (value) {
                                                                      blocFav
                                                                          .fetchAllFav();
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
                                                                        Radius.circular(
                                                                            8),
                                                                      ),
                                                                      color: AppColors
                                                                          .blue,
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        translate(
                                                                            "item.card"),
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              AppColors.fontRubik,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              AppColors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                          Expanded(
                                                            child: Container(),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              if (snapshot
                                                                  .data![index]
                                                                  .favourite) {
                                                                dataBaseFav
                                                                    .deleteProducts(
                                                                        snapshot
                                                                            .data![
                                                                                index]
                                                                            .id)
                                                                    .then(
                                                                        (value) {
                                                                  blocFav
                                                                      .fetchAllFav();
                                                                });
                                                              } else {
                                                                dataBaseFav
                                                                    .saveProducts(
                                                                        snapshot.data![
                                                                            index])
                                                                    .then(
                                                                        (value) {
                                                                  blocFav
                                                                      .fetchAllFav();
                                                                });
                                                              }
                                                            },
                                                            child: snapshot
                                                                    .data![index]
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
                          ),
                  ),
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
    RxBus.register<BottomView>(tag: "FAV_VIEW").listen((event) {
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
