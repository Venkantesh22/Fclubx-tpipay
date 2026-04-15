import 'package:flutter/material.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/main.dart';
import 'package:frezka/screens/dashboard/models/slider_data.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../booking/view/booking_screen.dart';
import '../../services/models/service_response.dart';

class PopularItemComponent extends StatelessWidget {
  final double? width;
  final PopularServices popularService;

  PopularItemComponent({this.width, required this.popularService});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          BookingScreen(services: [ServiceListData(id: popularService.id, name: popularService.name, defaultPrice: popularService.defaultPrice)]).launch(context);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.zero,
          width: 180,
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image at the top
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: CachedImageWidget(
                  url: popularService.serviceImage.validate(),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Details below
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      popularService.name.validate(),
                      style: primaryTextStyle(size: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.height,
                    Text(
                      '${popularService.durationMin} min',
                      style: secondaryTextStyle(),
                    ),
                    4.height,
                    PriceWidget(price: popularService.defaultPrice),
                    8.height,
                    AppButton(
                      text: locale.bookNow,
                      width: double.infinity,
                      padding: EdgeInsets.zero,
                      color: context.primaryColor,
                      textStyle: primaryTextStyle(color: Colors.white),
                      onTap: () {
                        BookingScreen(services: [
                          ServiceListData(
                              id: popularService.id,
                              name: popularService.name,
                              defaultPrice: popularService.defaultPrice,
                              durationMin: popularService.durationMin,
                              serviceImage: popularService.serviceImage)
                        ]).launch(context);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
