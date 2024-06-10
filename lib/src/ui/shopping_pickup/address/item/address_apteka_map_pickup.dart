import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/model/api/location_model.dart';
import 'package:pharmacy/src/model/http_result.dart';
import 'package:pharmacy/src/model/send/access_store.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/ui/dialog/bottom_dialog.dart';
import 'package:pharmacy/src/ui/main/main_screen.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../../../static/app_colors.dart';

class AddressStoreMapPickupScreen extends StatefulWidget {
  final List<ProductsStore> drugs;
  final Function(LocationModel store) chooseStore;

  AddressStoreMapPickupScreen(
    this.drugs,
    this.chooseStore,
  );

  @override
  State<StatefulWidget> createState() {
    return _AddressStoreMapPickupScreenState();
  }
}

class _AddressStoreMapPickupScreenState
    extends State<AddressStoreMapPickupScreen>
    with AutomaticKeepAliveClientMixin<AddressStoreMapPickupScreen> {
  @override
  bool get wantKeepAlive => true;

  MapAnimation animation = const MapAnimation(duration: 0.5);

  YandexMapController? mapController;
  final List<PlacemarkMapObject> placemarks = <PlacemarkMapObject>[];
  DatabaseHelper dataBase = new DatabaseHelper();

  bool isGranted = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    mapController!.dispose();
    super.dispose();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            YandexMap(
              mapObjects: placemarks,
              onMapCreated: (YandexMapController yandexMapController) async {
                mapController = yandexMapController;
                await mapController!.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: Point(
                        latitude: 41.311081,
                        longitude: 69.240562,
                      ),
                      zoom: 11,
                    ),
                  ),
                  animation: animation,
                );
              },
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
            ),
            Positioned(
              child: GestureDetector(
                onTap: () async {
                  Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.best,
                  ).then((position) async {
                    await mapController!.moveCamera(
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
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
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
            isLoading
                ? Container(
                    color: AppColors.white.withOpacity(0.6),
                    child: Align(
                      alignment: Alignment.center,
                      child: Lottie.asset(
                        'assets/anim/blue.json',
                        height: 120,
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    Permission.locationWhenInUse.request().then(
      (value) async {
        if (value.isGranted) {
          _getPosition();
        } else {
          _defaultLocation();
        }
      },
    );
  }

  void _addMarkers(HttpResult response) async {
    if (response.isSuccess) {
      _isLoading(false);
      if (locationModelFromJson(json.encode(response.result)).length > 0) {
        _addMarkerData(locationModelFromJson(json.encode(response.result)));
      }
    } else {
      _isLoading(false);
    }
  }

  void _isLoading(bool response) async {
    setState(() {
      isLoading = response;
    });
  }

  void _addMarkerData(List<LocationModel> data) {
    double latOr = 0.0, lngOr = 0.0;
    for (int i = 0; i < data.length; i++) {
      latOr += data[i].location.coordinates[1];
      lngOr += data[i].location.coordinates[0];

      placemarks.add(
        PlacemarkMapObject(
          point: Point(
            latitude: data[i].location.coordinates[1],
            longitude: data[i].location.coordinates[0],
          ),
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(
                'assets/map/selected_order.png',
              ),
            ),
          ),
          opacity: 1,
          onTap: (_, Point point) {
            BottomDialog.showStoreInfo(
              context,
              data[i],
              (value) {
                Navigator.pop(context);
                widget.chooseStore(value);
              },
            );
          },
          mapId: MapObjectId('map_object_collection' + i.toString()),
        ),
      );
    }
    setState(() {});
    if (mapController != null)
      mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: latOr / data.length,
              longitude: lngOr / data.length,
            ),
            zoom: 11,
          ),
        ),
        animation: animation,
      );
  }

  Future<void> _getPosition() async {
    AccessStore? addModel;
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    lat = position.latitude;
    lng = position.longitude;
    addModel = new AccessStore(
      lat: position.latitude,
      lng: position.longitude,
      products: widget.drugs,
    );
    Utils.saveLocation(position.latitude, position.longitude);
    _addMarkers(await Repository().fetchAccessStore(addModel));
  }

  Future<void> _defaultLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var lat = prefs.getDouble("coordLat") ?? 41.311081;
    var lng = prefs.getDouble("coordLng") ?? 69.240562;

    AccessStore addModel = new AccessStore(
      products: widget.drugs,
      lng: 0.0,
      lat: 0.0,
    );
    _addMarkers(await Repository().fetchAccessStore(addModel));
    if (mapController != null) {
      await mapController!.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: Point(
                latitude: lat,
                longitude: lng,
              ),
              zoom: 11),
        ),
        animation: animation,
      );
    }
  }
}
