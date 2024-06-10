import 'dart:convert';

import 'package:pharmacy/src/model/api/all_message_model.dart';
import 'package:pharmacy/src/model/socket/socket_model.dart';
import 'package:pharmacy/src/resourses/repository.dart';
import 'package:rxdart/rxdart.dart';

class ChatBloc {
  final _repository = Repository();
  final _chatFetcher = PublishSubject<AllMessageModel>();

  Stream<AllMessageModel> get allMessage => _chatFetcher.stream;
  List<ChatResults> resultsData = [];
  String next = "";

  fetchAllChat(int page) async {
    var response = await _repository.fetchAllMessage(page);
    if (response.isSuccess) {
      AllMessageModel result = AllMessageModel.fromJson(
        response.result,
      );
      if (page == 1) {
        resultsData = [];
      }
      resultsData.addAll(result.results);
      next = result.next;
      _chatFetcher.sink.add(
        AllMessageModel(
          next: next,
          results: resultsData,
        ),
      );
    } else if (response.status == -1) {
      ///network
    } else {
      ///error
    }
  }

  fetchSendChat(String data, int id) async {
    resultsData.insert(
      0,
      ChatResults(
        userId: id,
        body: data,
        createdAt: DateTime.now(),
        year: DateTime.now().year.toString() +
            "." +
            DateTime.now().month.toString() +
            "." +
            DateTime.now().day.toString(),
        id: 0,
      ),
    );
    _chatFetcher.sink.add(
      AllMessageModel(
        next: next,
        results: resultsData,
      ),
    );
    await _repository.fetchSendMessage(data);
  }

  fetchSocketChat(String data) async {
    var sokcetData = SocketModel.fromJson(json.decode(data));
    resultsData.insert(
      0,
      ChatResults(
        userId: sokcetData.message.userId,
        body: sokcetData.message.body,
        createdAt: DateTime.now(),
        year: DateTime.now().year.toString() +
            "." +
            DateTime.now().month.toString() +
            "." +
            DateTime.now().day.toString(),
        id: 0,
      ),
    );
    _chatFetcher.sink.add(
      AllMessageModel(
        next: next,
        results: resultsData,
      ),
    );
  }

  dispose() {
    _chatFetcher.close();
  }
}

final blocChat = ChatBloc();
