import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pharmacy/src/blocs/home_bloc.dart';
import 'package:pharmacy/src/blocs/region_bloc.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/database/database_helper_fav.dart';
import 'package:pharmacy/src/model/api/region_model.dart';
import 'package:pharmacy/src/widget/accardion/accordion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../static/app_colors.dart';

class RegionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegionScreenState();
  }
}

class _RegionScreenState extends State<RegionScreen> {
  int regionId = -1;
  String regionName = "";
  var duration = Duration(milliseconds: 270);
  DatabaseHelper dataBaseCard = new DatabaseHelper();
  DatabaseHelperFav dataBaseFav = new DatabaseHelperFav();

  @override
  void initState() {
    blocRegion.fetchAllRegion();
    _getRegion();
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
              translate("region.name"),
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
            child: StreamBuilder(
              stream: blocRegion.allRegion,
              builder: (context, AsyncSnapshot<List<RegionModel>> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 1,
                          top: 16,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(24),
                            topLeft: Radius.circular(24),
                          ),
                        ),
                        child: Text(
                          translate("region.title"),
                          textAlign: TextAlign.start,
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
                        itemCount: snapshot.data!.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return snapshot.data![index].childs.length == 0
                              ? GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      regionId = snapshot.data![index].id;
                                      regionName = snapshot.data![index].name;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(
                                          index == snapshot.data!.length - 1
                                              ? 24
                                              : 0,
                                        ),
                                        bottomRight: Radius.circular(
                                          index == snapshot.data!.length - 1
                                              ? 24
                                              : 0,
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                    ),
                                    padding: EdgeInsets.only(
                                      top: 16,
                                      bottom: index == snapshot.data!.length - 1
                                          ? 28
                                          : 16,
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            snapshot.data![index].name,
                                            style: TextStyle(
                                              fontFamily: AppColors.fontRubik,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              height: 1.2,
                                              color: AppColors.text_dark,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        AnimatedContainer(
                                          duration: duration,
                                          curve: Curves.easeInOut,
                                          height: 16,
                                          width: 16,
                                          padding: EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: regionId ==
                                                      snapshot.data![index].id
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
                                              color: regionId ==
                                                      snapshot.data![index].id
                                                  ? AppColors.blue
                                                  : AppColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Accordion(
                                  position: snapshot.data!.length - 1 == index
                                      ? true
                                      : false,
                                  title: snapshot.data![index].name,
                                  childs: snapshot.data![index].childs,
                                  data: regionId,
                                  onChoose: (choose) {
                                    setState(
                                      () {
                                        regionId = choose.id;
                                        regionName = choose.name;
                                      },
                                    );
                                  },
                                );
                        },
                      )),
                    ],
                  );
                }
                return Shimmer.fromColors(
                  child: Container(
                    height: 343,
                    width: double.infinity,
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  baseColor: AppColors.shimmerBase,
                  highlightColor: AppColors.shimmerHighlight,
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 12, left: 22, right: 22, bottom: 24),
            color: AppColors.white,
            child: GestureDetector(
              onTap: () async {
                if (regionId != -1) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setInt('cityId', regionId);
                  prefs.setString('city', regionName);
                  dataBaseFav.clear();
                  dataBaseCard.clear();
                  blocHome.fetchCityName();
                  Navigator.pop(context);
                  blocHome.fetchBanner();
                  blocHome.fetchRecently();
                  blocHome.fetchCategory();
                  blocHome.fetchBestItem();
                  blocHome.fetchSlimmingItem();
                }
              },
              child: Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: regionId == -1 ? AppColors.gray : AppColors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    translate("region.save"),
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
          )
        ],
      ),
    );
  }

  Future<void> _getRegion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      regionId = prefs.getInt('cityId') ?? -1;
      regionName = prefs.getString('city') ?? "";
    });
  }
}
