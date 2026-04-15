import 'package:flutter/material.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../dashboard/component/popular_item_component.dart';
import '../../dashboard/models/slider_data.dart';

class PopularServiceScreen extends StatelessWidget {
  final List<PopularServices> popularServices;

  const PopularServiceScreen({super.key, required this.popularServices});

  @override
  Widget build(BuildContext context) {
    double itemWidth = (context.width() - 16 * 2 - 12) / 2;
    // screen width - horizontal padding - spacing, then divide by 2

    return AppScaffold(
      appBarWidget: commonAppBarWidget(
        context,
        title: locale.popularServices,
        appBarHeight: 70,
        roundCornerShape: true,
        showLeadingIcon: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: popularServices.map((service) {
            return SizedBox(
              width: itemWidth,
              child: PopularItemComponent(
                width: itemWidth,
                popularService: service,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
