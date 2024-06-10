import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pharmacy/src/static/app_colors.dart';

class FavoriteButton extends StatefulWidget {
  FavoriteButton({
    required bool isFavorite,
    required Function valueChanged,
    Key? key,
  })  : _isFavorite = isFavorite,
        _valueChanged = valueChanged,
        super(key: key);

  final bool _isFavorite;
  final Function _valueChanged;

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _sizeAnimation;

  CurvedAnimation? _curve;

  double _maxIconSize = 0.0;
  double _minIconSize = 0.0;

  final int _animationTime = 400;

  bool _isFavorite = false;
  bool _isAnimationCompleted = false;

  @override
  void initState() {
    super.initState();

    _isFavorite = widget._isFavorite;
    _maxIconSize = 32;
    final double _sizeDifference = _maxIconSize * 0.25;
    _minIconSize = _maxIconSize - _sizeDifference;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _animationTime),
    );

    _curve = CurvedAnimation(curve: Curves.slowMiddle, parent: _controller!);

    _sizeAnimation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: _minIconSize,
            end: _maxIconSize,
          ),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: _maxIconSize,
            end: _minIconSize,
          ),
          weight: 50,
        ),
      ],
    ).animate(_curve!);

    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimationCompleted = true;
        _isFavorite = !_isFavorite;
        widget._valueChanged(_isFavorite);
      } else if (status == AnimationStatus.dismissed) {
        _isAnimationCompleted = false;
        _isFavorite = !_isFavorite;
        widget._valueChanged(_isFavorite);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller!,
      builder: (BuildContext context, _) {
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_isAnimationCompleted == true) {
                _controller!.reverse();
              } else {
                _controller!.forward();
              }
            });
          },
          child: AnimatedContainer(
            duration: Duration(microseconds: 270),
            curve: Curves.easeInOut,
            height: _sizeAnimation!.value,
            width: _sizeAnimation!.value,
            color: AppColors.white,
            child: _isFavorite
                ? SvgPicture.asset("assets/icons/fav_select.svg")
                : SvgPicture.asset("assets/icons/fav_unselect.svg"),
          ),
        );
      },
    );
  }
}
