import 'package:pharmacy/src/model/api/category_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc {
  final _repository = Repository();
  final _categoryFetcher = PublishSubject<CategoryModel>();

  Stream<CategoryModel> get allCategory => _categoryFetcher.stream;

  fetchAllCategory() async {
    var response = await _repository.fetchCategoryItem();
    if (response.isSuccess) {
      _categoryFetcher.sink.add(CategoryModel.fromJson(response.result));
    }
  }

  dispose() {
    _categoryFetcher.close();
  }
}

final blocCategory = CategoryBloc();
