import 'package:flutter/material.dart';
import 'package:frezka/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../screens/booking/view/booking_screen.dart';
import '../utils/constants.dart';

PageController customStepperController = PageController(initialPage: 0);

class CustomStepper extends StatefulWidget {
  final List<CustomStep> stepsList;
  final Function(int)? onChange;

  CustomStepper({required this.stepsList, this.onChange});

  @override
  _CustomStepperState createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  int currentPage = 0;
  bool flag = false;

  @override
  void initState() {
    super.initState();
    customStepperController = PageController(initialPage: 0);

    LiveStream().on(LiveStreamKeyConst.LIVESTREAM_CHANGE_STEP, (p0) async {
      log(flag);
      if (!flag) {
        flag = true;
        currentPage = p0 as int;
        setState(() {});

        await 100.milliseconds.delay;
        flag = false;
        log(flag);
      }
    });
  }

  Widget buildStepDivider(int index) {
    return Container(
      height: 2,
      width: double.infinity,
      color: primaryColor,
    );
  }

  Widget buildStepCircle(int index) {
    bool isCompleted = index < currentPage;
    bool isCurrent = index == currentPage;
    bool isPending = index > currentPage;

    return Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isCurrent ? successColor : lightBorderColor,
        border: isPending ? Border.all(color: borderColor, width: 1) : null,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
            style: TextStyle(
            color: isCompleted || isCurrent ? Colors.white : appTextSecondaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildStepTitle(int index) {
    bool isCompleted = index < currentPage;
    bool isCurrent = index == currentPage;

    
    return Flexible(
      flex: 2,
      child: Text(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        widget.stepsList[index].title.validate(),
        textAlign: TextAlign.center,
        style: boldTextStyle(
          color: isCompleted || isCurrent ? black : appTextSecondaryColor,
          size: 12,
        ),
      ),
    );
  }

  Widget _buildStepper(int currentStep) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stepper
          Container(
            height: 30,
            child: Stack(
              children: [
                // Background connecting line
                Positioned(
                  top: 15,
                  left: 20,
                  right: 20,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 2,
                    decoration: BoxDecoration(color: context.primaryColor, borderRadius: BorderRadius.circular(1)),
                  ),
                ),
                // Step circles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    widget.stepsList.length,
                    (index) => buildStepCircle(index),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // Step titles
          Container(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.stepsList.length, (index) => buildStepTitle(index)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    LiveStream().dispose(LiveStreamKeyConst.LIVESTREAM_CHANGE_STEP);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: customStepperController,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.stepsList.length,
          itemBuilder: (context, index) => widget.stepsList[index].page,
          onPageChanged: (index) {
            setState(
              () {
                currentPage = index;
                widget.onChange?.call(index);
              },
            );
          },
        ).paddingTop(120),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: context.width(),
                height: 130,
                child: appBarWidget(
                  locale.booking,
                  center: true,
                  color: context.primaryColor,
                  textColor: white,
                ).cornerRadiusWithClipRRectOnly(bottomLeft: 20, bottomRight: 20),
              ),
              Positioned(
                bottom: -48,
                left: 18,
                right: 18,
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: indicatorColor,
                        borderRadius: radius(4),
                      ),
                      child: _buildStepper(currentPage),
                    ),
                    Container(
                      height: 1,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
