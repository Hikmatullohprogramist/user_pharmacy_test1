import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pharmacy/src/static/app_colors.dart';
import 'package:pharmacy/src/model/api/location_model.dart';
import 'package:pharmacy/src/model/send/access_store.dart';
import 'package:pharmacy/src/ui/shopping_pickup/address/item/address_apteka_list_pickup.dart';
import 'package:pharmacy/src/ui/shopping_pickup/address/item/address_apteka_map_pickup.dart';

class ChooseStoreScreen extends StatefulWidget {
  final List<ProductsStore> drugs;
  final Function(LocationModel store) chooseStore;

  const ChooseStoreScreen({
    Key? key,
    required this.drugs,
    required this.chooseStore,
  }) : super(key: key);

  @override
  State<ChooseStoreScreen> createState() => _ChooseStoreScreenState();
}

class _ChooseStoreScreenState extends State<ChooseStoreScreen> {
  PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
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
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (currentIndex != 0) {
                        setState(() {
                          currentIndex = 0;
                          _pageController.jumpToPage(currentIndex);
                        });
                      }
                    },
                    child: Container(
                      color: AppColors.white,
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                translate("card.map"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: currentIndex == 0
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.2,
                                  color: currentIndex == 0
                                      ? AppColors.text_dark
                                      : AppColors.textGray,
                                ),
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 270),
                            curve: Curves.easeInOut,
                            height: currentIndex == 0 ? 2 : 1,
                            width: double.infinity,
                            color: currentIndex == 0
                                ? AppColors.blue
                                : AppColors.background,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (currentIndex != 1) {
                        setState(() {
                          currentIndex = 1;
                          _pageController.jumpToPage(currentIndex);
                        });
                      }
                    },
                    child: Container(
                      color: AppColors.white,
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                translate("card.list"),
                                style: TextStyle(
                                  fontFamily: AppColors.fontRubik,
                                  fontWeight: currentIndex == 1
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.2,
                                  color: currentIndex == 1
                                      ? AppColors.text_dark
                                      : AppColors.textGray,
                                ),
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 270),
                            curve: Curves.easeInOut,
                            height: currentIndex == 1 ? 2 : 1,
                            width: double.infinity,
                            color: currentIndex == 1
                                ? AppColors.blue
                                : AppColors.background,
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.all(16),
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  pageSnapping: false,
                  onPageChanged: (int page) {
                    setState(() {
                      currentIndex = page;
                    });
                  },
                  controller: _pageController,
                  children: <Widget>[
                    AddressStoreMapPickupScreen(
                      widget.drugs,
                      (value) {
                        Navigator.pop(context);
                        widget.chooseStore(value);
                      },
                    ),
                    AddressStoreListPickupScreen(
                      widget.drugs,
                      (value) {
                        Navigator.pop(context);
                        widget.chooseStore(value);
                      },
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
