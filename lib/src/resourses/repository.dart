import 'dart:async';

import 'package:pharmacy/src/database/database_helper.dart';
import 'package:pharmacy/src/database/database_helper_address.dart';
import 'package:pharmacy/src/database/database_helper_fav.dart';
import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/model/database/address_model.dart';
import 'package:pharmacy/src/model/http_result.dart';
import 'package:pharmacy/src/model/send/access_store.dart';
import 'package:pharmacy/src/model/send/create_order_model.dart';
import 'package:pharmacy/src/model/send/create_payment_model.dart';

import 'pharmacy_api_provider.dart';

class Repository {
  final pharmacyApiProvider = PharmacyApiProvider();

  DatabaseHelper databaseHelper = new DatabaseHelper();
  DatabaseHelperFav databaseHelperFav = new DatabaseHelperFav();
  DatabaseHelperAddress databaseHelperAddress = new DatabaseHelperAddress();

  Future<HttpResult> fetchLogin(String login) =>
      pharmacyApiProvider.fetchLogin(login);

  Future<HttpResult> fetchLoginCaptcha(
    String login,
    String captchaKey,
    String captchaValue,
  ) =>
      pharmacyApiProvider.fetchLoginCaptcha(
        login,
        captchaKey,
        captchaValue,
      );

  Future<HttpResult> fetchGetCaptcha() => pharmacyApiProvider.fetchGetCaptcha();

  Future<HttpResult> fetchVerify(String login, String code, String token) =>
      pharmacyApiProvider.fetchVerify(login, code, token);

  Future<HttpResult> fetchRegister(
    String name,
    String surname,
    String birthday,
    String gender,
    String token,
    String fctoken,
  ) =>
      pharmacyApiProvider.fetchRegister(
        name,
        surname,
        birthday,
        gender,
        token,
        fctoken,
      );

  Future<HttpResult> fetchAllSales() => pharmacyApiProvider.fetchBanner();

  Future<HttpResult> fetchBlog() => pharmacyApiProvider.fetchBlog();

  Future<HttpResult> fetchTopCategory() =>
      pharmacyApiProvider.fetchTopCategory();

  Future<HttpResult> fetchSlimming() => pharmacyApiProvider.fetchSlimming();

  Future<HttpResult> fetchCashBackTitle() =>
      pharmacyApiProvider.fetchCashBackTitle();

  Future<HttpResult> fetchBestItem(
    int page,
    String ordering,
    String priceMax,
  ) =>
      pharmacyApiProvider.fetchBestItemList(
        page,
        20,
        ordering,
        priceMax,
      );

  Future<HttpResult> fetchRecently(
    String ordering,
    String priceMax,
  ) =>
      pharmacyApiProvider.fetchRecently(
        ordering,
        priceMax,
      );

  Future<HttpResult> fetchCategoryItem() =>
      pharmacyApiProvider.fetchCategoryList();

  Future<List<ItemResult>> databaseItem() => databaseHelper.getProduct();

  Future<List<AddressModel>> databaseAddress() =>
      databaseHelperAddress.getProduct();

  Future<List<AddressModel>> databaseAddressAll() =>
      databaseHelperAddress.getAllProduct();

  Future<AddressModel?> databaseAddressType(int id) =>
      databaseHelperAddress.getProductsType(id);

  Future<List<ItemResult>> databaseCardItem(bool isCard) =>
      databaseHelper.getProdu(isCard);

  Future<List<ItemResult>> databaseFavItem() => databaseHelperFav.getProduct();

  Future<HttpResult> fetchCategoryItemList(
    String id,
    int page,
    String ordering,
    String priceMax,
  ) =>
      pharmacyApiProvider.fetchCategoryItemsList(
        id,
        page,
        20,
        ordering,
        priceMax,
      );

  Future<HttpResult> fetchIdsItemsList(
    String id,
    int page,
    String ordering,
    String priceMax,
  ) =>
      pharmacyApiProvider.fetchIdsItemsList(
        id,
        page,
        20,
        ordering,
        priceMax,
      );

  Future<HttpResult> fetchSearchItemList(
    String obj,
    int page,
    String ordering,
    String priceMax,
  ) =>
      pharmacyApiProvider.fetchSearchItemsList(
        obj,
        page,
        20,
        ordering,
        priceMax,
      );

  Future<HttpResult> fetchItems(String id) =>
      pharmacyApiProvider.fetchItems(id);

  Future<HttpResult> fetchAllMessage(int page) =>
      pharmacyApiProvider.fetchAllMessage(page);

  Future<HttpResult> fetchSendMessage(String message) =>
      pharmacyApiProvider.fetchSendMessage(message);

  Future<HttpResult> fetchAccessStore(AccessStore accessStore) =>
      pharmacyApiProvider.fetchAccessStore(accessStore);

  Future<HttpResult> fetchRegions() => pharmacyApiProvider.fetchRegions();

  Future<HttpResult> fetchPayment(PaymentOrderModel order) =>
      pharmacyApiProvider.fetchPayment(order);

  Future<HttpResult> fetchCreateOrder(CreateOrderModel order) =>
      pharmacyApiProvider.fetchCreateOrder(order);

  Future<HttpResult> fetchCheckOrder(CreateOrderModel order) =>
      pharmacyApiProvider.fetchCheckOrder(order);

  Future<HttpResult> fetchHistory(int page) =>
      pharmacyApiProvider.fetchOrderHistory(page, 20);

  Future<HttpResult> fetchCancelOrder(int orderId) =>
      pharmacyApiProvider.fetchCancelOrder(orderId);

  Future<HttpResult> fetchOrderOptions() =>
      pharmacyApiProvider.fetchOrderOptions();

  Future<HttpResult> fetchCheckErrorPickup(
    AccessStore accessStore,
  ) =>
      pharmacyApiProvider.fetchCheckErrorPickup(
        accessStore,
      );

  Future<HttpResult> fetchCheckErrorDelivery(AccessStore accessStore) =>
      pharmacyApiProvider.fetchCheckErrorDelivery(accessStore);

  Future<HttpResult> fetchMinSum() => pharmacyApiProvider.fetchMinSum();

  Future<HttpResult> fetchCheckVersion(String version) =>
      pharmacyApiProvider.fetchCheckVersion(version);

  Future<HttpResult> fetchSendRating(String comment, int rating) =>
      pharmacyApiProvider.fetchSendRating(comment, rating);

  Future<HttpResult> fetchOrderItemReview(
          String comment, int rating, int orderId) =>
      pharmacyApiProvider.fetchOrderItemReview(comment, rating, orderId);

  Future<HttpResult> fetchGetNoReview() =>
      pharmacyApiProvider.fetchGetNoReviews();

  Future<HttpResult> fetchCashBack() => pharmacyApiProvider.fetchCashBack();

  Future<HttpResult> fetchFAQ() => pharmacyApiProvider.fetchFAQ();

  Future<HttpResult> fetchGetRegion(String location) =>
      pharmacyApiProvider.fetchGetRegion(location);

  Future<HttpResult> fetchLocationAddress(double lat, double lng) =>
      pharmacyApiProvider.fetchLocationAddress(lat, lng);
}
