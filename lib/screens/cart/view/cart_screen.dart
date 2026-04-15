import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frezka/components/app_scaffold.dart';
import 'package:frezka/components/cached_image_widget.dart';
import 'package:frezka/components/common_product_bottom_price_widget.dart';
import 'package:frezka/components/dotted_line.dart';
import 'package:frezka/components/loader_widget.dart';
import 'package:frezka/components/price_widget.dart';
import 'package:frezka/screens/cart/view/add_address_screen.dart';
import 'package:frezka/screens/cart/view/select_address_screen.dart';
import 'package:frezka/screens/order/view/order_summary_screen.dart';
import 'package:frezka/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../cart_repository.dart';
import '../component/cart_item_component.dart';
import '../model/address_list_response.dart';
import '../model/cart_list_response.dart';
import '../model/logistic_zone_response.dart';

late VoidCallback onCartListUpdate;

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<(List<CartListData>, CartListResponse)>? future;

  (List<CartListData>, CartListResponse) cartList = ([], CartListResponse());

  int page = 1;

  bool isLastPage = false;

  int itemCount = 0;

  // Address related variables
  List<UserAddress> addressList = [];
  List<LogisticZoneData> logisticList = [];
  bool isSelectedLogistic = false;

  @override
  void initState() {
    super.initState();
    init(flag: true);
    loadPrimaryAddress();

    onCartListUpdate = () {
      init(flag: true);
    };
  }

  void init({bool flag = false}) async {
    future = getCartList(
      page: page,
      cartList: cartList,
      lastPageCallBack: (p0) {
        isLastPage = p0;
      },
    ).whenComplete(() {
      if (flag) {
        setState(() {});
      }
    });
  }

  void loadPrimaryAddress() async {
    try {
      await getAddressList(
        page: 1,
        addressList: addressList,
        lastPageCallBack: (p0) {},
      ).then((addresses) async {
        if (addressList.isNotEmpty) {
          if (addressList.length == 1) {
            // If only one address, make it primary and select it
            UserAddress single = addressList.first;
            single.isPrimary = 1;
            await getLogisticZoneApi(addressId: single.id.validate());
            productStore.setSelectedAddressData(single);
          } else {
            // Find primary address or select first one
            UserAddress primaryAddress = addressList.firstWhere(
              (element) => element.isPrimary.validate().getBoolInt(),
              orElse: () => addressList.first,
            );
            await getLogisticZoneApi(addressId: primaryAddress.id.validate());
            productStore.setSelectedAddressData(primaryAddress);
          }
          setState(() {});
        } else {
          // Clear address data when no addresses exist
          productStore.setSelectedAddressData(UserAddress());
          setState(() {});
        }
      });
    } catch (e) {
      log('Error loading primary address: $e');
    }
  }

  Future<void> getLogisticZoneApi({required int addressId}) async {
    try {
      await getLogisticZone(addressId: addressId).then((value) async {
        logisticList.clear();
        logisticList.addAll(value);

        // Automatically select the first available logistic option
        if (logisticList.isNotEmpty) {
          logisticList.first.isLogisticCheck = true;
          isSelectedLogistic = true;
          productStore.setLogisticZoneData(logisticList.first);
        } else {
          isSelectedLogistic = false;
          productStore.setLogisticZoneData(LogisticZoneData());
        }

        setState(() {});
      });
    } catch (e) {
      log('Error loading logistic zone: $e');
    }
  }

  num _calculateAllItemsSubtotal() {
    num subtotal = 0;
    for (var item in cartList.$1) {
      final int quantity = item.qty.validate(value: 1);
      if (item.productVariation != null) {
        subtotal += item.productVariation!.discountedProductPrice.validate() * quantity;
      } else {
        final num unitWithTax = item.taxIncludeProductPrice.validate();
        final num unitBase = item.getProductPrice.validate();
        final num lineFromApi = item.productAmount.validate();
        subtotal += (lineFromApi != 0) ? lineFromApi : ((unitBase != 0 ? unitBase : unitWithTax) * quantity);
      }
    }
    return subtotal;
  }

  num _calculateAllItemsTax() {
    num subtotal = _calculateAllItemsSubtotal();

    num couponDiscount = 0;
    if (productStore.isCouponApplied) {
      if (productStore.isFixedDiscountCoupon) {
        couponDiscount = productStore.finalDiscountCouponAmount;
      } else {
        couponDiscount = subtotal * productStore.couponDiscountPercentage / 100;
        productStore.setFinalDiscountCouponAmount(couponDiscount);
      }
    }

    num discountedSubtotal = subtotal - couponDiscount;

    if (discountedSubtotal < 0) discountedSubtotal = 0;

    num totalTaxAmount = 0.0;

    if (cartList.$2.cartPriceData?.taxData?.taxDetails != null) {
      cartList.$2.cartPriceData!.taxData!.taxDetails!.forEach((ele) {
        if (ele.taxType == TaxType.PERCENT) {
          totalTaxAmount += discountedSubtotal * ele.taxValue.validate() / 100;
        } else {
          totalTaxAmount += ele.taxValue.validate();
        }
      });
    }

    return totalTaxAmount;
  }

  num _calculateAllItemsTotal() {
    num subtotal = _calculateAllItemsSubtotal();

    num couponDiscount = 0;
    if (productStore.isCouponApplied) {
      if (productStore.isFixedDiscountCoupon) {
        couponDiscount = productStore.finalDiscountCouponAmount;
      } else {
        couponDiscount = subtotal * productStore.couponDiscountPercentage / 100;
      }
    }

    num discountedSubtotal = subtotal - couponDiscount;
    if (discountedSubtotal < 0) discountedSubtotal = 0;

    num taxAmount = _calculateAllItemsTax();
    num deliveryCharge = productStore.logisticZoneData.standardDeliveryCharge.validate();

    return discountedSubtotal + taxAmount + deliveryCharge;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget _buildAddressSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.address,
                style: boldTextStyle(size: 14),
              ),
              Observer(builder: (context) {
                final addressId = productStore.addressData.id;
                if (addressId == null || addressId == 0) return SizedBox.shrink();

                return GestureDetector(
                  onTap: () async {
                    final result = await AddAddressScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                    if (result == true) {
                      loadPrimaryAddress();
                    }
                  },
                  child: Text(
                    locale.addNewAddress,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: context.primaryColor, offset: Offset(0, -2))],
                      color: Colors.transparent,
                      decoration: TextDecoration.underline,
                      decorationColor: context.primaryColor,
                      decorationThickness: 1,
                      decorationStyle: TextDecorationStyle.solid,
                    ),
                  ),
                );
              }),
            ],
          ),
          12.height,
          // Address Card
          _buildAddressCard(),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Observer(
      builder: (context) {
        final addressData = productStore.addressData;
        if (addressData.id == null || addressData.id == 0) {
          return Container(
            padding: EdgeInsets.all(8),
            decoration: boxDecorationDefault(
              color: context.cardColor,
              borderRadius: radius(8),
              border: Border.all(color: lightBorderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_off_outlined, color: primaryColor, size: 24),
                    12.width,
                    Expanded(
                      child: Text(
                        locale.noAddressAddedMessage,
                        style: primaryTextStyle(size: 14),
                      ),
                    ),
                  ],
                ),
                8.height,
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    height: 35,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    elevation: 0,
                    color: context.primaryColor,
                    child: Text(locale.addAddress, style: boldTextStyle(color: white)),
                    onTap: () async {
                      final result = await AddAddressScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                      if (result == true) {
                        loadPrimaryAddress();
                      }
                    },
                  ).cornerRadiusWithClipRRect(4),
                ),
              ],
            ),
          );
        }

        String address = [
          productStore.addressData.addressLine1,
          productStore.addressData.addressLine2,
          productStore.addressData.cityName,
          productStore.addressData.postalCode,
          productStore.addressData.stateName,
          productStore.addressData.countryName,
        ]
            .where((e) => e != null && e.validate().isNotEmpty)
            .join(', ');


        return Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationDefault(
            color: context.cardColor,
            borderRadius: radius(4),
            border: Border.all(color: borderColor , width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Profile Picture
                  Container(
                    width: 25,
                    height: 25,
                    child: ClipRRect(
                      borderRadius: radius(12.5),
                      child: CachedImageWidget(
                        url: userStore.userProfileImage.validate(),
                        height: 25,
                        width: 25,
                        fit: BoxFit.cover,
                        radius: 12.5,
                      ),
                    ),
                  ),
                  // Name
                  8.width,
                  Text(
                    '${addressData.firstName.validate()} ${addressData.lastName.validate()}',
                    style: boldTextStyle(size: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  // Change Address Option
                  GestureDetector(
                    onTap: () async {
                      if (addressList.length > 1) {
                        final result = await SelectAddressScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                        if (result == true) {
                          // Refresh logistic zone for the newly selected address
                          if (productStore.addressData.id != null && productStore.addressData.id != 0) {
                            await getLogisticZoneApi(addressId: productStore.addressData.id!);
                          }
                          setState(() {});
                        }
                      } else {
                        // If only one address, allow editing or adding new
                        final result = await SelectAddressScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                        if (result == true) {
                          if (productStore.addressData.id != null && productStore.addressData.id != 0) {
                            await getLogisticZoneApi(addressId: productStore.addressData.id!);
                          }
                          setState(() {});
                        }
                      }
                    },
                    child: Text(
                      locale.change.capitalizeFirstLetter(),
                      style: boldTextStyle(color: primaryColor, size: 12, weight: FontWeight.w600, decoration: TextDecoration.underline, decorationColor: primaryColor),
                    ),
                  ),
                ],
              ),
              6.height,
              // Full Address
              Text(
                address,
                style: secondaryTextStyle(size: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              // Logistic Zone Section
              logisticWidget(context),
            ],
          ),
        );
      },
    );
  }

  /// Logistic Zone Widget
  Widget logisticWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (logisticList.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              12.height,
              Text('*${locale.weAreNotShipping}.', style: secondaryTextStyle(color: wishListColor, fontStyle: FontStyle.italic)),
              Text("${locale.weCurrentlyShipToTheFollowingLocations}:", style: secondaryTextStyle(fontStyle: FontStyle.italic)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: zoneList.map((e) => Text("• ${e.name.validate()}", style: secondaryTextStyle(fontStyle: FontStyle.italic))).toList(),
              ),
              Text(locale.wereExpandingSoon, style: secondaryTextStyle(fontStyle: FontStyle.italic)),
              Text(locale.ifYourAreaIsntListedPleaseContactUsOrTryADifferentAddress, style: secondaryTextStyle(fontStyle: FontStyle.italic))
            ],
          ),
        if (logisticList.isNotEmpty) ...[
          12.height,
          DottedLine(lineThickness: 1, dashLength: 4, dashColor: context.dividerColor),
          12.height,
          Text(
            locale.deliveryCharge,
            style: secondaryTextStyle(color: Colors.green, size: 14, fontStyle: FontStyle.italic),
          ),
          8.height,
        ],
        AnimatedWrap(
          itemCount: logisticList.length,
          itemBuilder: (context, index) {
            LogisticZoneData logisticData = logisticList[index];

            return Container(
              decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius()),
              padding: EdgeInsets.only(left: 0, right: 8, bottom: 8),
              child: CheckboxListTile(
                value: logisticData.isLogisticCheck,
                title: Text(
                  logisticData.name.validate(),
                  style: boldTextStyle(color: appStore.isDarkMode ? textPrimaryColorGlobal : secondaryColor, size: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                secondary: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(logisticData.standardDeliveryTime.validate(), style: secondaryTextStyle()),
                    8.width,
                    logisticData.standardDeliveryCharge.validate() == 0 ? Text(locale.free, style: primaryTextStyle(size: 16)) : PriceWidget(price: logisticData.standardDeliveryCharge.validate()),
                  ],
                ),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                controlAffinity: ListTileControlAffinity.leading,
                checkboxShape: RoundedRectangleBorder(borderRadius: radius(5)),
                side: BorderSide(color: textSecondaryColorGlobal),
                dense: true,
                activeColor: appStore.isDarkMode ? primaryColor : secondaryColor,
                onChanged: (value) {
                  // Deselect all other logistic options first
                  for (var logistic in logisticList) {
                    logistic.isLogisticCheck = false;
                  }

                  // Select only the current one
                  logisticData.isLogisticCheck = true;
                  isSelectedLogistic = true;
                  productStore.setLogisticZoneData(logisticData);

                  setState(() {});
                },
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => DashboardScreen(pageIndex: 2)),
            (route) => false,
          );
        }
      },
      child: AppScaffold(
        appBarWidget: commonAppBarServicesWidget(
          context,
          title: locale.cart,
          appBarHeight: 70,
          showLeadingIcon: true,
          roundCornerShape: true,
          onLeadingIconPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => DashboardScreen(pageIndex: 2)),
              (route) => false,
            );
          },
        ),
        body: SnapHelperWidget(
          future: future,
          loadingWidget: LoaderWidget(),
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.reload,
              imageWidget: ErrorStateWidget(),
              onRetry: () {
                page = 1;
                appStore.setLoading(true);

                init(flag: true);
              },
            );
          },
          onSuccess: (cartList) {
            if (cartList.$1.isEmpty) {
              return NoDataWidget(
                title: locale.yourCartIsEmpty,
                subTitle: locale.thereAreCurrentlyNoItems,
                imageWidget: EmptyStateWidget(),
                retryText: locale.reload,
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);

                  init(flag: true);
                },
              ).paddingSymmetric(horizontal: 16);
            }

            return Stack(
              children: [
                AnimatedScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 225, top: 20),
                  onSwipeRefresh: () async {
                    page = 1;
                    init(flag: true);
                    return await 2.seconds.delay;
                  },
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      appStore.setLoading(true);
                      init(flag: true);
                    }
                  },
                  children: [
                    // Address Section
                    _buildAddressSection(),
                    20.height,
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(locale.itemsInCart, style: primaryTextStyle(size: 14, weight: FontWeight.w600)),
                    ),
                    8.height,
                    AnimatedListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cartList.$1.length,
                      itemBuilder: (context, index) {
                        productStore.setCartListData(cartList.$1);
                        return CartItemComponent(cartListData: cartList.$1[index]);
                      },
                    ),
                    // Container(
                    //   margin: EdgeInsets.symmetric(horizontal: 16),
                    //   child: ApplyCouponComponent(
                    //     isFromCart: true,
                    //     cartTotal: _calculateAllItemsSubtotal(),
                    //     callback: () {
                    //       setState(() {});
                    //     },
                    //   ),
                    // ),
                  ],
                ),
                if (cartList.$1.isNotEmpty) ...[
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Observer(
                      builder: (context) {
                        // Check if button should be enabled
                        final bool hasValidAddress = productStore.addressData.id != null && productStore.addressData.id != 0;
                        final bool hasLogisticZone = logisticList.isNotEmpty;
                        final bool hasSelectedLogistic = isSelectedLogistic;
                        final bool isButtonEnabled = hasValidAddress && hasLogisticZone && hasSelectedLogistic;

                        return CommonProductBottomPriceWidget(
                          title: cartList.$1.map((item) => item.productName).toList().join(', '),
                          price: _calculateAllItemsTotal(),
                          buttonText: locale.next,
                          cartListData: cartList.$1,
                          cartPriceData: cartList.$2.cartPriceData,
                          isEnabled: isButtonEnabled,
                          onTap: isButtonEnabled
                              ? () {
                                  final List<CartListData> items = cartList.$1;
                                  productStore.setCartListData(items);

                                  final num subtotal = _calculateAllItemsSubtotal();
                                  final num tax = _calculateAllItemsTax();

                                  CartTaxData? originalTaxData = productStore.cartPriceData.taxData;

                                  productStore.setCartPriceData(CartPriceData(
                                    taxIncludedAmount: subtotal,
                                    taxAmount: tax,
                                    totalAmount: subtotal + tax,
                                    totalPayableAmount: subtotal + tax,
                                    taxData: originalTaxData,
                                  ));

                                  OrderSummaryScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
