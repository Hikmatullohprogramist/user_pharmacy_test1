import 'package:pharmacy/src/blocs/card_bloc.dart';
import 'package:pharmacy/src/blocs/fav_bloc.dart';
import 'package:pharmacy/src/blocs/home_bloc.dart';
import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/model/api/items_all_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:rxdart/rxdart.dart';

class ItemBloc {
  final _repository = Repository();
  final _itemFetcher = PublishSubject<ItemsAllModel>();

  Stream<ItemsAllModel> get allItems => _itemFetcher.stream;
  ItemsAllModel? items;

  fetchAllInfoItem(String id) async {
    var response = await _repository.fetchItems(id);
    if (response.isSuccess) {
      items = ItemsAllModel.fromJson(response.result);

      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> databaseFav = await _repository.databaseFavItem();
      for (int i = 0; i < databaseFav.length; i++) {
        if (databaseFav[i].id == items!.id) {
          items!.favourite = true;
        }
      }
      for (var j = 0; j < database.length; j++) {
        if (items!.id == database[j].id) {
          items!.cardCount = database[j].cardCount;
        }
      }
      for (var i = 0; i < items!.analog.length; i++) {
        for (var j = 0; j < database.length; j++) {
          if (items!.analog[i].id == database[j].id) {
            items!.analog[i].cardCount = database[j].cardCount;
          }
        }
      }
      for (var i = 0; i < items!.analog.length; i++) {
        for (var j = 0; j < databaseFav.length; j++) {
          if (items!.analog[i].id == databaseFav[j].id) {
            items!.analog[i].favourite = true;
          }
        }
      }
      _itemFetcher.sink.add(items!);
    } else if (response.status == -1) {
      RxBus.post(BottomViewIdsModel(id), tag: "HOME_VIEW_ERROR_HISTORY");
    }
  }

  fetchItemUpdate(int position) async {
    if (items != null) {
      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> databaseFav = await _repository.databaseFavItem();
      items!.favourite = false;
      items!.cardCount = 0;
      for (int i = 0; i < databaseFav.length; i++) {
        if (databaseFav[i].id == items!.id) {
          items!.favourite = true;
        }
      }
      for (var j = 0; j < database.length; j++) {
        if (items!.id == database[j].id) {
          items!.cardCount = database[j].cardCount;
        }
      }
      _itemFetcher.sink.add(items!);
      if (position == 0) {
        blocHome.update();
      } else if (position == 1) {
        //category
      } else if (position == 2) {
        blocCard.fetchAllCard();
      } else if (position == 3) {
        blocFav.fetchAllFav();
      }
    }
  }

  fetchAnalogUpdate() async {
    if (items != null) {
      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> databaseFav = await _repository.databaseFavItem();
      for (var i = 0; i < items!.analog.length; i++) {
        items!.analog[i].cardCount = 0;
        for (var j = 0; j < database.length; j++) {
          if (items!.analog[i].id == database[j].id) {
            items!.analog[i].cardCount = database[j].cardCount;
          }
        }
      }
      for (var i = 0; i < items!.analog.length; i++) {
        items!.analog[i].favourite = false;
        for (var j = 0; j < databaseFav.length; j++) {
          if (items!.analog[i].id == databaseFav[j].id) {
            items!.analog[i].favourite = true;
          }
        }
      }
      _itemFetcher.sink.add(items!);
    }
  }

  dispose() {
    _itemFetcher.close();
  }
}

final blocItem = ItemBloc();
