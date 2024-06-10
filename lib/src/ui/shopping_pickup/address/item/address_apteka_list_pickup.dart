import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacy/src/blocs/store_block.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/model/api/location_model.dart';
import 'package:pharmacy/src/model/send/access_store.dart';
import 'package:pharmacy/src/ui/main/home/home_screen.dart';
import 'package:pharmacy/src/ui/main/main_screen.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../static/app_colors.dart';

class AddressStoreListPickupScreen extends StatefulWidget {
  final List<ProductsStore> drugs;

  final Function(LocationModel store) chooseStore;

  AddressStoreListPickupScreen(
    this.drugs,
    this.chooseStore,
  );

  @override
  State<StatefulWidget> createState() {
    return _AddressStoreListPickupScreenState();
  }
}

class _AddressStoreListPickupScreenState
    extends State<AddressStoreListPickupScreen>
    with AutomaticKeepAliveClientMixin<AddressStoreListPickupScreen> {
  @override
  bool get wantKeepAlive => true;

  DatabaseHelper dataBase = new DatabaseHelper();

  @override
  void initState() {
    _requestPermission();
    super.initState();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: StreamBuilder(
        stream: blocStore.allExistStore,
        builder: (context, AsyncSnapshot<List<LocationModel>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.length == 0) {
              return Column(
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
                    translate("address.not_store"),
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
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 16),
                            Image.asset(
                              "assets/img/store_white.png",
                              height: 64,
                              width: 64,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    snapshot.data![index].name,
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
                                    snapshot.data![index].address,
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
                          color: AppColors.white,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(width: 16),
                            Text(
                              translate("card.distance"),
                              style: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                height: 1.3,
                                color: AppColors.textGray,
                              ),
                            ),
                            Expanded(child: Container()),
                            snapshot.data![index].distance == 0.0
                                ? Container()
                                : Text(
                                    ((snapshot.data![index].distance ~/ 100) /
                                                10.0)
                                            .toString() +
                                        translate("km"),
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
                              translate("card.mode"),
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
                              snapshot.data![index].mode,
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
                              translate("card.phone"),
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
                              Utils.numberFormat(snapshot.data![index].phone),
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
                              priceFormat.format(snapshot.data![index].total) +
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
                          color: AppColors.white,
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            widget.chooseStore(snapshot.data![index]);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            margin: EdgeInsets.only(left: 16, right: 16),
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Text(
                                translate("card.choose_store_info"),
                                style: TextStyle(
                                  fontSize: 17,
                                  color: AppColors.white,
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }
          }
          return Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: ListView.builder(
              itemBuilder: (_, __) => Container(
                height: 124,
                margin: EdgeInsets.only(top: 16, left: 12, right: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              itemCount: 10,
            ),
          );
        },
      ),
    );
  }

  Future<void> _requestPermission() async {
    Permission.locationWhenInUse.request().then(
      (value) async {
        if (value.isGranted) {
          _getLocation();
        } else {
          _defaultLocation();
        }
      },
    );
  }

  Future<void> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    lat = position.latitude;
    lng = position.longitude;
    Utils.saveLocation(position.latitude, position.longitude);
    AccessStore addModel = new AccessStore(
        lat: position.latitude,
        lng: position.longitude,
        products: widget.drugs);
    blocStore.fetchAccessStore(addModel);
  }

  Future<void> _defaultLocation() async {
    AccessStore addModel =
        new AccessStore(products: widget.drugs, lng: 0.0, lat: 0.0);
    blocStore.fetchAccessStore(addModel);
  }
}
