import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:rxdart/rxdart.dart';

class CardBloc {
  final _repository = Repository();
  final _cardFetcher = PublishSubject<List<ItemResult>>();

  Stream<List<ItemResult>> get allCard => _cardFetcher.stream;

  fetchAllCard() async {
    List<ItemResult> result = await _repository.databaseCardItem(true);
    _cardFetcher.sink.add(result);
  }

  dispose() {
    _cardFetcher.close();
  }
}

final blocCard = CardBloc();
