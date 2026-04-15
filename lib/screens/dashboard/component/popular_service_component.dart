import 'package:flutter/material.dart';
import 'package:frezka/screens/booking/component/quick_book_component.dart';
import 'package:frezka/screens/dashboard/component/popular_item_component.dart';
import 'package:frezka/screens/dashboard/models/slider_data.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/view_all_label_component.dart';
import '../../../main.dart';
import '../../popularService/view/popular_service_screen.dart';

class PopularServiceComponent extends StatefulWidget {
  final List<PopularServices>? popularServices;

  const PopularServiceComponent({super.key, this.popularServices});

  @override
  State<PopularServiceComponent> createState() => _PopularServiceComponentState();
}

class _PopularServiceComponentState extends State<PopularServiceComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    // Future data fetching or setup if needed
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.popularServices.validate().isEmpty) return Offstage();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: locale.popularServices,
          list: widget.popularServices,
          onTap: () {
            PopularServiceScreen(
              popularServices: widget.popularServices.validate(),
            ).launch(context).then((value) {
              setStatusBarColor(Colors.transparent);
            });
          },
        ).paddingSymmetric(horizontal: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.popularServices.validate().take(6).map((data) {
              return GestureDetector(
                onTap: () {
                  onQuickBookingDataUpdate?.call(); 
                  bookingRequestStore.setCouponApplied(false);
                },
                child: PopularItemComponent(popularService: data),
              ).paddingRight(16);
            }).toList(),
          ),
        )
      ],
    );
  }
}
