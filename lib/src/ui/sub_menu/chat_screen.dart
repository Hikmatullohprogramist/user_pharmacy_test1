import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:pharmacy/src/blocs/chat_bloc.dart';
import 'package:pharmacy/src/model/api/all_message_model.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:web_socket_channel/io.dart';

import '../../../main.dart';
import '../../static/app_colors.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController listScrollController = ScrollController();
  TextEditingController chatController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  var channel = IOWebSocketChannel.connect(
    Uri.parse(
      "wss://api.gopharm.uz/ws/messages?token=$token",
    ),
  );
  int page = 1;
  int userId = 0;
  bool isLoading = false;
  bool isSendIcon = false;

  @override
  void initState() {
    _getMoreData();
    _getUserId();
    _listenSocket();
    listScrollController.addListener(() {
      if (listScrollController.position.pixels ==
          listScrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
    super.initState();
  }

  _ChatScreenState() {
    chatController.addListener(() {
      if (chatController.text.length > 0) {
        setState(() {
          isSendIcon = true;
        });
      } else {
        setState(() {
          isSendIcon = false;
        });
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  Random random = new Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: GestureDetector(
          child: Container(
            height: 56,
            width: 56,
            color: AppColors.white,
            padding: EdgeInsets.all(13),
            child: SvgPicture.asset("assets/icons/arrow_left_blue.svg"),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        elevation: 4.0,
        shadowColor: Color.fromRGBO(110, 120, 146, 0.1),
        backgroundColor: AppColors.white,

        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              translate("menu.chat"),
              style: TextStyle(
                fontFamily: AppColors.fontRubik,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.2,
                color: AppColors.text_dark,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: blocChat.allMessage,
        builder: (context, AsyncSnapshot<AllMessageModel> snapshot) {
          if (snapshot.hasData) {
            List<ChatResults> chatData = snapshot.data!.results;
            snapshot.data!.next == "" ? isLoading = true : isLoading = false;
            return Column(
              children: [
                Expanded(
                  child: chatData.length == 0
                      ? Center(
                          child: Lottie.asset(
                            "assets/anim/item_load_animation.json",
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          itemCount: chatData.length + 1,
                          reverse: true,
                          controller: listScrollController,
                          itemBuilder: (context, index) {
                            if (index == chatData.length) {
                              return Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: Opacity(
                                    opacity: isLoading ? 0.0 : 1.0,
                                    child: Container(
                                      height: 45,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Column(
                                crossAxisAlignment:
                                    chatData[index].userId == userId
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  index == chatData.length - 1
                                      ? Container(
                                          width: double.infinity,
                                          margin: EdgeInsets.only(bottom: 8),
                                          child: Center(
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                left: 12,
                                                right: 12,
                                                top: 8,
                                                bottom: 8,
                                              ),
                                              child: Text(
                                                Utils.dateFormat(
                                                    chatData[index].createdAt),
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontSize: 14,
                                                  height: 1.6,
                                                  color: Color(0xFF6E80B0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : chatData[index + 1].year !=
                                              chatData[index].year
                                          ? Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 8),
                                              width: double.infinity,
                                              child: Center(
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                    left: 12,
                                                    right: 12,
                                                    top: 8,
                                                    bottom: 8,
                                                  ),
                                                  child: Text(
                                                    Utils.dateFormat(
                                                        chatData[index]
                                                            .createdAt),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppColors.fontRubik,
                                                      fontSize: 14,
                                                      height: 1.6,
                                                      color: Color(0xFF6E80B0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                  chatData[index].userId == userId
                                      ? Container(
                                          margin: EdgeInsets.only(
                                            bottom: 16,
                                            left: 32,
                                          ),
                                          padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 12,
                                            right: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.blue,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(8),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                chatData[index].body,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  height: 1.4,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                Utils.format(chatData[index]
                                                        .createdAt
                                                        .hour) +
                                                    ":" +
                                                    Utils.format(chatData[index]
                                                        .createdAt
                                                        .minute),
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 10,
                                                  height: 1.2,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(
                                            bottom: 16,
                                            right: 32,
                                          ),
                                          padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 12,
                                            right: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF4F5F7),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                chatData[index].body,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  height: 1.4,
                                                  color: AppColors.text_dark,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                Utils.format(chatData[index]
                                                        .createdAt
                                                        .hour) +
                                                    ":" +
                                                    Utils.format(chatData[index]
                                                        .createdAt
                                                        .minute),
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppColors.fontRubik,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 10,
                                                  height: 1.2,
                                                  color: Color(0xFF6E80B0),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                ],
                              );
                            }
                          },
                        ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: Platform.isIOS ? 20 : 12,
                  ),
                  width: double.infinity,
                  color: AppColors.background,
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 48,
                          child: TextFormField(
                            controller: chatController,
                            autofocus: false,
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: AppColors.text_dark,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: translate("menu.chat_message"),
                              hintStyle: TextStyle(
                                fontFamily: AppColors.fontRubik,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Color(0xFF7C859F),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      isSendIcon
                          ? GestureDetector(
                              onTap: () {
                                if (chatController.text.isNotEmpty) {
                                  blocChat.fetchSendChat(
                                    chatController.text,
                                    userId,
                                  );
                                  chatController.clear();
                                }
                              },
                              child: SvgPicture.asset(
                                "assets/icons/send.svg",
                                height: 24,
                                width: 24,
                              ),
                            )
                          : Container(
                              height: 24,
                              width: 24,
                            ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              Expanded(
                child: Shimmer.fromColors(
                  child: ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                    ),
                    itemBuilder: (_, int index) => Align(
                      alignment: index % 2 == 0
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: index % 2 == 0
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: index % 2 == 0
                                ? EdgeInsets.only(
                                    left: 32,
                                    bottom: 16,
                                  )
                                : EdgeInsets.only(
                                    right: 32,
                                    bottom: 16,
                                  ),
                            decoration: BoxDecoration(
                              color:
                                  index % 2 == 0 ? Colors.blue : Colors.white,
                              borderRadius: index % 2 == 0
                                  ? BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                      bottomLeft: Radius.circular(8.0),
                                    )
                                  : BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                      bottomRight: Radius.circular(8.0),
                                    ),
                            ),
                            height: 32 + random.nextInt(105 - 64).toDouble(),
                          )
                        ],
                      ),
                    ),
                    itemCount: 20,
                  ),
                  baseColor: AppColors.shimmerBase,
                  highlightColor: AppColors.shimmerHighlight,
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: Platform.isIOS ? 20 : 12,
                ),
                width: double.infinity,
                color: AppColors.background,
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        child: TextFormField(
                          controller: chatController,
                          autofocus: false,
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: AppColors.text_dark,
                          ),
                          readOnly: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: translate("menu.chat_message"),
                            hintStyle: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              color: Color(0xFF7C859F),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    SvgPicture.asset("assets/icons/send.svg"),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _getMoreData() async {
    if (!isLoading) {
      blocChat.fetchAllChat(page);
      page++;
    }
  }

  void _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId') ?? 0;
    });
  }

  void _listenSocket() async {
    channel.stream.listen((message) {
      blocChat.fetchSocketChat(message);
    });
  }
}
