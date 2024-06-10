import 'package:flutter/material.dart';
import 'package:pharmacy/src/static/app_colors.dart';
import 'package:pharmacy/src/model/api/region_model.dart';
import 'package:pharmacy/src/widget/accardion/expanded_section.dart';

class Accordion extends StatefulWidget {
  final bool position;
  final String title;
  final List<RegionModel> childs;
  final int data;
  final Function(RegionModel data) onChoose;

  Accordion({
    required this.position,
    required this.title,
    required this.childs,
    required this.data,
    required this.onChoose,
  });

  @override
  _AccordionState createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  bool _showContent = false;
  var duration = Duration(milliseconds: 270);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showContent = !_showContent;
            });
          },
          child: Container(
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(
                    (!_showContent && widget.position) ? 24 : 0),
                bottomRight: Radius.circular(
                    (!_showContent && widget.position) ? 24 : 0),
              ),
            ),
            padding: EdgeInsets.only(
              top: 16,
              bottom: (!_showContent && widget.position) ? 24 : 16,
              left: 16,
              right: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: AppColors.fontRubik,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        height: 1.2,
                        color: AppColors.text_dark,
                      ),
                    ),
                  ),
                ),
                Icon(
                  _showContent
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.blue,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        ExpandedSection(
          child: Container(
            width: double.infinity,
            child: ListView.builder(
              itemCount: widget.childs.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, position) {
                return GestureDetector(
                  onTap: () async {
                    widget.onChoose(widget.childs[position]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(
                          (_showContent &&
                                  position == widget.childs.length - 1 &&
                                  widget.position)
                              ? 24
                              : 0,
                        ),
                        bottomLeft: Radius.circular(
                          (_showContent &&
                                  position == widget.childs.length - 1 &&
                                  widget.position)
                              ? 24
                              : 0,
                        ),
                      ),
                    ),
                    margin: EdgeInsets.only(
                      left: 16,
                      right: 16,
                    ),
                    padding: EdgeInsets.only(
                      top: 16,
                      bottom:
                          _showContent && position == widget.childs.length - 1
                              ? 28
                              : 16,
                      left: 40,
                      right: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.childs[position].name,
                            style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.normal,
                              fontFamily: AppColors.fontRubik,
                              fontSize: 15,
                              color: AppColors.text_dark,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        AnimatedContainer(
                          duration: duration,
                          curve: Curves.easeInOut,
                          height: 16,
                          width: 16,
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: widget.data == widget.childs[position].id
                                  ? AppColors.blue
                                  : AppColors.gray,
                            ),
                          ),
                          child: AnimatedContainer(
                            duration: duration,
                            curve: Curves.easeInOut,
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: widget.data == widget.childs[position].id
                                  ? AppColors.blue
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          expand: _showContent,
        ),
      ],
    );
  }
}
