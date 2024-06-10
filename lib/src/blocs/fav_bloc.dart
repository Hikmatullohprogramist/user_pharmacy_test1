import 'package:pharmacy/src/model/api/item_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:rxdart/rxdart.dart';

class FavBloc {
  final _repository = Repository();
  final _favFetcher = PublishSubject<List<ItemResult>>();

  Stream<List<ItemResult>> get allFav => _favFetcher.stream;

  fetchAllFav() async {
    List<ItemResult> result = await _repository.databaseFavItem();
    List<ItemResult> resultCard = await _repository.databaseCardItem(true);
    for (int i = 0; i < result.length; i++) {
      for (int j = 0; j < resultCard.length; j++) {
        if(result[i].id == resultCard[j].id){
          result[i].cardCount = resultCard[j].cardCount;
        }
      }
    }
    _favFetcher.sink.add(result);
  }

  dispose() {
    _favFetcher.close();
  }
}

final blocFav = FavBloc();
