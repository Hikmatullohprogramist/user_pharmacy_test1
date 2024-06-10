import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:rxdart/rxdart.dart';

class ItemListBloc {
  final _repository = Repository();

  final _listItemsFetcher = PublishSubject<ItemModel>();

  Stream<ItemModel> get allItemsList => _listItemsFetcher.stream;

  ///recently
  ItemModel? recentlyItemData;

  fetchAllRecently(
    int page,
    String ordering,
    String priceMax,
  ) async {
    var response = await _repository.fetchRecently(
      "",
      "",
    );
    if (response.isSuccess) {
      if (page == 1) {
        recentlyItemData = ItemModel.fromJson(response.result);
      } else {
        var data = ItemModel.fromJson(response.result);
        recentlyItemData!.next = data.next;
        recentlyItemData!.results.addAll(data.results);
      }
      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> resultFav = await _repository.databaseFavItem();
      if (recentlyItemData!.results.length > 0) {
        for (var i = 0; i < recentlyItemData!.results.length; i++) {
          for (var j = 0; j < database.length; j++) {
            if (recentlyItemData!.results[i].id == database[j].id) {
              recentlyItemData!.results[i].cardCount = database[j].cardCount;
            }
          }
        }

        for (int i = 0; i < recentlyItemData!.results.length; i++) {
          recentlyItemData!.results[i].favourite = false;
          for (int j = 0; j < resultFav.length; j++) {
            if (recentlyItemData!.results[i].id == resultFav[j].id) {
              recentlyItemData!.results[i].favourite = resultFav[j].favourite;
              break;
            }
          }
        }
      }
      _listItemsFetcher.sink.add(recentlyItemData!);
    } else {
      RxBus.post(BottomView(true), tag: "LIST_VIEW_ERROR_NETWORK");
    }
  }

  ///category
  ItemModel? categoryItemData;

  fetchCategory(
    String id,
    int page,
    String ordering,
    String priceMax,
  ) async {
    var response = await _repository.fetchCategoryItemList(
      id,
      page,
      ordering,
      priceMax,
    );
    if (response.isSuccess) {
      if (page == 1) {
        categoryItemData = ItemModel.fromJson(response.result);
      } else {
        var data = ItemModel.fromJson(response.result);
        categoryItemData!.next = data.next;
        categoryItemData!.results.addAll(data.results);
      }

      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> resultFav = await _repository.databaseFavItem();
      if (categoryItemData!.results.length > 0) {
        for (var i = 0; i < categoryItemData!.results.length; i++) {
          for (var j = 0; j < database.length; j++) {
            if (categoryItemData!.results[i].id == database[j].id) {
              categoryItemData!.results[i].cardCount = database[j].cardCount;
            }
          }
        }

        for (int i = 0; i < categoryItemData!.results.length; i++) {
          categoryItemData!.results[i].favourite = false;
          for (int j = 0; j < resultFav.length; j++) {
            if (categoryItemData!.results[i].id == resultFav[j].id) {
              categoryItemData!.results[i].favourite = resultFav[j].favourite;
              break;
            }
          }
        }
      }
      _listItemsFetcher.sink.add(categoryItemData!);
    } else {
      RxBus.post(BottomView(true), tag: "LIST_VIEW_ERROR_NETWORK");
    }
  }

  ///best
  ItemModel? bestItemData;

  fetchAllBestItem(
    int page,
    String ordering,
    String priceMax,
  ) async {
    var response = await _repository.fetchBestItem(
      page,
      ordering,
      priceMax,
    );
    if (response.isSuccess) {
      if (page == 1) {
        bestItemData = ItemModel.fromJson(response.result);
      } else {
        var data = ItemModel.fromJson(response.result);
        bestItemData!.next = data.next;
        bestItemData!.results.addAll(data.results);
      }
      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> resultFav = await _repository.databaseFavItem();
      if (bestItemData!.results.length > 0) {
        for (var i = 0; i < bestItemData!.results.length; i++) {
          for (var j = 0; j < database.length; j++) {
            if (bestItemData!.results[i].id == database[j].id) {
              bestItemData!.results[i].cardCount = database[j].cardCount;
            }
          }
        }

        for (int i = 0; i < bestItemData!.results.length; i++) {
          bestItemData!.results[i].favourite = false;
          for (int j = 0; j < resultFav.length; j++) {
            if (bestItemData!.results[i].id == resultFav[j].id) {
              bestItemData!.results[i].favourite = resultFav[j].favourite;
              break;
            }
          }
        }
      }
      _listItemsFetcher.sink.add(bestItemData!);
    } else {
      RxBus.post(BottomView(true), tag: "LIST_VIEW_ERROR_NETWORK");
    }
  }

  ///coll
  ItemModel? collItemData;

  fetchAllCollItem(
    int page,
    String ordering,
    String priceMax,
  ) async {
    var response = await _repository.fetchSlimming();
    if (response.isSuccess) {
      if (page == 1) {
        var data = ItemModel.fromJson(response.result);
        collItemData = ItemModel(
          next: data.next,
          results: data.drugs,
          drugs: [],
          title: '',
          count: 0,
        );
      } else {
        var data = ItemModel.fromJson(response.result);
        collItemData!.next = data.next;
        collItemData!.results.addAll(data.drugs);
      }
      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> resultFav = await _repository.databaseFavItem();
      if (collItemData!.results.length > 0) {
        for (var i = 0; i < collItemData!.results.length; i++) {
          for (var j = 0; j < database.length; j++) {
            if (collItemData!.results[i].id == database[j].id) {
              collItemData!.results[i].cardCount = database[j].cardCount;
            }
          }
        }

        for (int i = 0; i < collItemData!.results.length; i++) {
          collItemData!.results[i].favourite = false;
          for (int j = 0; j < resultFav.length; j++) {
            if (collItemData!.results[i].id == resultFav[j].id) {
              collItemData!.results[i].favourite = resultFav[j].favourite;
              break;
            }
          }
        }
      }
      _listItemsFetcher.sink.add(collItemData!);
    } else {
      RxBus.post(BottomView(true), tag: "LIST_VIEW_ERROR_NETWORK");
    }
  }

  ///ids
  ItemModel? idsItemData;

  fetchAllIdsItem(
    String ids,
    int page,
    String ordering,
    String priceMax,
  ) async {
    var response =
        await _repository.fetchIdsItemsList(ids, page, ordering, priceMax);
    if (response.isSuccess) {
      if (page == 1) {
        idsItemData = ItemModel.fromJson(response.result);
      } else {
        var data = ItemModel.fromJson(response.result);
        idsItemData!.next = data.next;
        idsItemData!.results.addAll(data.results);
      }
      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> resultFav = await _repository.databaseFavItem();
      if (idsItemData!.results.length > 0) {
        for (var i = 0; i < idsItemData!.results.length; i++) {
          for (var j = 0; j < database.length; j++) {
            if (idsItemData!.results[i].id == database[j].id) {
              idsItemData!.results[i].cardCount = database[j].cardCount;
            }
          }
        }

        for (int i = 0; i < idsItemData!.results.length; i++) {
          idsItemData!.results[i].favourite = false;
          for (int j = 0; j < resultFav.length; j++) {
            if (idsItemData!.results[i].id == resultFav[j].id) {
              idsItemData!.results[i].favourite = resultFav[j].favourite;
              break;
            }
          }
        }
      }
      _listItemsFetcher.sink.add(idsItemData!);
    } else {
      RxBus.post(BottomView(true), tag: "LIST_VIEW_ERROR_NETWORK");
    }
  }

  ///search
  ItemModel? searchData;

  fetchAllSearchItem(
    String ids,
    int page,
    String ordering,
    String priceMax,
  ) async {
    var response =
        await _repository.fetchSearchItemList(ids, page, ordering, priceMax);
    if (response.isSuccess) {
      if (page == 1) {
        searchData = ItemModel.fromJson(response.result);
      } else {
        var data = ItemModel.fromJson(response.result);
        searchData!.next = data.next;
        searchData!.results.addAll(data.results);
      }
      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> resultFav = await _repository.databaseFavItem();
      if (searchData!.results.length > 0) {
        for (var i = 0; i < searchData!.results.length; i++) {
          for (var j = 0; j < database.length; j++) {
            if (searchData!.results[i].id == database[j].id) {
              searchData!.results[i].cardCount = database[j].cardCount;
            }
          }
        }

        for (int i = 0; i < searchData!.results.length; i++) {
          searchData!.results[i].favourite = false;
          for (int j = 0; j < resultFav.length; j++) {
            if (searchData!.results[i].id == resultFav[j].id) {
              searchData!.results[i].favourite = resultFav[j].favourite;
              break;
            }
          }
        }
      }
      _listItemsFetcher.sink.add(searchData!);
    } else {
      RxBus.post(BottomView(true), tag: "LIST_VIEW_ERROR_NETWORK");
    }
  }

  update(int type) async {
    if (type == 1) {
      if (recentlyItemData != null) {
        List<ItemResult> database = await _repository.databaseItem();
        List<ItemResult> resultFav = await _repository.databaseFavItem();
        if (recentlyItemData!.results.length > 0) {
          for (var i = 0; i < recentlyItemData!.results.length; i++) {
            recentlyItemData!.results[i].cardCount = 0;
            for (var j = 0; j < database.length; j++) {
              if (recentlyItemData!.results[i].id == database[j].id) {
                recentlyItemData!.results[i].cardCount = database[j].cardCount;
              }
            }
          }

          for (int i = 0; i < recentlyItemData!.results.length; i++) {
            recentlyItemData!.results[i].favourite = false;
            for (int j = 0; j < resultFav.length; j++) {
              if (recentlyItemData!.results[i].id == resultFav[j].id) {
                recentlyItemData!.results[i].favourite = resultFav[j].favourite;
                break;
              }
            }
          }
        }
        _listItemsFetcher.sink.add(recentlyItemData!);
      }
    } else if (type == 2) {
      if (categoryItemData != null) {
        List<ItemResult> database = await _repository.databaseItem();
        List<ItemResult> resultFav = await _repository.databaseFavItem();
        if (categoryItemData!.results.length > 0) {
          for (var i = 0; i < categoryItemData!.results.length; i++) {
            categoryItemData!.results[i].cardCount = 0;
            for (var j = 0; j < database.length; j++) {
              if (categoryItemData!.results[i].id == database[j].id) {
                categoryItemData!.results[i].cardCount = database[j].cardCount;
              }
            }
          }

          for (int i = 0; i < categoryItemData!.results.length; i++) {
            categoryItemData!.results[i].favourite = false;
            for (int j = 0; j < resultFav.length; j++) {
              if (categoryItemData!.results[i].id == resultFav[j].id) {
                categoryItemData!.results[i].favourite = resultFav[j].favourite;
                break;
              }
            }
          }
        }
        _listItemsFetcher.sink.add(categoryItemData!);
      }
    } else if (type == 3) {
      if (bestItemData != null) {
        List<ItemResult> database = await _repository.databaseItem();
        List<ItemResult> resultFav = await _repository.databaseFavItem();
        if (bestItemData!.results.length > 0) {
          for (var i = 0; i < bestItemData!.results.length; i++) {
            bestItemData!.results[i].cardCount = 0;
            for (var j = 0; j < database.length; j++) {
              if (bestItemData!.results[i].id == database[j].id) {
                bestItemData!.results[i].cardCount = database[j].cardCount;
              }
            }
          }

          for (int i = 0; i < bestItemData!.results.length; i++) {
            bestItemData!.results[i].favourite = false;
            for (int j = 0; j < resultFav.length; j++) {
              if (bestItemData!.results[i].id == resultFav[j].id) {
                bestItemData!.results[i].favourite = resultFav[j].favourite;
                break;
              }
            }
          }
        }
        _listItemsFetcher.sink.add(bestItemData!);
      }
    } else if (type == 4) {
      if (collItemData != null) {
        List<ItemResult> database = await _repository.databaseItem();
        List<ItemResult> resultFav = await _repository.databaseFavItem();
        if (collItemData!.results.length > 0) {
          for (var i = 0; i < collItemData!.results.length; i++) {
            collItemData!.results[i].cardCount = 0;
            for (var j = 0; j < database.length; j++) {
              if (collItemData!.results[i].id == database[j].id) {
                collItemData!.results[i].cardCount = database[j].cardCount;
              }
            }
          }

          for (int i = 0; i < collItemData!.results.length; i++) {
            collItemData!.results[i].favourite = false;
            for (int j = 0; j < resultFav.length; j++) {
              if (collItemData!.results[i].id == resultFav[j].id) {
                collItemData!.results[i].favourite = resultFav[j].favourite;
                break;
              }
            }
          }
        }
        _listItemsFetcher.sink.add(collItemData!);
      }
    } else if (type == 5) {
      if (idsItemData != null) {
        List<ItemResult> database = await _repository.databaseItem();
        List<ItemResult> resultFav = await _repository.databaseFavItem();
        if (idsItemData!.results.length > 0) {
          for (var i = 0; i < idsItemData!.results.length; i++) {
            idsItemData!.results[i].cardCount = 0;
            for (var j = 0; j < database.length; j++) {
              if (idsItemData!.results[i].id == database[j].id) {
                idsItemData!.results[i].cardCount = database[j].cardCount;
              }
            }
          }

          for (int i = 0; i < idsItemData!.results.length; i++) {
            idsItemData!.results[i].favourite = false;
            for (int j = 0; j < resultFav.length; j++) {
              if (idsItemData!.results[i].id == resultFav[j].id) {
                idsItemData!.results[i].favourite = resultFav[j].favourite;
                break;
              }
            }
          }
        }
        _listItemsFetcher.sink.add(idsItemData!);
      }
    } else if (type == 6) {
      if (searchData != null) {
        List<ItemResult> database = await _repository.databaseItem();
        List<ItemResult> resultFav = await _repository.databaseFavItem();
        if (searchData!.results.length > 0) {
          for (var i = 0; i < searchData!.results.length; i++) {
            searchData!.results[i].cardCount = 0;
            for (var j = 0; j < database.length; j++) {
              if (searchData!.results[i].id == database[j].id) {
                searchData!.results[i].cardCount = database[j].cardCount;
              }
            }
          }

          for (int i = 0; i < searchData!.results.length; i++) {
            searchData!.results[i].favourite = false;
            for (int j = 0; j < resultFav.length; j++) {
              if (searchData!.results[i].id == resultFav[j].id) {
                searchData!.results[i].favourite = resultFav[j].favourite;
                break;
              }
            }
          }
        }
        _listItemsFetcher.sink.add(searchData!);
      }
    }
  }

  dispose() {
    _listItemsFetcher.close();
  }
}

final blocItemsList = ItemListBloc();
