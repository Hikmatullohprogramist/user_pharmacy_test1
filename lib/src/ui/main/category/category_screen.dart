import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pharmacy/src/blocs/category_bloc.dart';
import 'package:pharmacy/src/model/api/category_model.dart';
import 'package:pharmacy/src/model/eventBus/bottom_view.dart';
import 'package:pharmacy/src/ui/main/category/sub_category_screen.dart';
import 'package:pharmacy/src/utils/bus/rx_bus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../static/app_colors.dart';

class CategoryScreen extends StatefulWidget {
  final Function({
    required String name,
    required int type,
    required String id,
  }) onListItem;

  CategoryScreen({required this.onListItem});

  @override
  State<StatefulWidget> createState() {
    return _CategoryScreenState();
  }
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    blocCategory.fetchAllCategory();
    _registerBus();
    super.initState();
  }

  @override
  void dispose() {
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
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              translate("category.title"),
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
        stream: blocCategory.allCategory,
        builder: (context, AsyncSnapshot<CategoryModel> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.results.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (snapshot.data!.results[index].childs.length > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubCategoryScreen(
                            snapshot.data!.results[index].name,
                            snapshot.data!.results[index].childs,
                            widget.onListItem,
                          ),
                        ),
                      );
                    } else {
                      widget.onListItem(
                        name: snapshot.data!.results[index].name,
                        type: 2,
                        id: snapshot.data!.results[index].id.toString(),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 16 : 8,
                      bottom:
                          index == snapshot.data!.results.length - 1 ? 16 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(index == 0 ? 24 : 0),
                        topLeft: Radius.circular(index == 0 ? 24 : 0),
                        bottomLeft: Radius.circular(
                          index == snapshot.data!.results.length - 1 ? 24 : 0,
                        ),
                        bottomRight: Radius.circular(
                          index == snapshot.data!.results.length - 1 ? 24 : 0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 16, right: 12),
                          color: AppColors.white,
                          width: 40,
                          height: 40,
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data!.results[index].image,
                            placeholder: (context, url) => SvgPicture.asset(
                              "assets/icons/default_image.svg",
                            ),
                            errorWidget: (context, url, error) =>
                                SvgPicture.asset(
                              "assets/icons/default_image.svg",
                            ),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            snapshot.data!.results[index].name,
                            style: TextStyle(
                              fontFamily: AppColors.fontRubik,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                              height: 1.37,
                              color: AppColors.text_dark,
                            ),
                          ),
                        ),
                        SvgPicture.asset(
                          "assets/icons/arrow_right_grey.svg",
                        ),
                        SizedBox(width: 16),
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
            child: Container(
              height: 575,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              margin: EdgeInsets.all(16),
            ),
          );
        },
      ),
    );
  }

  void _registerBus() {
    RxBus.register<BottomView>(tag: "CATEGORY_VIEW").listen((event) {
      if (event.title) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }
}
