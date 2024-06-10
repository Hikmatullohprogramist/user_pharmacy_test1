import 'package:pharmacy/src/model/api/cash_back_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:rxdart/rxdart.dart';

class MenuBloc {
  final _repository = Repository();
  final _cashBackFetcher = PublishSubject<CashBackModel>();
  final _visibleFetcher = PublishSubject<bool>();

  Stream<CashBackModel> get cashBackOptions => _cashBackFetcher.stream;

  Stream<bool> get visibleOptions => _visibleFetcher.stream;

  fetchCashBack() async {
    var response = await _repository.fetchCashBack();
    if (response.isSuccess) {
      _cashBackFetcher.sink.add(CashBackModel.fromJson(response.result));
    }
  }

  fetchVisible(int star, String text) {
    if (star > 0 || text.length > 0) {
      _visibleFetcher.sink.add(true);
    } else {
      _visibleFetcher.sink.add(false);
    }
  }

  dispose() {
    _cashBackFetcher.close();
    _visibleFetcher.close();
  }
}

final menuBack = MenuBloc();
