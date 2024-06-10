import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacy/src/blocs/region_bloc.dart';
import 'package:pharmacy/src/model/api/order_status_model.dart';
import 'package:pharmacy/src/model/api/region_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/main/main_screen.dart';
import 'package:pharmacy/src/widget/accardion/accordion.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shimmer/shimmer.dart';

import '../static/app_colors.dart';

class LoginRegionScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginRegionScreenState();
  }
}

class _LoginRegionScreenState extends State<LoginRegionScreen> {
  RegionModel data = RegionModel(id: -1);
  var duration = Duration(milliseconds: 270);

  @override
  void initState() {
    _requestPermission();
    super.initState();
  }

  Future<void> _requestPermission() async {
    Permission.locationWhenInUse.request().then(
      (value) async {
        if (value.isGranted) {
          _getPosition();
        } else {
          blocRegion.fetchAllRegion();
        }
      },
    );
  }

  Future<void> _getPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    lat = position.latitude;
    lng = position.longitude;
    var response = await Repository().fetchGetRegion("$lng,$lat");
    if (response.isSuccess) {
      var result = OrderStatusModel.fromJson(response.result);
      if (result.status == 1) {
        Utils.saveRegion(result.region, result.msg, lat, lng);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      } else {
        blocRegion.fetchAllRegion();
      }
    } else {
      blocRegion.fetchAllRegion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppColors.white,
        title: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          child: Text(
            "Выбор региона",
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
                          "Ваше местоположение",
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
                                      data = RegionModel(
                                        id: snapshot.data![index].id,
                                        name: snapshot.data![index].name,
                                        coords: [
                                          snapshot.data![index].coords[0],
                                          snapshot.data![index].coords[1]
                                        ],
                                      );
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
                                              color: data.id ==
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
                                              color: data.id ==
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
                                  data: data.id,
                                  onChoose: (choose) {
                                    setState(
                                      () {
                                        data = RegionModel(
                                          id: choose.id,
                                          name: choose.name,
                                          coords: [
                                            choose.coords[0],
                                            choose.coords[1]
                                          ],
                                        );
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
              onTap: () {
                if (data.id != -1) {
                  Utils.saveRegion(
                    data.id,
                    data.name,
                    data.coords[0],
                    data.coords[1],
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ),
                  );
                }
              },
              child: Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: data.id == -1 ? AppColors.gray : AppColors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Продолжить",
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
}
