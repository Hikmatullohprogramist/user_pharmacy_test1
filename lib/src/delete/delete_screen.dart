import 'package:flutter/material.dart';
import 'package:pharmacy/src/static/app_colors.dart';

class MyAppDelete extends StatefulWidget {
  @override
  _MyAppDeleteState createState() => _MyAppDeleteState();
}

class _MyAppDeleteState extends State<MyAppDelete> {
  double _sliderDiscreteValue = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                  trackHeight: 3,
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  activeTrackColor: AppColors.blue,
                  inactiveTrackColor: AppColors.gray,
                  overlayColor: AppColors.blue.withOpacity(0.1),
                  thumbColor: AppColors.blue),
              child: Slider(
                value: _sliderDiscreteValue,
                min: 0,
                max: 1000000,
                onChanged: (value) {
                  setState(() {
                    _sliderDiscreteValue = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
