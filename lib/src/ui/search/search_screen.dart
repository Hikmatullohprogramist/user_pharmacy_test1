import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/blocs/search_bloc.dart';
import 'package:pharmacy/src/database/database_helper_history.dart';
import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view_model.dart';
import 'package:pharmacy/src/ui/dialog/bottom_dialog.dart';
import 'package:pharmacy/src/ui/item_list/item_list_screen.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';

import 'package:shimmer/shimmer.dart';

import '../../static/app_colors.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  bool isSearchText = false;
  String obj = "";
  String cancelText = "";
  int page = 1;
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  var durationTime = Duration(
    milliseconds: 270,
  );
  var width = 0.0;
  var height = 8.0;

  DatabaseHelperHistory dataHistory = new DatabaseHelperHistory();

  Timer? _timer;

  @override
  void initState() {
    _registerBus();
    Timer(Duration(milliseconds: 1), () {
      setState(() {
        width = translate("search.close").length * 10.0 + 16.0;
        height = 0.0;
      });
    });
    Timer(durationTime, () {
      setState(() {
        cancelText = translate("search.close");
      });
    });
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page);
      }
    });
    const oneSec = const Duration(milliseconds: 500);
    searchController.addListener(() {
      if (searchController.text.length > 2) {
        if (_timer == null) {
          _timer = new Timer(oneSec, () {
            obj = searchController.text;
            if (obj.length > 2) {
              setState(() {
                _timer!.cancel();
                page = 1;
                isLoading = false;
                isSearchText = true;
                this._getMoreData(1);
              });
            } else {
              setState(() {
                page = 1;
                obj = "";
                isSearchText = false;
              });
            }
          });
        } else {
          _timer!.cancel();
          _timer = new Timer(oneSec, () {
            obj = searchController.text;
            if (obj.length > 2) {
              setState(() {
                _timer!.cancel();
                page = 1;
                isSearchText = true;
                isLoading = false;
                this._getMoreData(1);
              });
            } else {
              setState(() {
                page = 1;
                obj = "";
                isSearchText = false;
              });
            }
          });
        }
      } else {
        setState(() {
          page = 1;
          obj = "";
          isSearchText = false;
        });
      }
    });
    super.initState();
  }


  @override
  void dispose() {
    _sc.dispose();
    RxBus.destroy();
    if (_timer != null) _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        setState(() {
          width = 0.0;
          height = 8.0;
        });
        Timer(durationTime, () {
          Navigator.pop(context);
        });
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0.0,
            backgroundColor: AppColors.white,

          ),
        ),
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            AnimatedContainer(
              height: height,
              duration: durationTime,
              curve: Curves.easeInOut,
              color: AppColors.white,
            ),
            Theme(
              data: ThemeData(
                platform: Platform.isAndroid
                    ? TargetPlatform.android
                    : TargetPlatform.iOS,
              ),
              child: Container(
                height: 44,
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                color: AppColors.white,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.background,
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 16),
                            SvgPicture.asset("assets/icons/search.svg"),
                            SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 44,
                                child: TextFormField(
                                  textInputAction: TextInputAction.search,
                                  autofocus: true,
                                  onFieldSubmitted: (value) {
                                    if (searchController.text.length > 0) {
                                      var data = dataHistory
                                          .getProducts(searchController.text);
                                      data.then(
                                        (value) => {
                                          if (value == 0)
                                            {
                                              dataHistory.saveProducts(
                                                  searchController.text),
                                            }
                                          else
                                            {
                                              dataHistory.updateProduct(
                                                  searchController.text),
                                            },
                                        },
                                      );
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ItemListScreen(
                                          name: translate("search.result"),
                                          type: 6,
                                          id: obj,
                                        ),
                                      ),
                                    );
                                  },
                                  cursorColor: AppColors.gray,
                                  style: TextStyle(
                                    fontFamily: AppColors.fontRubik,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 16,
                                    height: 1.2,
                                    color: AppColors.text_dark,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: translate("search.hint"),
                                    hintStyle: TextStyle(
                                      fontFamily: AppColors.fontRubik,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                      height: 1.2,
                                      color: AppColors.gray,
                                    ),
                                  ),
                                  controller: searchController,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      width: width,
                      duration: durationTime,
                      curve: Curves.easeInOut,
                      color: AppColors.white,
                      child: GestureDetector(
                        onTap: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          setState(() {
                            cancelText = "";
                            width = 0.0;
                            height = 8.0;
                          });
                          Timer(durationTime, () {
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 12),
                          child: Text(
                            cancelText,
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              height: 1.2,
                              color: AppColors.textGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: isSearchText
                  ? StreamBuilder(
                      stream: blocSearch.searchOptions,
                      builder: (context, AsyncSnapshot<ItemModel> snapshot) {
                        if (snapshot.hasData) {
                          snapshot.data!.next == ""
                              ? isLoading = true
                              : isLoading = false;
                          return snapshot.data!.results.length > 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 24,
                                        left: 16,
                                        right: 16,
                                        bottom: 21,
                                      ),
                                      child: Text(
                                        translate("search.result"),
                                        style: TextStyle(
                                          fontFamily: AppColors.fontRubik,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          height: 1.2,
                                          color: AppColors.text_dark,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        padding: EdgeInsets.only(
                                          top: 0,
                                          bottom: 24,
                                          left: 16,
                                          right: 16,
                                        ),
                                        itemCount:
                                            snapshot.data!.results.length + 1,
                                        controller: _sc,
                                        itemBuilder: (context, index) {
                                          if (index ==
                                              snapshot.data!.results.length) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: new Center(
                                                child: new Opacity(
                                                  opacity:
                                                      isLoading ? 0.0 : 1.0,
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
                                                    BottomViewModel(snapshot
                                                        .data!
                                                        .results[index]
                                                        .id),
                                                    tag:
                                                        "EVENT_BOTTOM_ITEM_ALL");
                                              },
                                              child: Container(
                                                color: AppColors.white,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 1,
                                                      width: double.infinity,
                                                      color:
                                                          AppColors.background,
                                                    ),
                                                    SizedBox(height: 16),
                                                    Row(
                                                      children: [
                                                        CachedNetworkImage(
                                                          imageUrl: snapshot
                                                              .data!
                                                              .results[index]
                                                              .imageThumbnail,
                                                          placeholder: (context,
                                                                  url) =>
                                                              SvgPicture.asset(
                                                            "assets/icons/default_image.svg",
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              SvgPicture.asset(
                                                            "assets/icons/default_image.svg",
                                                          ),
                                                          fit: BoxFit.fitHeight,
                                                          height: 48,
                                                          width: 48,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                snapshot
                                                                    .data!
                                                                    .results[
                                                                        index]
                                                                    .manufacturer
                                                                    .name,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppColors
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
                                                              Text(
                                                                snapshot
                                                                    .data!
                                                                    .results[
                                                                        index]
                                                                    .name,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppColors
                                                                          .fontRubik,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 12,
                                                                  height: 1.5,
                                                                  color: AppColors
                                                                      .text_dark,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 16),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 80,
                                        margin: EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          color: AppColors.yellow,
                                          borderRadius:
                                              BorderRadius.circular(16),
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
                                        translate("search.empty_title"),
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
                                        translate("search.empty_message"),
                                        textAlign: TextAlign.center,
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
                                );
                        }
                        return Shimmer.fromColors(
                          baseColor: AppColors.shimmerBase,
                          highlightColor: AppColors.shimmerHighlight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 19,
                                width: 150,
                                margin: EdgeInsets.only(
                                    top: 24, left: 16, right: 16, bottom: 21),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    right: 16,
                                    left: 16,
                                  ),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: 10,
                                  itemBuilder: (_, __) => Container(
                                    padding:
                                        EdgeInsets.only(top: 16, bottom: 16),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 48,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              height: 16,
                                              margin: EdgeInsets.only(left: 8),
                                              width: 125,
                                              decoration: BoxDecoration(
                                                color: AppColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                top: 4,
                                                left: 8,
                                              ),
                                              height: 19,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: AppColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    )
                  : FutureBuilder<List<String>>(
                      future: dataHistory.getProdu(),
                      builder: (context, snapshots) {
                        if (snapshots.data == null) {
                          return Container();
                        }
                        return snapshots.data!.length > 0
                            ? Column(
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          translate("search.history"),
                                          style: TextStyle(
                                            fontFamily: AppColors.fontRubik,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            height: 1.2,
                                            color: AppColors.text_dark,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(),
                                        ),
                                        GestureDetector(
                                          child: SvgPicture.asset(
                                            "assets/icons/close.svg",
                                          ),
                                          onTap: () {
                                            BottomDialog.showClearHistory(
                                                context, () {
                                              setState(() {
                                                dataHistory.clear();
                                              });
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                    margin: EdgeInsets.only(
                                      left: 16,
                                      right: 18,
                                      top: 24,
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: snapshots.data!.length,
                                      padding:
                                          EdgeInsets.only(top: 18, bottom: 18),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              searchController.text =
                                                  snapshots.data![index];
                                              searchController.selection =
                                                  TextSelection.fromPosition(
                                                TextPosition(
                                                  offset: searchController
                                                      .text.length,
                                                ),
                                              );
                                            });
                                          },
                                          child: Container(
                                            color: AppColors.white,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    left: 16,
                                                    right: 16,
                                                  ),
                                                  height: 1,
                                                  color: AppColors.background,
                                                ),
                                                SizedBox(height: 17),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    SizedBox(width: 16),
                                                    SvgPicture.asset(
                                                      "assets/icons/time.svg",
                                                      color: AppColors.gray,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        snapshots.data![index],
                                                        style: TextStyle(
                                                          fontFamily: AppColors
                                                              .fontRubik,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontSize: 14,
                                                          height: 1.2,
                                                          color:
                                                              AppColors.textGray,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    SvgPicture.asset(
                                                      "assets/icons/arrow_right_grey.svg",
                                                      color: AppColors.gray,
                                                    ),
                                                    SizedBox(width: 16),
                                                  ],
                                                ),
                                                SizedBox(height: 17),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEFF0FF),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        "assets/img/search.png",
                                        width: 32,
                                        height: 32,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      translate("search.full_title"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        height: 1.2,
                                        color: AppColors.text_dark,
                                      ),
                                    ),
                                    margin: EdgeInsets.only(
                                      top: 16,
                                      left: 32,
                                      right: 32,
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      translate("search.full_msg"),
                                      style: TextStyle(
                                        fontFamily: AppColors.fontRubik,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        height: 1.6,
                                        color: AppColors.textGray,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    margin: EdgeInsets.only(
                                      top: 8,
                                      left: 32,
                                      right: 32,
                                    ),
                                  )
                                ],
                              );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  void _registerBus() {
    RxBus.register<BottomView>(tag: "SEARCH_VIEW_ERROR_NETWORK").listen(
      (event) {
        BottomDialog.showNetworkError(context, () {
          page = 1;
          isLoading = false;
          _getMoreData(1);
        });
      },
    );
  }

  void _getMoreData(int index) async {
    if (obj.length > 2) {
      if (!isLoading) {
        blocSearch.fetchSearch(index, obj);
        page++;
      }
    }
  }
}
