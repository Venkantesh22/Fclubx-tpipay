// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductStore on _ProductStore, Store {
  Computed<num>? _$totalAmountComputed;

  @override
  num get totalAmount =>
      (_$totalAmountComputed ??= Computed<num>(() => super.totalAmount,
              name: '_ProductStore.totalAmount'))
          .value;

  late final _$qtyAtom = Atom(name: '_ProductStore.qty', context: context);

  @override
  int get qty {
    _$qtyAtom.reportRead();
    return super.qty;
  }

  @override
  set qty(int value) {
    _$qtyAtom.reportWrite(value, super.qty, () {
      super.qty = value;
    });
  }

  late final _$inWishListIdsAtom =
      Atom(name: '_ProductStore.inWishListIds', context: context);

  @override
  List<ProductData> get inWishListIds {
    _$inWishListIdsAtom.reportRead();
    return super.inWishListIds;
  }

  @override
  set inWishListIds(List<ProductData> value) {
    _$inWishListIdsAtom.reportWrite(value, super.inWishListIds, () {
      super.inWishListIds = value;
    });
  }

  late final _$isWishListAtom =
      Atom(name: '_ProductStore.isWishList', context: context);

  @override
  int get isWishList {
    _$isWishListAtom.reportRead();
    return super.isWishList;
  }

  @override
  set isWishList(int value) {
    _$isWishListAtom.reportWrite(value, super.isWishList, () {
      super.isWishList = value;
    });
  }

  late final _$cartItemCountAtom =
      Atom(name: '_ProductStore.cartItemCount', context: context);

  @override
  int get cartItemCount {
    _$cartItemCountAtom.reportRead();
    return super.cartItemCount;
  }

  @override
  set cartItemCount(int value) {
    _$cartItemCountAtom.reportWrite(value, super.cartItemCount, () {
      super.cartItemCount = value;
    });
  }

  late final _$fullNameAtom =
      Atom(name: '_ProductStore.fullName', context: context);

  @override
  String get fullName {
    _$fullNameAtom.reportRead();
    return super.fullName;
  }

  @override
  set fullName(String value) {
    _$fullNameAtom.reportWrite(value, super.fullName, () {
      super.fullName = value;
    });
  }

  late final _$customerEmailAtom =
      Atom(name: '_ProductStore.customerEmail', context: context);

  @override
  String get customerEmail {
    _$customerEmailAtom.reportRead();
    return super.customerEmail;
  }

  @override
  set customerEmail(String value) {
    _$customerEmailAtom.reportWrite(value, super.customerEmail, () {
      super.customerEmail = value;
    });
  }

  late final _$contactNumberAtom =
      Atom(name: '_ProductStore.contactNumber', context: context);

  @override
  String get contactNumber {
    _$contactNumberAtom.reportRead();
    return super.contactNumber;
  }

  @override
  set contactNumber(String value) {
    _$contactNumberAtom.reportWrite(value, super.contactNumber, () {
      super.contactNumber = value;
    });
  }

  late final _$alternateContactNumberAtom =
      Atom(name: '_ProductStore.alternateContactNumber', context: context);

  @override
  String get alternateContactNumber {
    _$alternateContactNumberAtom.reportRead();
    return super.alternateContactNumber;
  }

  @override
  set alternateContactNumber(String value) {
    _$alternateContactNumberAtom
        .reportWrite(value, super.alternateContactNumber, () {
      super.alternateContactNumber = value;
    });
  }

  late final _$selectedVariationDataAtom =
      Atom(name: '_ProductStore.selectedVariationData', context: context);

  @override
  VariationData get selectedVariationData {
    _$selectedVariationDataAtom.reportRead();
    return super.selectedVariationData;
  }

  @override
  set selectedVariationData(VariationData value) {
    _$selectedVariationDataAtom.reportWrite(value, super.selectedVariationData,
        () {
      super.selectedVariationData = value;
    });
  }

  late final _$cartPriceDataAtom =
      Atom(name: '_ProductStore.cartPriceData', context: context);

  @override
  CartPriceData get cartPriceData {
    _$cartPriceDataAtom.reportRead();
    return super.cartPriceData;
  }

  @override
  set cartPriceData(CartPriceData value) {
    _$cartPriceDataAtom.reportWrite(value, super.cartPriceData, () {
      super.cartPriceData = value;
    });
  }

  late final _$addressDataAtom =
      Atom(name: '_ProductStore.addressData', context: context);

  @override
  UserAddress get addressData {
    _$addressDataAtom.reportRead();
    return super.addressData;
  }

  @override
  set addressData(UserAddress value) {
    _$addressDataAtom.reportWrite(value, super.addressData, () {
      super.addressData = value;
    });
  }

  late final _$logisticZoneDataAtom =
      Atom(name: '_ProductStore.logisticZoneData', context: context);

  @override
  LogisticZoneData get logisticZoneData {
    _$logisticZoneDataAtom.reportRead();
    return super.logisticZoneData;
  }

  @override
  set logisticZoneData(LogisticZoneData value) {
    _$logisticZoneDataAtom.reportWrite(value, super.logisticZoneData, () {
      super.logisticZoneData = value;
    });
  }

  late final _$productCartListDataAtom =
      Atom(name: '_ProductStore.productCartListData', context: context);

  @override
  List<CartListData> get productCartListData {
    _$productCartListDataAtom.reportRead();
    return super.productCartListData;
  }

  @override
  set productCartListData(List<CartListData> value) {
    _$productCartListDataAtom.reportWrite(value, super.productCartListData, () {
      super.productCartListData = value;
    });
  }

  late final _$selectedOrderStatusListAtom =
      Atom(name: '_ProductStore.selectedOrderStatusList', context: context);

  @override
  List<String> get selectedOrderStatusList {
    _$selectedOrderStatusListAtom.reportRead();
    return super.selectedOrderStatusList;
  }

  @override
  set selectedOrderStatusList(List<String> value) {
    _$selectedOrderStatusListAtom
        .reportWrite(value, super.selectedOrderStatusList, () {
      super.selectedOrderStatusList = value;
    });
  }

  late final _$selectedPaymentStatusListAtom =
      Atom(name: '_ProductStore.selectedPaymentStatusList', context: context);

  @override
  List<String> get selectedPaymentStatusList {
    _$selectedPaymentStatusListAtom.reportRead();
    return super.selectedPaymentStatusList;
  }

  @override
  set selectedPaymentStatusList(List<String> value) {
    _$selectedPaymentStatusListAtom
        .reportWrite(value, super.selectedPaymentStatusList, () {
      super.selectedPaymentStatusList = value;
    });
  }

  late final _$isCouponAppliedAtom =
      Atom(name: '_ProductStore.isCouponApplied', context: context);

  @override
  bool get isCouponApplied {
    _$isCouponAppliedAtom.reportRead();
    return super.isCouponApplied;
  }

  @override
  set isCouponApplied(bool value) {
    _$isCouponAppliedAtom.reportWrite(value, super.isCouponApplied, () {
      super.isCouponApplied = value;
    });
  }

  late final _$discountCouponCodeAtom =
      Atom(name: '_ProductStore.discountCouponCode', context: context);

  @override
  String get discountCouponCode {
    _$discountCouponCodeAtom.reportRead();
    return super.discountCouponCode;
  }

  @override
  set discountCouponCode(String value) {
    _$discountCouponCodeAtom.reportWrite(value, super.discountCouponCode, () {
      super.discountCouponCode = value;
    });
  }

  late final _$finalDiscountCouponAmountAtom =
      Atom(name: '_ProductStore.finalDiscountCouponAmount', context: context);

  @override
  num get finalDiscountCouponAmount {
    _$finalDiscountCouponAmountAtom.reportRead();
    return super.finalDiscountCouponAmount;
  }

  @override
  set finalDiscountCouponAmount(num value) {
    _$finalDiscountCouponAmountAtom
        .reportWrite(value, super.finalDiscountCouponAmount, () {
      super.finalDiscountCouponAmount = value;
    });
  }

  late final _$isFixedDiscountCouponAtom =
      Atom(name: '_ProductStore.isFixedDiscountCoupon', context: context);

  @override
  bool get isFixedDiscountCoupon {
    _$isFixedDiscountCouponAtom.reportRead();
    return super.isFixedDiscountCoupon;
  }

  @override
  set isFixedDiscountCoupon(bool value) {
    _$isFixedDiscountCouponAtom.reportWrite(value, super.isFixedDiscountCoupon,
        () {
      super.isFixedDiscountCoupon = value;
    });
  }

  late final _$couponDiscountPercentageAtom =
      Atom(name: '_ProductStore.couponDiscountPercentage', context: context);

  @override
  double get couponDiscountPercentage {
    _$couponDiscountPercentageAtom.reportRead();
    return super.couponDiscountPercentage;
  }

  @override
  set couponDiscountPercentage(double value) {
    _$couponDiscountPercentageAtom
        .reportWrite(value, super.couponDiscountPercentage, () {
      super.couponDiscountPercentage = value;
    });
  }

  late final _$setCustomerFullNameAsyncAction =
      AsyncAction('_ProductStore.setCustomerFullName', context: context);

  @override
  Future<void> setCustomerFullName(String val) {
    return _$setCustomerFullNameAsyncAction
        .run(() => super.setCustomerFullName(val));
  }

  late final _$setCustomerEmailAsyncAction =
      AsyncAction('_ProductStore.setCustomerEmail', context: context);

  @override
  Future<void> setCustomerEmail(String val) {
    return _$setCustomerEmailAsyncAction.run(() => super.setCustomerEmail(val));
  }

  late final _$setCustomerContactNumberAsyncAction =
      AsyncAction('_ProductStore.setCustomerContactNumber', context: context);

  @override
  Future<void> setCustomerContactNumber(String val) {
    return _$setCustomerContactNumberAsyncAction
        .run(() => super.setCustomerContactNumber(val));
  }

  late final _$setCustomerAlternateContactNumberAsyncAction = AsyncAction(
      '_ProductStore.setCustomerAlternateContactNumber',
      context: context);

  @override
  Future<void> setCustomerAlternateContactNumber(String val) {
    return _$setCustomerAlternateContactNumberAsyncAction
        .run(() => super.setCustomerAlternateContactNumber(val));
  }

  late final _$_ProductStoreActionController =
      ActionController(name: '_ProductStore', context: context);

  @override
  void setSelectedOrderStatusList(List<String> selectedOrderStatusListRequest) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setSelectedOrderStatusList');
    try {
      return super.setSelectedOrderStatusList(selectedOrderStatusListRequest);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedPaymentStatusList(
      List<String> selectedPaymentStatusListRequest) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setSelectedPaymentStatusList');
    try {
      return super
          .setSelectedPaymentStatusList(selectedPaymentStatusListRequest);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setProductQuantity(int val) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setProductQuantity');
    try {
      return super.setProductQuantity(val);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setToWishList(List<ProductData> val) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setToWishList');
    try {
      return super.setToWishList(val);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setWishList(int val) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setWishList');
    try {
      return super.setWishList(val);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCartItemCount(int val) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setCartItemCount');
    try {
      return super.setCartItemCount(val);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedVariationData(VariationData data) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setSelectedVariationData');
    try {
      return super.setSelectedVariationData(data);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCartPriceData(CartPriceData data) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setCartPriceData');
    try {
      return super.setCartPriceData(data);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedAddressData(UserAddress data) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setSelectedAddressData');
    try {
      return super.setSelectedAddressData(data);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLogisticZoneData(LogisticZoneData data) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setLogisticZoneData');
    try {
      return super.setLogisticZoneData(data);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCartListData(List<CartListData> cartListData) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setCartListData');
    try {
      return super.setCartListData(cartListData);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCouponApplied(bool val) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setCouponApplied');
    try {
      return super.setCouponApplied(val);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDiscountCouponCode(String val) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setDiscountCouponCode');
    try {
      return super.setDiscountCouponCode(val);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFinalDiscountCouponAmount(num val) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setFinalDiscountCouponAmount');
    try {
      return super.setFinalDiscountCouponAmount(val);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFixedCouponType(bool val) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setFixedCouponType');
    try {
      return super.setFixedCouponType(val);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCouponPercentage(double val) {
    final _$actionInfo = _$_ProductStoreActionController.startAction(
        name: '_ProductStore.setCouponPercentage');
    try {
      return super.setCouponPercentage(val);
    } finally {
      _$_ProductStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
qty: ${qty},
inWishListIds: ${inWishListIds},
isWishList: ${isWishList},
cartItemCount: ${cartItemCount},
fullName: ${fullName},
customerEmail: ${customerEmail},
contactNumber: ${contactNumber},
alternateContactNumber: ${alternateContactNumber},
selectedVariationData: ${selectedVariationData},
cartPriceData: ${cartPriceData},
addressData: ${addressData},
logisticZoneData: ${logisticZoneData},
productCartListData: ${productCartListData},
selectedOrderStatusList: ${selectedOrderStatusList},
selectedPaymentStatusList: ${selectedPaymentStatusList},
isCouponApplied: ${isCouponApplied},
discountCouponCode: ${discountCouponCode},
finalDiscountCouponAmount: ${finalDiscountCouponAmount},
isFixedDiscountCoupon: ${isFixedDiscountCoupon},
couponDiscountPercentage: ${couponDiscountPercentage},
totalAmount: ${totalAmount}
    ''';
  }
}
