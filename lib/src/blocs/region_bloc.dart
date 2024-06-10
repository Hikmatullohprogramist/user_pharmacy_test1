import 'dart:convert';

import 'package:flutter_translate/flutter_translate.dart';
import 'package:pharmacy/src/model/api/region_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:rxdart/rxdart.dart';

class RegionBloc {
  final _repository = Repository();
  final _regionFetcher = PublishSubject<List<RegionModel>>();

  Stream<List<RegionModel>> get allRegion => _regionFetcher.stream;

  fetchAllRegion() async {
    var response = await _repository.fetchRegions();
    if (response.isSuccess) {
      var result = regionModelFromJson(json.encode(response.result));
      for (int i = 0; i < result.length; i++) {
        if (result[i].childs.length > 0) {
          result[i].childs.insert(
                0,
                RegionModel(
                  id: result[i].id,
                  name: translate("region.all") + " " + result[i].name,
                  parentName: result[i].name,
                  coords: result[i].coords,
                  childs: [],
                ),
              );
        }
      }
      _regionFetcher.sink.add(result);
    }
  }

  dispose() {
    _regionFetcher.close();
  }
}

final blocRegion = RegionBloc();
