import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:pharmacy/src/blocs/home_bloc.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/database/database_helper_fav.dart';
import 'package:pharmacy/src/model/api/blog_model.dart';
import 'package:pharmacy/src/model/api/category_model.dart';
import 'package:pharmacy/src/model/api/check_version.dart';
import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/model/api/sale_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view_model.dart';
import 'package:pharmacy/src/model/review/get_review.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/dialog/bottom_dialog.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../static/app_colors.dart';

final priceFormat = new NumberFormat("#,##0", "ru");
String fcToken = "";

class HomeScreen extends StatefulWidget {
  final Function(String title, String uri) onUnversal;
  final Function(bool optiona, String descl) onUpdate;
  final Function(Function reload) onReloadNetwork;
  final Function(int orderId) onCommentService;
  final Function({
    required String name,
    required int type,
    required String id,
  }) onListItem;
  final Function({
    required String image,
    required String title,
    required String message,
    required DateTime dateTime,
  }) onBlogList;
  final Function() onItemBlog;
  final Function() onRegion;
  final Function() onSearch;

  HomeScreen({
    required this.onUnversal,
    required this.onUpdate,
    required this.onReloadNetwork,
    required this.onCommentService,
    required this.onListItem,
    required this.onBlogList,
    required this.onItemBlog,
    required this.onRegion,
    required this.onSearch,
  });

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DatabaseHelper dataBase = new DatabaseHelper();
  DatabaseHelperFav dataBaseFav = new DatabaseHelperFav();
  var isAnimated = true;
  int lastPosition = 0;
  var duration = Duration(milliseconds: 750);
  ScrollController _sc = new ScrollController();

  @override
  void initState() {
    _sc.addListener(() {
      if (_sc.offset ~/ 10 > 0) {
        blocHome.update();
      }
    });
    _setLanguage();
    _initPackageInfo();
    _registerBus();
    _getNoReview();
    blocHome.fetchBanner();
    blocHome.fetchBlog(1);
    blocHome.fetchRecently();
    blocHome.fetchCategory();
    blocHome.fetchBestItem();
    blocHome.fetchSlimmingItem();
    blocHome.fetchCashBack();
    blocHome.fetchCityName();
    _getCashInfo();
    _getBlog();
    super.initState();
  }

  @override
  void dispose() {
    RxBus.destroy();
    _sc.dispose();
    super.dispose();
  }

  List<BannerResult>? bannerResults;
  List<ItemResult>? recentlyItem;
  List<CategoryResults>? categoryResults;
  List<ItemResult>? getBestItem;
  ItemModel? slimmingItem;
  BlogResults? cashBack;
  List<BlogResults> blog = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          backgroundColor: AppColors.white,
        ),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            height: 124,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    widget.onSearch();
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      top: 8,
                      left: 16,
                      right: 16,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/icons/search.svg"),
                        SizedBox(width: 12),
                        Text(
                          translate("home.search"),
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            height: 1.2,
                            color: AppColors.gray,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.onRegion();
                        },
                        child: Container(
                          color: AppColors.white,
                          child: Row(
                            children: [
                              SizedBox(width: 16),
                              SvgPicture.asset(
                                  "assets/icons/location_grey.svg"),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translate("home.location"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        height: 1.2,
                                        color: AppColors.blue,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        StreamBuilder(
                                          stream: blocHome.allCityName,
                                          builder: (context,
                                              AsyncSnapshot<String> snapshot) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                snapshot.data!,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  height: 1.2,
                                                  color: AppColors.text_dark,
                                                ),
                                              );
                                            }
                                            return Text(
                                              "Ташкент",
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                height: 1.2,
                                                color: AppColors.text_dark,
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 4),
                                        SvgPicture.asset(
                                          "assets/icons/arrow_blue_right.svg",
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              controller: _sc,
              padding: EdgeInsets.only(
                top: 16,
                bottom: 24,
                left: 0,
                right: 0,
              ),
              children: <Widget>[
                Container(
                  height: (MediaQuery.of(context).size.width - 32) / 2.0,
                  width: double.infinity,
                  child: StreamBuilder(
                    stream: blocHome.banner,
                    builder: (context, AsyncSnapshot<BannerModel> snapshot) {
                      if (snapshot.hasData || bannerResults != null) {
                        if (snapshot.hasData) {
                          bannerResults = snapshot.data!.results;
                        }
                        if (bannerResults!.length > 0) {
                          return CarouselSlider(
                            options: CarouselOptions(
                              height: (MediaQuery.of(context).size.width - 32) /
                                  2.0,
                              viewportFraction: 1.0,
                              aspectRatio: 2.0,
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 4),
                              enlargeCenterPage: false,
                            ),
                            items: bannerResults!.map(
                              (url) {
                                return GestureDetector(
                                  onTap: () async {
                                    if (url.drugs.length > 0) {
                                      widget.onListItem(
                                        name: url.name,
                                        type: 5,
                                        id: url.drugs
                                            .toString()
                                            .replaceAll('[', '')
                                            .replaceAll(']', '')
                                            .replaceAll(' ', ''),
                                      );
                                    } else if (url.drug != 0) {
                                      RxBus.post(BottomViewModel(url.drug),
                                          tag: "EVENT_BOTTOM_ITEM_ALL");
                                    } else if (url.category != 0) {
                                      widget.onListItem(
                                        name: url.name,
                                        type: 2,
                                        id: url.category.toString(),
                                      );
                                    } else if (url.url.length > 0) {
                                      if (await canLaunch(url.url)) {
                                        await launch(
                                          url.url,
                                        );
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Container(
                                        color: AppColors.white,
                                        child: CachedNetworkImage(
                                          imageUrl: url.image,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: AppColors.background,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: AppColors.background,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          );
                        } else {
                          return Container();
                        }
                      }
                      return Shimmer.fromColors(
                        baseColor: AppColors.shimmerBase,
                        highlightColor: AppColors.shimmerHighlight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          height:
                              (MediaQuery.of(context).size.width - 32) / 2.0,
                          width: double.infinity,
                          margin: EdgeInsets.only(
                            right: 16,
                            left: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                StreamBuilder(
                  stream: blocHome.recentlyItem,
                  builder: (context, AsyncSnapshot<ItemModel> snapshot) {
                    if (snapshot.hasData || recentlyItem != null) {
                      if (snapshot.hasData) {
                        recentlyItem = snapshot.data!.results;
                      }
                      if (recentlyItem!.length > 0) {
                        return Container(
                          height: 225,
                          margin: EdgeInsets.only(top: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  right: 16,
                                  left: 16,
                                  bottom: 16,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      translate("home.recently"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        height: 1.1,
                                        color: AppColors.text_dark,
                                      ),
                                    ),
                                    Expanded(child: Container()),
                                    GestureDetector(
                                      onTap: () {
                                        widget.onListItem(
                                          name: translate("home.recently"),
                                          type: 1,
                                          id: "HOME",
                                        );
                                      },
                                      child: Container(
                                        color: AppColors.background,
                                        child: Row(
                                          children: [
                                            Text(
                                              translate("home.all"),
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                height: 1.1,
                                                color: AppColors.blue,
                                              ),
                                            ),
                                            SvgPicture.asset(
                                                "assets/icons/arrow_right_blue.svg"),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    right: 0,
                                    left: 16,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 0.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        RxBus.post(
                                          BottomViewModel(
                                            recentlyItem![index].id,
                                          ),
                                          tag: "EVENT_BOTTOM_ITEM_ALL",
                                        );
                                      },
                                      child: Container(
                                        width: 148,
                                        height: 189,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        margin: EdgeInsets.only(
                                          right: 16,
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          recentlyItem![index]
                                                              .imageThumbnail,
                                                      placeholder:
                                                          (context, url) =>
                                                              SvgPicture.asset(
                                                        "assets/icons/default_image.svg",
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          SvgPicture.asset(
                                                        "assets/icons/default_image.svg",
                                                      ),
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        recentlyItem![index]
                                                                .favourite =
                                                            !recentlyItem![
                                                                    index]
                                                                .favourite;
                                                        if (recentlyItem![index]
                                                            .favourite) {
                                                          dataBaseFav
                                                              .saveProducts(
                                                                  recentlyItem![
                                                                      index])
                                                              .then((value) {
                                                            blocHome
                                                                .fetchRecentlyUpdate();
                                                          });
                                                        } else {
                                                          dataBaseFav
                                                              .deleteProducts(
                                                                  recentlyItem![
                                                                          index]
                                                                      .id)
                                                              .then((value) {
                                                            blocHome
                                                                .fetchRecentlyUpdate();
                                                          });
                                                        }
                                                      },
                                                      child: recentlyItem![
                                                                  index]
                                                              .favourite
                                                          ? SvgPicture.asset(
                                                              "assets/icons/fav_select.svg")
                                                          : SvgPicture.asset(
                                                              "assets/icons/fav_unselect.svg"),
                                                    ),
                                                    top: 0,
                                                    right: 0,
                                                  ),
                                                  Positioned(
                                                    child: recentlyItem![index]
                                                                .price >=
                                                            recentlyItem![index]
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
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Text(
                                                              "-" +
                                                                  (((recentlyItem![index].basePrice - recentlyItem![index].price) *
                                                                              100) ~/
                                                                          recentlyItem![index]
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
                                                                    .red,
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
                                              recentlyItem![index].name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                height: 1.5,
                                                color: AppColors.text_dark,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              recentlyItem![index]
                                                  .manufacturer
                                                  .name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 10,
                                                height: 1.2,
                                                color: AppColors.textGray,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            recentlyItem![index].isComing
                                                ? Container(
                                                    height: 29,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Center(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: translate(
                                                                  "fast"),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppColors
                                                                        .fontRubik,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                                height: 1.2,
                                                                color: AppColors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : recentlyItem![index]
                                                            .cardCount >
                                                        0
                                                    ? Container(
                                                        height: 29,
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors.blue
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
                                                              onTap: () {
                                                                if (recentlyItem![
                                                                            index]
                                                                        .cardCount >
                                                                    1) {
                                                                  recentlyItem![
                                                                          index]
                                                                      .cardCount = recentlyItem![
                                                                              index]
                                                                          .cardCount -
                                                                      1;
                                                                  dataBase
                                                                      .updateProduct(
                                                                          recentlyItem![
                                                                              index])
                                                                      .then(
                                                                          (value) {
                                                                    blocHome
                                                                        .fetchRecentlyUpdate();
                                                                  });
                                                                } else if (recentlyItem![
                                                                            index]
                                                                        .cardCount ==
                                                                    1) {
                                                                  dataBase
                                                                      .deleteProducts(
                                                                          recentlyItem![index]
                                                                              .id)
                                                                      .then(
                                                                          (value) {
                                                                    blocHome
                                                                        .fetchRecentlyUpdate();
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 29,
                                                                width: 29,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .blue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    "assets/icons/remove.svg",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Center(
                                                                child: Text(
                                                                  recentlyItem![
                                                                              index]
                                                                          .cardCount
                                                                          .toString() +
                                                                      " " +
                                                                      translate(
                                                                          "sht"),
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppColors
                                                                            .fontRubik,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        12,
                                                                    height: 1.2,
                                                                    color: AppColors
                                                                        .text_dark,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (recentlyItem![
                                                                            index]
                                                                        .cardCount <
                                                                    recentlyItem![
                                                                            index]
                                                                        .maxCount)
                                                                  recentlyItem![
                                                                          index]
                                                                      .cardCount = recentlyItem![
                                                                              index]
                                                                          .cardCount +
                                                                      1;
                                                                dataBase
                                                                    .updateProduct(
                                                                        recentlyItem![
                                                                            index])
                                                                    .then(
                                                                        (value) {
                                                                  blocHome
                                                                      .fetchRecentlyUpdate();
                                                                });
                                                              },
                                                              child: Container(
                                                                height: 29,
                                                                width: 29,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .blue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
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
                                                          recentlyItem![index]
                                                              .cardCount = 1;
                                                          dataBase
                                                              .saveProducts(
                                                                  recentlyItem![
                                                                      index])
                                                              .then((value) {
                                                            blocHome
                                                                .fetchRecentlyUpdate();
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 29,
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                AppColors.blue,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Center(
                                                            child: RichText(
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text: priceFormat
                                                                        .format(
                                                                            recentlyItem![index].price),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          AppColors
                                                                              .fontRubik,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          14,
                                                                      height:
                                                                          1.2,
                                                                      color: AppColors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: translate(
                                                                        "sum"),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          AppColors
                                                                              .fontRubik,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14,
                                                                      height:
                                                                          1.2,
                                                                      color: AppColors
                                                                          .white,
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
                                  itemCount: recentlyItem!.length,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }
                    return Container(
                      height: 225,
                      margin: EdgeInsets.only(top: 24),
                      child: Shimmer.fromColors(
                        baseColor: AppColors.shimmerBase,
                        highlightColor: AppColors.shimmerHighlight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                right: 16,
                                left: 16,
                                bottom: 16,
                              ),
                              height: 19,
                              width: 125,
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  right: 16,
                                  left: 16,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (_, __) => Padding(
                                  padding: const EdgeInsets.only(bottom: 0.0),
                                  child: Container(
                                    width: 148,
                                    height: 189,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: EdgeInsets.only(
                                      right: 16,
                                    ),
                                  ),
                                ),
                                itemCount: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                StreamBuilder(
                  stream: blocHome.categoryItem,
                  builder: (context, AsyncSnapshot<CategoryModel> snapshot) {
                    if (snapshot.hasData || categoryResults != null) {
                      if (snapshot.hasData) {
                        categoryResults = snapshot.data!.results;
                      }
                      if (categoryResults!.length > 0) {
                        return Container(
                          margin: EdgeInsets.only(top: 24, left: 16, right: 16),
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  translate("home.popular_category"),
                                  style: TextStyle(
                                    fontFamily: AppColors.fontRubik,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    height: 1.2,
                                    color: AppColors.text_dark,
                                  ),
                                ),
                                padding: EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                ),
                              ),
                              Container(
                                height: 1,
                                margin: EdgeInsets.only(top: 16, bottom: 16),
                                color: AppColors.background,
                                width: double.infinity,
                              ),
                              ListView.builder(
                                padding: EdgeInsets.only(
                                    top: 0, left: 16, right: 16, bottom: 4),
                                itemCount: categoryResults!.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      widget.onListItem(
                                        name: categoryResults![index].name,
                                        type: 2,
                                        id: categoryResults![index]
                                            .id
                                            .toString(),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      color: AppColors.white,
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            color: AppColors.white,
                                            width: 42,
                                            height: 42,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  categoryResults![index].image,
                                              placeholder: (context, url) =>
                                                  SvgPicture.asset(
                                                "assets/icons/default_image.svg",
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      SvgPicture.asset(
                                                "assets/icons/default_image.svg",
                                              ),
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              categoryResults![index].name,
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16,
                                                height: 1.37,
                                                color: AppColors.text_dark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                              ),
                              GestureDetector(
                                onTap: () {
                                  RxBus.post(BottomViewModel(1),
                                      tag: "EVENT_BOTTOM_VIEW");
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 16, right: 16),
                                  height: 44,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      translate("home.all_category"),
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
                      } else {
                        return Container();
                      }
                    }

                    return Shimmer.fromColors(
                      baseColor: AppColors.shimmerBase,
                      highlightColor: AppColors.shimmerHighlight,
                      child: Container(
                        height: 225,
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 24, left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    );
                  },
                ),
                StreamBuilder(
                  stream: blocHome.getBestItem,
                  builder: (context, AsyncSnapshot<ItemModel> snapshot) {
                    if (snapshot.hasData || getBestItem != null) {
                      if (snapshot.hasData) {
                        getBestItem = snapshot.data!.results;
                      }
                      if (getBestItem!.length > 0) {
                        return Container(
                          height: 225,
                          margin: EdgeInsets.only(top: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  right: 16,
                                  left: 16,
                                  bottom: 16,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      translate("home.best"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        height: 1.1,
                                        color: AppColors.text_dark,
                                      ),
                                    ),
                                    Expanded(child: Container()),
                                    GestureDetector(
                                      onTap: () {
                                        widget.onListItem(
                                          name: translate("home.best"),
                                          type: 3,
                                          id: "BEST",
                                        );
                                      },
                                      child: Container(
                                        color: AppColors.background,
                                        child: Row(
                                          children: [
                                            Text(
                                              translate("home.all"),
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                height: 1.1,
                                                color: AppColors.blue,
                                              ),
                                            ),
                                            SvgPicture.asset(
                                              "assets/icons/arrow_right_blue.svg",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    right: 0,
                                    left: 16,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 0.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        RxBus.post(
                                          BottomViewModel(
                                            getBestItem![index].id,
                                          ),
                                          tag: "EVENT_BOTTOM_ITEM_ALL",
                                        );
                                      },
                                      child: Container(
                                        width: 148,
                                        height: 189,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        margin: EdgeInsets.only(
                                          right: 16,
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          getBestItem![index]
                                                              .imageThumbnail,
                                                      placeholder:
                                                          (context, url) =>
                                                              SvgPicture.asset(
                                                        "assets/icons/default_image.svg",
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          SvgPicture.asset(
                                                        "assets/icons/default_image.svg",
                                                      ),
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        getBestItem![index]
                                                                .favourite =
                                                            !getBestItem![index]
                                                                .favourite;
                                                        if (getBestItem![index]
                                                            .favourite) {
                                                          dataBaseFav
                                                              .saveProducts(
                                                                  getBestItem![
                                                                      index])
                                                              .then((value) {
                                                            blocHome
                                                                .fetchBestUpdate();
                                                          });
                                                        } else {
                                                          dataBaseFav
                                                              .deleteProducts(
                                                                  getBestItem![
                                                                          index]
                                                                      .id)
                                                              .then((value) {
                                                            blocHome
                                                                .fetchBestUpdate();
                                                          });
                                                        }
                                                      },
                                                      child: getBestItem![index]
                                                              .favourite
                                                          ? SvgPicture.asset(
                                                              "assets/icons/fav_select.svg")
                                                          : SvgPicture.asset(
                                                              "assets/icons/fav_unselect.svg"),
                                                    ),
                                                    top: 0,
                                                    right: 0,
                                                  ),
                                                  Positioned(
                                                    child: getBestItem![index]
                                                                .price >=
                                                            getBestItem![index]
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
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Text(
                                                              "-" +
                                                                  (((getBestItem![index].basePrice - getBestItem![index].price) *
                                                                              100) ~/
                                                                          getBestItem![index]
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
                                                                    .red,
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
                                              getBestItem![index].name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                height: 1.5,
                                                color: AppColors.text_dark,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              getBestItem![index]
                                                  .manufacturer
                                                  .name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 10,
                                                height: 1.2,
                                                color: AppColors.textGray,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            getBestItem![index].isComing
                                                ? Container(
                                                    height: 29,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Center(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: translate(
                                                                  "fast"),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppColors
                                                                        .fontRubik,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                                height: 1.2,
                                                                color: AppColors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : getBestItem![index]
                                                            .cardCount >
                                                        0
                                                    ? Container(
                                                        height: 29,
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors.blue
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
                                                              onTap: () {
                                                                if (getBestItem![
                                                                            index]
                                                                        .cardCount >
                                                                    1) {
                                                                  getBestItem![
                                                                          index]
                                                                      .cardCount = getBestItem![
                                                                              index]
                                                                          .cardCount -
                                                                      1;
                                                                  dataBase
                                                                      .updateProduct(
                                                                          getBestItem![
                                                                              index])
                                                                      .then(
                                                                          (value) {
                                                                    blocHome
                                                                        .fetchBestUpdate();
                                                                  });
                                                                } else if (getBestItem![
                                                                            index]
                                                                        .cardCount ==
                                                                    1) {
                                                                  dataBase
                                                                      .deleteProducts(
                                                                          getBestItem![index]
                                                                              .id)
                                                                      .then(
                                                                          (value) {
                                                                    blocHome
                                                                        .fetchBestUpdate();
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 29,
                                                                width: 29,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .blue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    "assets/icons/remove.svg",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Center(
                                                                child: Text(
                                                                  getBestItem![
                                                                              index]
                                                                          .cardCount
                                                                          .toString() +
                                                                      " " +
                                                                      translate(
                                                                          "sht"),
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppColors
                                                                            .fontRubik,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        12,
                                                                    height: 1.2,
                                                                    color: AppColors
                                                                        .text_dark,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (getBestItem![
                                                                            index]
                                                                        .cardCount <
                                                                    getBestItem![
                                                                            index]
                                                                        .maxCount)
                                                                  getBestItem![
                                                                          index]
                                                                      .cardCount = getBestItem![
                                                                              index]
                                                                          .cardCount +
                                                                      1;
                                                                dataBase
                                                                    .updateProduct(
                                                                        getBestItem![
                                                                            index])
                                                                    .then(
                                                                        (value) {
                                                                  blocHome
                                                                      .fetchBestUpdate();
                                                                });
                                                              },
                                                              child: Container(
                                                                height: 29,
                                                                width: 29,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .blue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
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
                                                          getBestItem![index]
                                                              .cardCount = 1;
                                                          dataBase
                                                              .saveProducts(
                                                                  getBestItem![
                                                                      index])
                                                              .then((value) {
                                                            blocHome
                                                                .fetchBestUpdate();
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 29,
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                AppColors.blue,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Center(
                                                            child: RichText(
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text: priceFormat
                                                                        .format(
                                                                            getBestItem![index].price),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          AppColors
                                                                              .fontRubik,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          14,
                                                                      height:
                                                                          1.2,
                                                                      color: AppColors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: translate(
                                                                        "sum"),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          AppColors
                                                                              .fontRubik,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14,
                                                                      height:
                                                                          1.2,
                                                                      color: AppColors
                                                                          .white,
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
                                  itemCount: getBestItem!.length,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }
                    return Container(
                      height: 225,
                      margin: EdgeInsets.only(top: 24),
                      child: Shimmer.fromColors(
                        baseColor: AppColors.shimmerBase,
                        highlightColor: AppColors.shimmerHighlight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                right: 16,
                                left: 16,
                                bottom: 16,
                              ),
                              height: 19,
                              width: 125,
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  right: 16,
                                  left: 16,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (_, __) => Padding(
                                  padding: const EdgeInsets.only(bottom: 0.0),
                                  child: Container(
                                    width: 148,
                                    height: 189,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: EdgeInsets.only(
                                      right: 16,
                                    ),
                                  ),
                                ),
                                itemCount: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                StreamBuilder(
                  stream: blocHome.slimmingItem,
                  builder: (context, AsyncSnapshot<ItemModel> snapshot) {
                    if (snapshot.hasData || slimmingItem != null) {
                      if (snapshot.hasData) {
                        slimmingItem = snapshot.data;
                      }
                      if (slimmingItem!.drugs.length > 0) {
                        return Container(
                          height: 225,
                          margin: EdgeInsets.only(top: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  right: 16,
                                  left: 16,
                                  bottom: 16,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      slimmingItem!.title,
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        height: 1.1,
                                        color: AppColors.text_dark,
                                      ),
                                    ),
                                    Expanded(child: Container()),
                                    GestureDetector(
                                      onTap: () {
                                        widget.onListItem(
                                            name: slimmingItem!.title,
                                            type: 4,
                                            id: "SLIM");
                                      },
                                      child: Container(
                                        color: AppColors.background,
                                        child: Row(
                                          children: [
                                            Text(
                                              translate("home.all"),
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                height: 1.1,
                                                color: AppColors.blue,
                                              ),
                                            ),
                                            SvgPicture.asset(
                                                "assets/icons/arrow_right_blue.svg"),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    right: 0,
                                    left: 16,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 0.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        RxBus.post(
                                          BottomViewModel(
                                            slimmingItem!.drugs[index].id,
                                          ),
                                          tag: "EVENT_BOTTOM_ITEM_ALL",
                                        );
                                      },
                                      child: Container(
                                        width: 148,
                                        height: 189,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        margin: EdgeInsets.only(
                                          right: 16,
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: CachedNetworkImage(
                                                      imageUrl: slimmingItem!
                                                          .drugs[index]
                                                          .imageThumbnail,
                                                      placeholder:
                                                          (context, url) =>
                                                              SvgPicture.asset(
                                                        "assets/icons/default_image.svg",
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          SvgPicture.asset(
                                                        "assets/icons/default_image.svg",
                                                      ),
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        slimmingItem!
                                                                .drugs[index]
                                                                .favourite =
                                                            !slimmingItem!
                                                                .drugs[index]
                                                                .favourite;
                                                        if (slimmingItem!
                                                            .drugs[index]
                                                            .favourite) {
                                                          dataBaseFav
                                                              .saveProducts(
                                                                  slimmingItem!
                                                                          .drugs[
                                                                      index])
                                                              .then((value) {
                                                            blocHome
                                                                .fetchSlimmingUpdate();
                                                          });
                                                        } else {
                                                          dataBaseFav
                                                              .deleteProducts(
                                                                  slimmingItem!
                                                                      .drugs[
                                                                          index]
                                                                      .id)
                                                              .then((value) {
                                                            blocHome
                                                                .fetchSlimmingUpdate();
                                                          });
                                                        }
                                                      },
                                                      child: slimmingItem!
                                                              .drugs[index]
                                                              .favourite
                                                          ? SvgPicture.asset(
                                                              "assets/icons/fav_select.svg")
                                                          : SvgPicture.asset(
                                                              "assets/icons/fav_unselect.svg"),
                                                    ),
                                                    top: 0,
                                                    right: 0,
                                                  ),
                                                  Positioned(
                                                    child: slimmingItem!
                                                                .drugs[index]
                                                                .price >=
                                                            slimmingItem!
                                                                .drugs[index]
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
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Text(
                                                              "-" +
                                                                  (((slimmingItem!.drugs[index].basePrice - slimmingItem!.drugs[index].price) *
                                                                              100) ~/
                                                                          slimmingItem!
                                                                              .drugs[index]
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
                                                                    .red,
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
                                              slimmingItem!.drugs[index].name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                height: 1.5,
                                                color: AppColors.text_dark,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              slimmingItem!.drugs[index]
                                                  .manufacturer.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 10,
                                                height: 1.2,
                                                color: AppColors.textGray,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            slimmingItem!.drugs[index].isComing
                                                ? Container(
                                                    height: 29,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Center(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: translate(
                                                                  "fast"),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppColors
                                                                        .fontRubik,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                                height: 1.2,
                                                                color: AppColors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : slimmingItem!.drugs[index]
                                                            .cardCount >
                                                        0
                                                    ? Container(
                                                        height: 29,
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors.blue
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
                                                              onTap: () {
                                                                if (slimmingItem!
                                                                        .drugs[
                                                                            index]
                                                                        .cardCount >
                                                                    1) {
                                                                  slimmingItem!
                                                                      .drugs[
                                                                          index]
                                                                      .cardCount = slimmingItem!
                                                                          .drugs[
                                                                              index]
                                                                          .cardCount -
                                                                      1;
                                                                  dataBase
                                                                      .updateProduct(
                                                                          slimmingItem!.drugs[
                                                                              index])
                                                                      .then(
                                                                          (value) {
                                                                    blocHome
                                                                        .fetchSlimmingUpdate();
                                                                  });
                                                                } else if (slimmingItem!
                                                                        .drugs[
                                                                            index]
                                                                        .cardCount ==
                                                                    1) {
                                                                  dataBase
                                                                      .deleteProducts(slimmingItem!
                                                                          .drugs[
                                                                              index]
                                                                          .id)
                                                                      .then(
                                                                          (value) {
                                                                    blocHome
                                                                        .fetchSlimmingUpdate();
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                height: 29,
                                                                width: 29,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .blue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    "assets/icons/remove.svg",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Center(
                                                                child: Text(
                                                                  slimmingItem!
                                                                          .drugs[
                                                                              index]
                                                                          .cardCount
                                                                          .toString() +
                                                                      " " +
                                                                      translate(
                                                                          "sht"),
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppColors
                                                                            .fontRubik,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        12,
                                                                    height: 1.2,
                                                                    color: AppColors
                                                                        .text_dark,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (slimmingItem!
                                                                        .drugs[
                                                                            index]
                                                                        .cardCount <
                                                                    slimmingItem!
                                                                        .drugs[
                                                                            index]
                                                                        .maxCount)
                                                                  slimmingItem!
                                                                      .drugs[
                                                                          index]
                                                                      .cardCount = slimmingItem!
                                                                          .drugs[
                                                                              index]
                                                                          .cardCount +
                                                                      1;
                                                                dataBase
                                                                    .updateProduct(
                                                                        slimmingItem!.drugs[
                                                                            index])
                                                                    .then(
                                                                        (value) {
                                                                  blocHome
                                                                      .fetchSlimmingUpdate();
                                                                });
                                                              },
                                                              child: Container(
                                                                height: 29,
                                                                width: 29,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .blue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
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
                                                          slimmingItem!
                                                              .drugs[index]
                                                              .cardCount = 1;
                                                          dataBase
                                                              .saveProducts(
                                                                  slimmingItem!
                                                                          .drugs[
                                                                      index])
                                                              .then((value) {
                                                            blocHome
                                                                .fetchSlimmingUpdate();
                                                          });
                                                        },
                                                        child: Container(
                                                          height: 29,
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                AppColors.blue,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Center(
                                                            child: RichText(
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text: priceFormat.format(slimmingItem!
                                                                        .drugs[
                                                                            index]
                                                                        .price),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          AppColors
                                                                              .fontRubik,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          14,
                                                                      height:
                                                                          1.2,
                                                                      color: AppColors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: translate(
                                                                        "sum"),
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          AppColors
                                                                              .fontRubik,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          14,
                                                                      height:
                                                                          1.2,
                                                                      color: AppColors
                                                                          .white,
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
                                  itemCount: slimmingItem!.drugs.length,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }
                    return Container(
                      height: 225,
                      margin: EdgeInsets.only(top: 24),
                      child: Shimmer.fromColors(
                        baseColor: AppColors.shimmerBase,
                        highlightColor: AppColors.shimmerHighlight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                right: 16,
                                left: 16,
                                bottom: 16,
                              ),
                              height: 19,
                              width: 125,
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  right: 16,
                                  left: 16,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (_, __) => Padding(
                                  padding: const EdgeInsets.only(bottom: 0.0),
                                  child: Container(
                                    width: 148,
                                    height: 189,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: EdgeInsets.only(
                                      right: 16,
                                    ),
                                  ),
                                ),
                                itemCount: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                cashBack == null
                    ? Container()
                    : Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(
                          top: 24,
                          left: 16,
                          right: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              child: CachedNetworkImage(
                                imageUrl: cashBack!.image,
                                placeholder: (context, url) => Image.asset(
                                  "assets/img/default.png",
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "assets/img/default.png",
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            SizedBox(height: 16),
                            Text(
                              cashBack!.title,
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                height: 1.2,
                                color: AppColors.text_dark,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              cashBack!.body
                                  .replaceAll("<p>", " ")
                                  .replaceAll("</p>", ""),
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                height: 1.6,
                                color: AppColors.textGray,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                widget.onBlogList(
                                  image: cashBack!.image,
                                  dateTime: cashBack!.updatedAt,
                                  title: cashBack!.title,
                                  message: cashBack!.body,
                                );
                              },
                              child: Container(
                                child: Center(
                                  child: Text(
                                    translate("home.bonus_all"),
                                    style: TextStyle(
                                      fontFamily: AppColors.fontRubik,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      height: 1.25,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                height: 44,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                blog.length > 0
                    ? Container(
                        height: 282,
                        margin: EdgeInsets.only(top: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                right: 16,
                                left: 16,
                                bottom: 16,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    translate("home.articles"),
                                    style: TextStyle(
                                      fontFamily: AppColors.fontRubik,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      height: 1.1,
                                      color: AppColors.text_dark,
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  GestureDetector(
                                    child: Container(
                                      color: AppColors.background,
                                      child: Row(
                                        children: [
                                          Text(
                                            translate("home.all"),
                                            style: TextStyle(
                                              fontFamily: AppColors.fontRubik,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              height: 1.1,
                                              color: AppColors.blue,
                                            ),
                                          ),
                                          SvgPicture.asset(
                                              "assets/icons/arrow_right_blue.svg")
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      widget.onItemBlog();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,
                                  right: 0,
                                  left: 16,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 0.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.onBlogList(
                                        image: blog[index].image,
                                        dateTime: blog[index].updatedAt,
                                        title: blog[index].title,
                                        message: blog[index].body,
                                      );
                                    },
                                    child: Container(
                                      width: 253,
                                      height: 246,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      margin: EdgeInsets.only(
                                        right: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              child: CachedNetworkImage(
                                                imageUrl: blog[index].image,
                                                placeholder: (context, url) =>
                                                    Image.asset(
                                                  "assets/img/default.png",
                                                  width: 253,
                                                  fit: BoxFit.cover,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Image.asset(
                                                  "assets/img/default.png",
                                                  width: 253,
                                                  fit: BoxFit.cover,
                                                ),
                                                width: 253,
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              Utils.dateFormat(
                                                  blog[index].updatedAt),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                                height: 1.2,
                                                color: AppColors.textGray,
                                              ),
                                            ),
                                            margin: EdgeInsets.only(
                                              bottom: 8,
                                              top: 8,
                                              left: 16,
                                              right: 16,
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              blog[index].title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: AppColors.fontRubik,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                height: 1.6,
                                                color: AppColors.text_dark,
                                              ),
                                            ),
                                            margin: EdgeInsets.only(
                                              bottom: 16,
                                              left: 16,
                                              right: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                itemCount: blog.length,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                GestureDetector(
                  onTap: () async {
                    var url = "tel:712050888";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(
                        top: 24, left: 16, right: 16, bottom: 24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.blue.withOpacity(0.2),
                          ),
                          child: Center(
                            child: SvgPicture.asset("assets/icons/phone.svg"),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate("home.call_center"),
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                height: 1.2,
                                color: AppColors.textGray,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "+998 (71) 205-0-888",
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                height: 1.1,
                                color: AppColors.text_dark,
                              ),
                            ),
                          ],
                        )),
                        SizedBox(width: 16),
                        SvgPicture.asset("assets/icons/arrow_right_grey.svg")
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

  Future<void> _setLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language') != null) {
      setState(() {
        var localizationDelegate = LocalizedApp.of(context).delegate;
        localizationDelegate.changeLocale(
          Locale(prefs.getString('language') ?? "ru"),
        );
      });
    } else {
      setState(() {
        var localizationDelegate = LocalizedApp.of(context).delegate;
        localizationDelegate.changeLocale(Locale('ru'));
      });
    }
  }

  Future<void> _getCashInfo() async {
    var response = await blocHome.cashBack.first;
    if (response.results.length > 0) {
      setState(() {
        cashBack = response.results[0];
      });
    }
  }

  Future<void> _getBlog() async {
    var responseBlog = await blocHome.blog.first;
    if (responseBlog.results.length > 0) {
      setState(() {
        blog = responseBlog.results;
      });
    }
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    Repository().fetchCheckVersion(info.buildNumber).then(
      (v) {
        if (v.isSuccess) {
          var value = CheckVersion.fromJson(v.result);
          if (value.status != 0) {
            widget.onUpdate(false, value.description);
          } else if (value.winner) {
            BottomDialog.showWinner(context, value.konkursText);
          }
          if (value.requestForm) {
            widget.onUnversal(value.requestTitle, value.requestUrl);
          }
        }
      },
    );
  }

  Future<void> _getNoReview() async {
    var login = await Utils.isLogin();
    if (login) {
      var response = await Repository().fetchGetNoReview();
      if (response.isSuccess) {
        var result = GetReviewModel.fromJson(response.result);
        if (result.data.length > 0) {
          widget.onCommentService(result.data[0]);
        }
      }
    }
  }

  void _registerBus() {
    RxBus.register<BottomView>(tag: "HOME_VIEW").listen((event) {
      if (event.title) {
        _sc.animateTo(
          _sc.position.minScrollExtent,
          duration: const Duration(milliseconds: 270),
          curve: Curves.easeInOut,
        );
      }
    });

    RxBus.register<BottomView>(tag: "HOME_VIEW_ERROR_NETWORK").listen(
      (event) {
        widget.onReloadNetwork(
          () {
            blocHome.fetchBanner();
            blocHome.fetchBlog(1);
            blocHome.fetchRecently();
            blocHome.fetchCategory();
            blocHome.fetchBestItem();
            blocHome.fetchSlimmingItem();
            blocHome.fetchCashBack();
          },
        );
      },
    );
  }
}
