import 'dart:convert';

import 'package:pharmacy/src/model/api/location_model.dart';
import 'package:pharmacy/src/model/database/address_model.dart';
import 'package:pharmacy/src/model/send/access_store.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:rxdart/rxdart.dart';

class StoreBloc {
  final _repository = Repository();

  final _existStoreFetcher = PublishSubject<List<LocationModel>>();
  final _addressFetcher = PublishSubject<List<AddressModel>>();
  final _addressAllFetcher = PublishSubject<List<AddressModel>>();
  final _addressHomeFetcher = PublishSubject<AddressModel>();
  final _addressWorkFetcher = PublishSubject<AddressModel>();

  Stream<List<LocationModel>> get allExistStore => _existStoreFetcher.stream;

  Stream<List<AddressModel>> get allAddress => _addressFetcher.stream;

  Stream<List<AddressModel>> get allAddressInfo => _addressAllFetcher.stream;

  Stream<AddressModel> get allAddressHome => _addressHomeFetcher.stream;

  Stream<AddressModel> get allAddressWork => _addressWorkFetcher.stream;

  fetchAddress() async {
    _addressFetcher.sink.add(await _repository.databaseAddress());
  }

  fetchAllAddress() async {
    List<AddressModel> data = await _repository.databaseAddressAll();
    List<AddressModel> sortData = <AddressModel>[];
    for (int i = 0; i < data.length; i++) {
      if (data[i].type == 1) {
        sortData.add(data[i]);
        break;
      }
    }
    for (int i = 0; i < data.length; i++) {
      if (data[i].type == 2) {
        sortData.add(data[i]);
        break;
      }
    }
    for (int i = 0; i < data.length; i++) {
      if (data[i].type == 0) {
        sortData.add(data[i]);
      }
    }

    _addressAllFetcher.sink.add(sortData);
  }

  fetchAddressHome() async {
    AddressModel? data = await _repository.databaseAddressType(1);
    if (data != null) {
      _addressHomeFetcher.sink.add(data);
    }
  }

  fetchAddressWork() async {
    AddressModel? data = await _repository.databaseAddressType(2);
    if (data != null) {
      _addressWorkFetcher.sink.add(data);
    }
  }

  fetchAccessStore(AccessStore accessStore) async {
    var response = await _repository.fetchAccessStore(accessStore);
    if (response.isSuccess) {
      _existStoreFetcher.sink
          .add(locationModelFromJson(json.encode(response.result)));
    }
  }

  dispose() {
    _existStoreFetcher.close();
    _addressAllFetcher.close();
    _addressFetcher.close();
    _addressHomeFetcher.close();
    _addressWorkFetcher.close();
  }
}

final blocStore = StoreBloc();
