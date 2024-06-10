
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pharmacy/src/blocs/faq_bloc.dart';
import 'package:pharmacy/src/model/api/faq_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../static/app_colors.dart';

class FaqAppScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FaqAppScreenState();
  }
}

class _FaqAppScreenState extends State<FaqAppScreen> {
  @override
  void initState() {
    blocFaq.fetchAllFaq();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
              translate("menu.qus_title"),
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
        stream: blocFaq.allFaq,
        builder: (context, AsyncSnapshot<List<FaqModel>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              padding: EdgeInsets.only(bottom: 24, top: 24),
              itemBuilder: (BuildContext ctxt, int index) {
                return Container(
                  margin: EdgeInsets.only(
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                        child: Text(
                          snapshot.data![index].question,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.text_dark,
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: AppColors.background,
                        margin: EdgeInsets.symmetric(vertical: 8),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Text(
                          snapshot.data![index].answer,
                          style: TextStyle(
                            fontFamily: AppColors.fontRubik,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: 10,
              itemBuilder: (_, __) => Container(
                height: 120,
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  color: AppColors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
