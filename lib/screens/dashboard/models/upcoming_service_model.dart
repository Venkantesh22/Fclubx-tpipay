class UpcomingServiceModel {
  List<UpcomingBooking> upcomingBooking;

  UpcomingServiceModel({
    this.upcomingBooking = const <UpcomingBooking>[],
  });

  factory UpcomingServiceModel.fromJson(Map<String, dynamic> json) {
    return UpcomingServiceModel(
      upcomingBooking: json['upcoming_booking'] is List
          ? List<UpcomingBooking>.from(
          json['upcoming_booking'].map((x) => UpcomingBooking.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upcoming_booking': upcomingBooking.map((e) => e.toJson()).toList(),
    };
  }
}

class UpcomingBooking {
  int id;
  dynamic note;
  String startDateTime;
  int branchId;
  String branchName;
  String addressLine1;
  String addressLine2;
  String phone;
  int employeeId;
  String employeeName;
  String employeeImage;
  List<Services> services;
  int userId;
  String userName;
  String userProfileImage;
  String userCreated;
  String status;
  String createdByName;
  String updatedByName;
  String createdAt;
  String updatedAt;
  Payment payment;
  int sumOfServicePrices;
  int sumOfProductPrices;
  int taxAmount;
  int totalAmount;
  int couponAmount;
  int sumOfPackagesPrices;
  List<dynamic> packages;

  UpcomingBooking({
    this.id = -1,
    this.note,
    this.startDateTime = "",
    this.branchId = -1,
    this.branchName = "",
    this.addressLine1 = "",
    this.addressLine2 = "",
    this.phone = "",
    this.employeeId = -1,
    this.employeeName = "",
    this.employeeImage = "",
    this.services = const <Services>[],
    this.userId = -1,
    this.userName = "",
    this.userProfileImage = "",
    this.userCreated = "",
    this.status = "",
    this.createdByName = "",
    this.updatedByName = "",
    this.createdAt = "",
    this.updatedAt = "",
    required this.payment,
    this.sumOfServicePrices = -1,
    this.sumOfProductPrices = -1,
    this.taxAmount = -1,
    this.totalAmount = -1,
    this.couponAmount = -1,
    this.sumOfPackagesPrices = -1,
    this.packages = const [],
  });

  factory UpcomingBooking.fromJson(Map<String, dynamic> json) {
    return UpcomingBooking(
      id: json['id'] is int ? json['id'] : -1,
      note: json['note'],
      startDateTime:
      json['start_date_time'] is String ? json['start_date_time'] : "",
      branchId: json['branch_id'] is int ? json['branch_id'] : -1,
      branchName: json['branch_name'] is String ? json['branch_name'] : "",
      addressLine1:
      json['address_line_1'] is String ? json['address_line_1'] : "",
      addressLine2:
      json['address_line_2'] is String ? json['address_line_2'] : "",
      phone: json['phone'] is String ? json['phone'] : "",
      employeeId: json['employee_id'] is int ? json['employee_id'] : -1,
      employeeName:
      json['employee_name'] is String ? json['employee_name'] : "",
      employeeImage:
      json['employee_image'] is String ? json['employee_image'] : "",
      services: json['services'] is List
          ? List<Services>.from(
          json['services'].map((x) => Services.fromJson(x)))
          : [],
      userId: json['user_id'] is int ? json['user_id'] : -1,
      userName: json['user_name'] is String ? json['user_name'] : "",
      userProfileImage: json['user_profile_image'] is String
          ? json['user_profile_image']
          : "",
      userCreated: json['user_created'] is String ? json['user_created'] : "",
      status: json['status'] is String ? json['status'] : "",
      createdByName:
      json['created_by_name'] is String ? json['created_by_name'] : "",
      updatedByName:
      json['updated_by_name'] is String ? json['updated_by_name'] : "",
      createdAt: json['created_at'] is String ? json['created_at'] : "",
      updatedAt: json['updated_at'] is String ? json['updated_at'] : "",
      payment: json['payment'] is Map
          ? Payment.fromJson(json['payment'])
          : Payment(),
      sumOfServicePrices:
      json['sumOfServicePrices'] is int ? json['sumOfServicePrices'] : -1,
      sumOfProductPrices:
      json['sumOfProductPrices'] is int ? json['sumOfProductPrices'] : -1,
      taxAmount: json['tax_amount'] is int ? json['tax_amount'] : -1,
      totalAmount: json['total_amount'] is int ? json['total_amount'] : -1,
      couponAmount: json['coupon_amount'] is int ? json['coupon_amount'] : -1,
      sumOfPackagesPrices:
      json['sumOfPackagesPrices'] is int ? json['sumOfPackagesPrices'] : -1,
      packages: json['packages'] is List ? json['packages'] : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'note': note,
      'start_date_time': startDateTime,
      'branch_id': branchId,
      'branch_name': branchName,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'phone': phone,
      'employee_id': employeeId,
      'employee_name': employeeName,
      'employee_image': employeeImage,
      'services': services.map((e) => e.toJson()).toList(),
      'user_id': userId,
      'user_name': userName,
      'user_profile_image': userProfileImage,
      'user_created': userCreated,
      'status': status,
      'created_by_name': createdByName,
      'updated_by_name': updatedByName,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'payment': payment.toJson(),
      'sumOfServicePrices': sumOfServicePrices,
      'sumOfProductPrices': sumOfProductPrices,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'coupon_amount': couponAmount,
      'sumOfPackagesPrices': sumOfPackagesPrices,
      'packages': [],
    };
  }
}

class Services {
  int id;
  int sequance;
  String startDateTime;
  int bookingId;
  int serviceId;
  int employeeId;
  int servicePrice;
  int durationMin;
  dynamic createdBy;
  dynamic updatedBy;
  dynamic deletedBy;
  String createdAt;
  String updatedAt;
  dynamic deletedAt;
  String serviceName;
  String serviceImage;

  Services({
    this.id = -1,
    this.sequance = -1,
    this.startDateTime = "",
    this.bookingId = -1,
    this.serviceId = -1,
    this.employeeId = -1,
    this.servicePrice = -1,
    this.durationMin = -1,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt = "",
    this.updatedAt = "",
    this.deletedAt,
    this.serviceName = "",
    this.serviceImage = "",
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      id: json['id'] is int ? json['id'] : -1,
      sequance: json['sequance'] is int ? json['sequance'] : -1,
      startDateTime:
      json['start_date_time'] is String ? json['start_date_time'] : "",
      bookingId: json['booking_id'] is int ? json['booking_id'] : -1,
      serviceId: json['service_id'] is int ? json['service_id'] : -1,
      employeeId: json['employee_id'] is int ? json['employee_id'] : -1,
      servicePrice: json['service_price'] is int ? json['service_price'] : -1,
      durationMin: json['duration_min'] is int ? json['duration_min'] : -1,
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      deletedBy: json['deleted_by'],
      createdAt: json['created_at'] is String ? json['created_at'] : "",
      updatedAt: json['updated_at'] is String ? json['updated_at'] : "",
      deletedAt: json['deleted_at'],
      serviceName: json['service_name'] is String ? json['service_name'] : "",
      serviceImage:
      json['service_image'] is String ? json['service_image'] : "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sequance': sequance,
      'start_date_time': startDateTime,
      'booking_id': bookingId,
      'service_id': serviceId,
      'employee_id': employeeId,
      'service_price': servicePrice,
      'duration_min': durationMin,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'service_name': serviceName,
      'service_image': serviceImage,
    };
  }
}

class Payment {
  int id;
  int bookingId;
  String externalTransactionId;
  String transactionType;
  int discountPercentage;
  int discountAmount;
  int tipAmount;
  List<TaxPercentage> taxPercentage;
  int paymentStatus;
  dynamic requestToken;
  dynamic createdBy;
  dynamic updatedBy;
  dynamic deletedBy;
  String createdAt;
  String updatedAt;
  dynamic deletedAt;

  Payment({
    this.id = -1,
    this.bookingId = -1,
    this.externalTransactionId = "",
    this.transactionType = "",
    this.discountPercentage = -1,
    this.discountAmount = -1,
    this.tipAmount = -1,
    this.taxPercentage = const <TaxPercentage>[],
    this.paymentStatus = -1,
    this.requestToken,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt = "",
    this.updatedAt = "",
    this.deletedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] is int ? json['id'] : -1,
      bookingId: json['booking_id'] is int ? json['booking_id'] : -1,
      externalTransactionId: json['external_transaction_id'] is String
          ? json['external_transaction_id']
          : "",
      transactionType:
      json['transaction_type'] is String ? json['transaction_type'] : "",
      discountPercentage:
      json['discount_percentage'] is int ? json['discount_percentage'] : -1,
      discountAmount:
      json['discount_amount'] is int ? json['discount_amount'] : -1,
      tipAmount: json['tip_amount'] is int ? json['tip_amount'] : -1,
      taxPercentage: json['tax_percentage'] is List
          ? List<TaxPercentage>.from(
          json['tax_percentage'].map((x) => TaxPercentage.fromJson(x)))
          : [],
      paymentStatus:
      json['payment_status'] is int ? json['payment_status'] : -1,
      requestToken: json['request_token'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      deletedBy: json['deleted_by'],
      createdAt: json['created_at'] is String ? json['created_at'] : "",
      updatedAt: json['updated_at'] is String ? json['updated_at'] : "",
      deletedAt: json['deleted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'external_transaction_id': externalTransactionId,
      'transaction_type': transactionType,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'tip_amount': tipAmount,
      'tax_percentage': taxPercentage.map((e) => e.toJson()).toList(),
      'payment_status': paymentStatus,
      'request_token': requestToken,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}

class TaxPercentage {
  String name;
  String type;
  int percent;
  int amount;

  TaxPercentage({
    this.name = "",
    this.type = "",
    this.percent = -1,
    this.amount = -1,
  });

  factory TaxPercentage.fromJson(Map<String, dynamic> json) {
    return TaxPercentage(
      name: json['name'] is String ? json['name'] : "",
      type: json['type'] is String ? json['type'] : "",
      percent: json['percent'] is int ? json['percent'] : -1,
      amount: json['amount'] is int ? json['amount'] : -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'percent': percent,
      'amount': amount,
    };
  }
}
