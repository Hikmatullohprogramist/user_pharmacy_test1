import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_alice/core/alice_http_extensions.dart';
import 'package:http/http.dart' as http;
import 'package:pharmacy/main.dart';
import 'package:pharmacy/src/model/http_result.dart';
import 'package:pharmacy/src/model/send/access_store.dart';
import 'package:pharmacy/src/model/send/create_order_model.dart';
import 'package:pharmacy/src/model/send/create_payment_model.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PharmacyApiProvider {
  HttpClient httpClient = new HttpClient();

  static Duration durationTimeout = new Duration(seconds: 30);

  static Future<HttpResult> postRequest(url, body) async {
    final dynamic headers = await _getReqHeader();
    print(url);
    try {
      http.Response response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(durationTimeout)
          .interceptWithAlice(alice);

      print(response.body);
      return _result(response);
    } on TimeoutException catch (_) {
      return HttpResult(
        isSuccess: false,
        status: -1,
        result: null,
      );
    } on SocketException catch (_) {
      return HttpResult(
        isSuccess: false,
        status: -1,
        result: null,
      );
    }
  }

  static Future<HttpResult> getRequest(url) async {
    final dynamic headers = await _getReqHeader();
    try {
      print(url);
      http.Response response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(durationTimeout)
          .interceptWithAlice(
            alice,
          );

      ;
      print(response.body);
      return _result(response);
    } on TimeoutException catch (_) {
      return HttpResult(
        isSuccess: false,
        status: -1,
        result: null,
      );
    } on SocketException catch (_) {
      return HttpResult(
        isSuccess: false,
        status: -1,
        result: null,
      );
    }
  }

  static HttpResult _result(response) {
    var result;
    int status = response.statusCode ?? 404;
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      result = json.decode(utf8.decode(response.bodyBytes));
      return HttpResult(
        isSuccess: true,
        status: status,
        result: result,
      );
    } else {
      return HttpResult(
        isSuccess: false,
        status: status,
        result: null,
      );
    }
  }

  static _getReqHeader() async {
    final prefs = await SharedPreferences.getInstance();
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = prefs.getString("deviceData") != null
        ? stringToBase64.encode(prefs.getString("deviceData") ?? "")
        : "";

    if (prefs.getString('token') == null) {
      return {
        "Accept": "application/json",
        'content-type': 'application/json; charset=utf-8',
        'X-Device': encoded,
      };
    } else {
      return {
        "Accept": "application/json",
        'content-type': 'application/json; charset=utf-8',
        'X-Device': encoded,
        "Authorization": "Bearer " + (prefs.getString('token') ?? "")
      };
    }
  }

  ///Login
  Future<HttpResult> fetchLogin(String login) async {
    String url = Utils.baseUrl + '/api/v1/register';
    final data = {
      "login": login,
    };
    return await postRequest(url, json.encode(data));
  }

  Future<HttpResult> fetchLoginCaptcha(
    String login,
    String captchaKey,
    String captchaValue,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String language = prefs.getString('language') ?? "ru";
    String url = Utils.baseUrl + '/api/v1/register-captcha?lan=$language';
    final data = {
      "login": login,
      "captcha_key": captchaKey,
      "captcha_value": captchaValue,
    };
    return await postRequest(url, json.encode(data));
  }

  ///get captcha
  Future<HttpResult> fetchGetCaptcha() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String language = prefs.getString('language') ?? "ru";
    String url = Utils.baseUrl + '/api/v1/captcha?lan=$language';
    return await postRequest(url, json.encode({}));
  }

  ///verify
  Future<HttpResult> fetchVerify(
    String login,
    String code,
    String token,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String language = prefs.getString('language') ?? "ru";

    String url = Utils.baseUrl + '/api/v1/accept?lan=$language';

    final data = {
      "login": login,
      "smscode": code,
      "device_token": token,
    };
    return await postRequest(url, json.encode(data));
  }

  ///Register
  Future<HttpResult> fetchRegister(
    String name,
    String surname,
    String birthday,
    String gender,
    String token,
    String fctoken,
  ) async {
    String url = Utils.baseUrl + '/api/v1/register-profil';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = prefs.getString("deviceData") != null
        ? stringToBase64.encode(prefs.getString("deviceData") ?? "")
        : "";

    final data = {
      "first_name": name,
      "last_name": surname,
      "gender": gender,
      "birth_date": birthday,
      "fctoken": fctoken,
      "region": regionId.toString(),
    };

    final dynamic headers = {
      "Accept": "application/json",
      'X-Device': encoded,
      "Authorization": "Bearer " + token
    };
    print(url);
    try {
      http.Response response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: data,
          )
          .timeout(durationTimeout);
      print(response.body);
      return _result(response);
    } on TimeoutException catch (_) {
      return HttpResult(
        isSuccess: false,
        status: -1,
        result: null,
      );
    } on SocketException catch (_) {
      return HttpResult(
        isSuccess: false,
        status: -1,
        result: null,
      );
    }
  }

  ///Banner
  Future<HttpResult> fetchBanner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl + '/api/v1/sales?region=$regionId';

    return await getRequest(url);
  }

  ///Blog
  Future<HttpResult> fetchBlog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";
    String language = prefs.getString('language') ?? "ru";

    String url = Utils.baseUrl +
        '/api/v1/pages?choice=blog&region=$regionId&lan=$language';

    return await getRequest(url);
  }

  ///CashBack title
  Future<HttpResult> fetchCashBackTitle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";
    String language = prefs.getString('language') ?? "ru";

    String url = Utils.baseUrl +
        '/api/v1/pages?choice=cashback&region=$regionId&lan=$language';

    return await getRequest(url);
  }

  ///best items
  Future<HttpResult> fetchBestItemList(
    int page,
    int perPage,
    String ordering,
    String priceMax,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl +
        '/api/v1/drugs?'
            'is_home=1&'
            'page=$page&'
            'region=$regionId&'
            'per_page=$perPage&'
            'ordering=$ordering&'
            'price_max=$priceMax';
    return await getRequest(url);
  }

  ///recently
  Future<HttpResult> fetchRecently(
    String ordering,
    String priceMax,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl +
        '/api/v1/drugs/latest/?'
            'region=$regionId&'
            'ordering=$ordering&'
            'price_max=$priceMax';

    return await getRequest(url);
  }

  ///Top category
  Future<HttpResult> fetchTopCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";
    String url =
        Utils.baseUrl + '/api/v1/categories?popular=true&region=$regionId';
    return await getRequest(url);
  }

  ///slimming
  Future<HttpResult> fetchSlimming() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";
    String language = prefs.getString('language') ?? "ru";
    String url = Utils.baseUrl +
        '/api/v1/drugs/collections?region=$regionId&lan=$language';
    return await getRequest(url);
  }

  ///category
  Future<HttpResult> fetchCategoryList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl + '/api/v1/categories?region=$regionId';

    return await getRequest(url);
  }

  ///category's by item
  Future<HttpResult> fetchCategoryItemsList(
    String id,
    int page,
    int perPage,
    String ordering,
    String priceMax,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl +
        '/api/v1/drugs?'
            'page=$page&'
            'region=$regionId&'
            'per_page=$perPage&'
            'category=$id&'
            'ordering=$ordering&'
            'price_max=$priceMax';

    return await getRequest(url);
  }

  ///ids's by item
  Future<HttpResult> fetchIdsItemsList(
    String id,
    int page,
    int perPage,
    String ordering,
    String priceMax,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl +
        '/api/v1/drugs?'
            'page=$page&'
            'region=$regionId&'
            'per_page=$perPage&'
            'ids=$id&'
            'ordering=$ordering&'
            'price_max=$priceMax';

    return await getRequest(url);
  }

  ///search's by item
  Future<HttpResult> fetchSearchItemsList(
    String obj,
    int page,
    int perPage,
    String ordering,
    String priceMax,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String search = "search=$obj";

    String url = Utils.baseUrl +
        '/api/v1/drugs?'
            'page=$page&'
            'region=$regionId&'
            'per_page=$perPage&'
            '$search&'
            'ordering=$ordering&'
            'price_max=$priceMax';
    return await getRequest(url);
  }

  ///items
  Future<HttpResult> fetchItems(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl + '/api/v1/drugs/$id?region=$regionId';

    return await getRequest(url);
  }

  ///All message
  Future<HttpResult> fetchAllMessage(int page) async {
    String url = Utils.baseUrl + '/api/v1/chat/messages?page=$page&per_page=20';
    return await getRequest(url);
  }

  ///Send message
  Future<HttpResult> fetchSendMessage(String message) async {
    String url = Utils.baseUrl + '/api/v1/chat/send-message';
    final data = {
      "message": message,
    };
    return await postRequest(url, json.encode(data));
  }

  ///regions
  Future<HttpResult> fetchRegions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lan = prefs.getString('language') ?? "ru";
    String url = Utils.baseUrl + '/api/v1/regions?lan=$lan';
    return await getRequest(url);
  }

  ///History
  Future<HttpResult> fetchOrderHistory(int page, int perPage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";
    String lan = prefs.getString('language') ?? "ru";
    String url = Utils.baseUrl +
        '/api/v1/orders?'
            'page=$page&'
            'per_page=$perPage&'
            'lan=$lan&'
            'region=$regionId';
    return await getRequest(url);
  }

  ///Cancel order
  Future<HttpResult> fetchCancelOrder(int orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";
    String lan = prefs.getString('language') ?? "ru";
    String url = Utils.baseUrl +
        '/api/v1/order-cancel?'
            'lan=$lan&'
            'region=$regionId';

    final data = {
      "order": orderId.toString(),
    };
    return await postRequest(url, json.encode(data));
  }

  /// Order options
  Future<HttpResult> fetchOrderOptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";
    String lan = prefs.getString('language') ?? "ru";

    String url = Utils.baseUrl +
        '/api/v1/order-options?lan=$lan&region=$regionId&new_payment=true';

    return await getRequest(url);
  }

  ///access store
  Future<HttpResult> fetchAccessStore(AccessStore accessStore) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl + '/api/v1/exists-stores?region=$regionId';
    return await postRequest(url, json.encode(accessStore));
  }

  ///Min sum
  Future<HttpResult> fetchMinSum() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl + '/api/v1/order-minimum?region=$regionId';

    return await getRequest(url);
  }

  ///Check error pickup
  Future<HttpResult> fetchCheckErrorPickup(
    AccessStore accessStore,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";
    String lan = prefs.getString("language") ?? "ru";

    String url =
        Utils.baseUrl + '/api/v1/check-error?lan=$lan&region=$regionId';

    return await postRequest(url, json.encode(accessStore));
  }

  ///Check error delivery
  Future<HttpResult> fetchCheckErrorDelivery(AccessStore accessStore) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";
    String lan = prefs.getString("language") ?? "ru";

    String url = Utils.baseUrl +
        '/api/v1/check-shipping-error?lan=$lan&region=$regionId';

    return await postRequest(url, json.encode(accessStore));
  }

  ///check version
  Future<HttpResult> fetchCheckVersion(String version) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = {
      "version": version,
      "device": Platform.isIOS ? "ios" : "android"
    };
    String lan = prefs.getString('language') ?? "ru";
    String url = Utils.baseUrl + '/api/v1/check-version?lan=$lan';

    return await postRequest(url, json.encode(data));
  }

  ///send rating
  Future<HttpResult> fetchSendRating(String comment, int rating) async {
    String url = Utils.baseUrl + '/api/v1/send-review';
    final data = {
      "comment": comment,
      "rating": rating.toString(),
    };
    return await postRequest(url, json.encode(data));
  }

  ///get-no-reviews
  Future<HttpResult> fetchGetNoReviews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl + '/api/v1/get-no-reviews?region=$regionId';
    return await getRequest(url);
  }

  ///order item review
  Future<HttpResult> fetchOrderItemReview(
    String comment,
    int rating,
    int orderId,
  ) async {
    String url = Utils.baseUrl + '/api/v1/send-order-reviews';

    final data = {
      "review": comment,
      "rating": rating.toString(),
      "order_id": orderId.toString(),
    };

    return await postRequest(url, json.encode(data));
  }

  /// Cash back
  Future<HttpResult> fetchCashBack() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl + '/api/v1/user-cashback?region=$regionId';

    return await getRequest(url);
  }

  /// FAQ
  Future<HttpResult> fetchFAQ() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lan = prefs.getString('language') ?? "ru";
    var regionId = prefs.getInt("cityId") ?? "";

    String url = Utils.baseUrl + '/api/v1/faq?lan=$lan&region=$regionId';
    return await getRequest(url);
  }

  ///create order
  Future<HttpResult> fetchCreateOrder(CreateOrderModel order) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lan = prefs.getString('language') ?? "ru";
    var regionId = prefs.getInt("cityId") ?? "";

    String url =
        Utils.baseUrl + '/api/v1/create-order?lan=$lan&region=$regionId';

    return await postRequest(url, json.encode(order));
  }

  ///check order
  Future<HttpResult> fetchCheckOrder(CreateOrderModel order) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lan = prefs.getString('language') ?? "ru";
    var regionId = prefs.getInt("cityId") ?? "";

    String url =
        Utils.baseUrl + '/api/v1/check-order?lan=$lan&region=$regionId';

    return await postRequest(url, json.encode(order));
  }

  ///Payment
  Future<HttpResult> fetchPayment(PaymentOrderModel order) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lan = prefs.getString('language') ?? "ru";
    var regionId = prefs.getInt("cityId") ?? "";

    String url =
        Utils.baseUrl + '/api/v1/activate-order?lan=$lan&region=$regionId';

    return await postRequest(url, json.encode(order));
  }

  ///set location to region
  Future<HttpResult> fetchGetRegion(String location) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lan = prefs.getString('language') ?? "ru";

    final data = {
      "location": location,
    };
    String url = Utils.baseUrl + '/api/v1/check-region-polygon?lan=$lan';
    return await postRequest(url, json.encode(data));
  }

  ///set location to address
  Future<HttpResult> fetchLocationAddress(double lat, double lng) async {
    String url =
        "https://geocode-maps.yandex.ru/1.x/?apikey=b4985736-e176-472f-af14-36678b5d6aaa&geocode=$lng,$lat&format=json";
    return await getRequest(url);
  }
}
