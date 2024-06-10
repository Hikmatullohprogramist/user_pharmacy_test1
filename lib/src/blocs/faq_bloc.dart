import 'dart:convert';

import 'package:pharmacy/src/model/api/faq_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:rxdart/rxdart.dart';

class FaqBloc {
  final _repository = Repository();
  final _faqFetcher = PublishSubject<List<FaqModel>>();

  Stream<List<FaqModel>> get allFaq => _faqFetcher.stream;

  fetchAllFaq() async {
    var response = await _repository.fetchFAQ();
    if (response.isSuccess) {
      _faqFetcher.sink.add(faqModelFromJson(json.encode(response.result)));
    }
  }

  dispose() {
    _faqFetcher.close();
  }
}

final blocFaq = FaqBloc();
