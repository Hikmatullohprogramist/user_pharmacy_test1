import 'package:pharmacy/src/model/api/blog_model.dart';
import 'package:pharmacy/src/model/api/category_model.dart';
import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/model/api/sale_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeBloc {
  final _repository = Repository();
  final _bannerFetcher = PublishSubject<BannerModel>();
  final _blogFetcher = PublishSubject<BlogModel>();
  final _cashBackFetcher = PublishSubject<BlogModel>();
  final _cityNameFetcher = PublishSubject<String>();
  final _bestItemFetcher = PublishSubject<ItemModel>();
  final _recentlyFetcher = PublishSubject<ItemModel>();
  final _slimmingFetcher = PublishSubject<ItemModel>();
  final _categoryFetcher = PublishSubject<CategoryModel>();

  Stream<BannerModel> get banner => _bannerFetcher.stream;

  Stream<BlogModel> get blog => _blogFetcher.stream;

  Stream<BlogModel> get cashBack => _cashBackFetcher.stream;

  Stream<String> get allCityName => _cityNameFetcher.stream;

  Stream<ItemModel> get getBestItem => _bestItemFetcher.stream;

  Stream<ItemModel> get recentlyItem => _recentlyFetcher.stream;

  Stream<ItemModel> get slimmingItem => _slimmingFetcher.stream;

  Stream<CategoryModel> get categoryItem => _categoryFetcher.stream;

  fetchBanner() async {
    var response = await _repository.fetchAllSales();
    if (response.isSuccess) {
      _bannerFetcher.sink.add(BannerModel.fromJson(response.result));
    } else {
      _bannerFetcher.sink.add(BannerModel.fromJson({}));
    }
  }

  fetchBlog(int page) async {
    var response = await _repository.fetchBlog();
    if (response.isSuccess) {
      _blogFetcher.sink.add(BlogModel.fromJson(response.result));
    } else {
      _blogFetcher.sink.add(BlogModel.fromJson({}));
    }
  }

  fetchCashBack() async {
    var response = await _repository.fetchCashBackTitle();
    if (response.isSuccess) {
      _cashBackFetcher.sink.add(BlogModel.fromJson(response.result));
    } else {
      _cashBackFetcher.sink.add(BlogModel.fromJson({}));
    }
  }

  ///recently
  ItemModel? recentlyItemData;

  fetchRecently() async {
    var response = await _repository.fetchRecently(
      "",
      "",
    );
    if (response.isSuccess) {
      recentlyItemData = ItemModel.fromJson(response.result);
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
      _recentlyFetcher.sink.add(recentlyItemData!);
    } else if (response.status == -1) {
      RxBus.post(BottomView(true), tag: "HOME_VIEW_ERROR_NETWORK");
    }
  }

  fetchRecentlyUpdate() async {
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
      _recentlyFetcher.sink.add(recentlyItemData!);
    } else {
      fetchRecently();
    }
  }

  fetchCategory() async {
    var response = await _repository.fetchTopCategory();
    if (response.isSuccess) {
      _categoryFetcher.sink.add(CategoryModel.fromJson(response.result));
    } else {
      _categoryFetcher.sink.add(CategoryModel.fromJson({}));
    }
  }

  ///Best item
  ItemModel? bestItemData;

  fetchBestItem() async {
    var response = await _repository.fetchBestItem(
      1,
      "",
      "",
    );
    if (response.isSuccess) {
      bestItemData = ItemModel.fromJson(response.result);
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
      _bestItemFetcher.sink.add(bestItemData!);
    }
  }

  fetchBestUpdate() async {
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
      _bestItemFetcher.sink.add(bestItemData!);
    } else {
      fetchBestItem();
    }
  }

  ///slimming
  ItemModel? slimmingItemData;

  fetchSlimmingItem() async {
    var response = await _repository.fetchSlimming();
    if (response.isSuccess) {
      slimmingItemData = ItemModel.fromJson(response.result);
      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> resultFav = await _repository.databaseFavItem();
      if (slimmingItemData!.drugs.length > 0) {
        for (var i = 0; i < slimmingItemData!.drugs.length; i++) {
          for (var j = 0; j < database.length; j++) {
            if (slimmingItemData!.drugs[i].id == database[j].id) {
              slimmingItemData!.drugs[i].cardCount = database[j].cardCount;
            }
          }
        }

        for (int i = 0; i < slimmingItemData!.drugs.length; i++) {
          slimmingItemData!.drugs[i].favourite = false;
          for (int j = 0; j < resultFav.length; j++) {
            if (slimmingItemData!.drugs[i].id == resultFav[j].id) {
              slimmingItemData!.drugs[i].favourite = resultFav[j].favourite;
              break;
            }
          }
        }
      }
      _slimmingFetcher.sink.add(slimmingItemData!);
    }
  }

  fetchSlimmingUpdate() async {
    if (slimmingItemData != null) {
      List<ItemResult> database = await _repository.databaseItem();
      List<ItemResult> resultFav = await _repository.databaseFavItem();
      if (slimmingItemData!.drugs.length > 0) {
        for (var i = 0; i < slimmingItemData!.drugs.length; i++) {
          slimmingItemData!.drugs[i].cardCount = 0;
          for (var j = 0; j < database.length; j++) {
            if (slimmingItemData!.drugs[i].id == database[j].id) {
              slimmingItemData!.drugs[i].cardCount = database[j].cardCount;
            }
          }
        }

        for (int i = 0; i < slimmingItemData!.drugs.length; i++) {
          slimmingItemData!.drugs[i].favourite = false;
          for (int j = 0; j < resultFav.length; j++) {
            if (slimmingItemData!.drugs[i].id == resultFav[j].id) {
              slimmingItemData!.drugs[i].favourite = resultFav[j].favourite;
              break;
            }
          }
        }
      }
      _slimmingFetcher.sink.add(slimmingItemData!);
    } else {
      fetchSlimmingItem();
    }
  }

  update() {
    fetchBestUpdate();
    fetchSlimmingUpdate();
    fetchRecentlyUpdate();
  }

  fetchCityName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("city") != null) {
      _cityNameFetcher.sink.add(prefs.getString("city") ?? "");
    }
  }

  dispose() {
    _bannerFetcher.close();
    _blogFetcher.close();
    _cashBackFetcher.close();
    _cityNameFetcher.close();
    _bestItemFetcher.close();
    _slimmingFetcher.close();
    _recentlyFetcher.close();
    _categoryFetcher.close();
  }
}

final blocHome = HomeBloc();
