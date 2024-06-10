import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pharmacy/src/blocs/home_bloc.dart';
import 'package:pharmacy/src/model/api/blog_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/ui/item/blog_item_screen.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:pharmacy/src/utils/utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../static/app_colors.dart';

class BlogListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BlogListScreenState();
  }
}

class _BlogListScreenState extends State<BlogListScreen> {
  int page = 1;
  bool isLoading = false;
  ScrollController _sc = new ScrollController();

  @override
  void initState() {
    super.initState();
    _registerBus();
    _getMoreData(1);
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page);
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    RxBus.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4.0,
        shadowColor: Color.fromRGBO(110, 120, 146, 0.1),
        backgroundColor: AppColors.white,
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
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              translate("home.articles"),
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
        stream: blocHome.blog,
        builder: (context, AsyncSnapshot<BlogModel> snapshot) {
          if (snapshot.hasData) {
            snapshot.data!.next == "" ? isLoading = true : isLoading = false;
            return ListView.builder(
              padding: EdgeInsets.only(bottom: 24),
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data!.results.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlogItemScreen(
                          image: snapshot.data!.results[index].image,
                          dateTime: snapshot.data!.results[index].updatedAt,
                          title: snapshot.data!.results[index].title,
                          message: snapshot.data!.results[index].body,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 246,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: EdgeInsets.only(
                      right: 16,
                      left: 16,
                      top: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data!.results[index].image,
                              placeholder: (context, url) => Image.asset(
                                "assets/img/default.png",
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/img/default.png",
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            Utils.dateFormat(
                                snapshot.data!.results[index].updatedAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                              height: 1.2,
                              color: AppColors.textGray,
                            ),
                          ),
                          margin: EdgeInsets.only(
                            bottom: 8,
                            top: 8,
                            left: 16,
                            right: 16,
                          ),
                        ),
                        Container(
                          child: Text(
                            snapshot.data!.results[index].title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              height: 1.6,
                              color: AppColors.text_dark,
                            ),
                          ),
                          margin: EdgeInsets.only(
                            bottom: 16,
                            left: 16,
                            right: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Container(
                  height: 246,
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _registerBus() {
    RxBus.register<BottomView>(tag: "LIST_VIEW_ERROR_NETWORK").listen(
      (event) {
        /// network error
      },
    );
  }

  void _getMoreData(int index) async {
    if (!isLoading) {
      blocHome.fetchBlog(page);
      page++;
    }
  }
}
