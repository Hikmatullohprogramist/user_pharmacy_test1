import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacy/src/static/app_colors.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class ShowMapAddress extends StatefulWidget {
  final double lat;
  final double lng;
  final Function(Point point) onChooseLocation;

  const ShowMapAddress({
    Key? key,
    required this.lat,
    required this.lng,
    required this.onChooseLocation,
  }) : super(key: key);

  @override
  State<ShowMapAddress> createState() => _ShowMapAddressState();
}

class _ShowMapAddressState extends State<ShowMapAddress> {
  MapAnimation animation = const MapAnimation(duration: 0.5);
  late YandexMapController controller;
  late final List<MapObject> mapObjects;
  final MapObjectId cameraMapObjectId = MapObjectId('camera_placemark');

  @override
  void initState() {
    mapObjects = [
      PlacemarkMapObject(
        mapId: cameraMapObjectId,
        point: Point(
          latitude: widget.lat,
          longitude: widget.lng,
        ),
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/map/location.png'),
          ),
        ),
        opacity: 1,
      )
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
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
              translate("address.choose_address"),
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
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: YandexMap(
                    onUserLocationAdded: (UserLocationView view) async {
                      return view.copyWith(
                        pin: view.pin.copyWith(
                          icon: PlacemarkIcon.single(
                            PlacemarkIconStyle(
                              image: BitmapDescriptor.fromAssetImage(
                                'assets/map/user.png',
                              ),
                            ),
                          ),
                        ),
                        arrow: view.arrow.copyWith(
                          icon: PlacemarkIcon.single(
                            PlacemarkIconStyle(
                              image: BitmapDescriptor.fromAssetImage(
                                'assets/map/arrow.png',
                              ),
                            ),
                          ),
                        ),
                        accuracyCircle: view.accuracyCircle.copyWith(
                          fillColor: Colors.green.withOpacity(0.5),
                        ),
                      );
                    },
                    mapObjects: mapObjects,
                    onCameraPositionChanged: (CameraPosition cameraPosition,
                        CameraUpdateReason _, bool __) async {
                      final placemarkMapObject = mapObjects
                              .firstWhere((el) => el.mapId == cameraMapObjectId)
                          as PlacemarkMapObject;

                      setState(() {
                        mapObjects[mapObjects.indexOf(placemarkMapObject)] =
                            placemarkMapObject.copyWith(
                                point: cameraPosition.target);
                      });
                    },
                    onMapCreated:
                        (YandexMapController yandexMapController) async {
                      final placemarkMapObject = mapObjects
                              .firstWhere((el) => el.mapId == cameraMapObjectId)
                          as PlacemarkMapObject;

                      controller = yandexMapController;

                      await controller.moveCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: placemarkMapObject.point,
                            zoom: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  child: GestureDetector(
                    onTap: () async {
                      Permission.locationWhenInUse.request().then(
                        (value) async {
                          if (value.isGranted) {
                            Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.best,
                            ).then((position) async {
                              await controller.moveCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: Point(
                                      latitude: position.latitude,
                                      longitude: position.longitude,
                                    ),
                                  ),
                                ),
                                animation: animation,
                              );
                            });
                          } else if (value.isDenied) {
                            openAppSettings();
                          } else {
                            AppSettings.openLocationSettings();
                          }
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            translate("address.me"),
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: AppColors.text_dark,
                            ),
                          ),
                          SizedBox(width: 5),
                          SvgPicture.asset("assets/icons/gps.svg")
                        ],
                      ),
                    ),
                  ),
                  bottom: 4,
                  right: 8,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 22,
              right: 22,
              bottom: 24,
              top: 12,
            ),
            color: AppColors.white,
            child: GestureDetector(
              onTap: () async {
                final cameraPosition = await controller.getCameraPosition();
                widget.onChooseLocation(
                  Point(
                    latitude: cameraPosition.target.latitude,
                    longitude: cameraPosition.target.longitude,
                  ),
                );
                Navigator.pop(context);
              },
              child: Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    translate("address.choose"),
                    style: TextStyle(
                      fontFamily: AppColors.fontRubik,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.2,
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
