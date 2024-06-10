import 'package:pharmacy/src/model/api/history_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:rxdart/rxdart.dart';

class HistoryBloc {
  final _repository = Repository();
  final _historyFetcher = PublishSubject<HistoryModel>();
  List<HistoryResults> data = <HistoryResults>[];

  Stream<HistoryModel> get allHistory => _historyFetcher.stream;

  fetchAllHistory(int page) async {
    var response = await _repository.fetchHistory(page);
    if (response.isSuccess) {
      var result = HistoryModel.fromJson(response.result);
      if (page == 1) data = <HistoryResults>[];
      data.addAll(result.results);
      _historyFetcher.sink.add(
        HistoryModel(
          next: result.next,
          results: data,
          count: 0,
        ),
      );
    } else if (response.status == -1) {
      RxBus.post(BottomView(true), tag: "HOME_VIEW_ERROR_HISTORY");
    }
  }

  dispose() {
    _historyFetcher.close();
  }
}

final blocHistory = HistoryBloc();
