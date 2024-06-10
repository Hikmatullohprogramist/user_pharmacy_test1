import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharmacy/src/model/api/category_model.dart';

import '../../../static/app_colors.dart';

class SubCategoryScreen extends StatefulWidget {
  final String name;
  final List<Childs> list;
  final Function({
    required String name,
    required int type,
    required String id,
  }) onListItem;

  SubCategoryScreen(this.name, this.list, this.onListItem);

  @override
  State<StatefulWidget> createState() {
    return _SubCategoryScreenState();
  }
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
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
              widget.name,
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
      body: ListView.builder(
        itemCount: widget.list.length,
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (widget.list[index].childs.length > 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubCategoryScreen(
                      widget.list[index].name,
                      widget.list[index].childs,
                      widget.onListItem,
                    ),
                  ),
                );
              } else {
                widget.onListItem(
                  name: widget.list[index].name,
                  type: 2,
                  id: widget.list[index].id.toString(),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.only(
                top: index == 0 ? 16 : 12,
                bottom: index == widget.list.length - 1 ? 16 : 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(index == 0 ? 24 : 0),
                  topLeft: Radius.circular(index == 0 ? 24 : 0),
                  bottomLeft: Radius.circular(
                    index == widget.list.length - 1 ? 24 : 0,
                  ),
                  bottomRight: Radius.circular(
                    index == widget.list.length - 1 ? 24 : 0,
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.list[index].name,
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
      ),
    );
  }
}
