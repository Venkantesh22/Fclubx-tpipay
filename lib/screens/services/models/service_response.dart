import 'package:frezka/main.dart';

class ServiceResponse {
  List<ServiceListData>? data;
  String? message;
  bool? status;

  ServiceResponse({this.data, this.message, this.status});

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      data: json['data'] != null ? (json['data'] as List).map((i) => ServiceListData.fromJson(i)).toList() : null,
      message: json['message'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceListData {
  int? categoryId;
  String? createdAt;
  int? createdBy;
  num? defaultPrice;
  String? deletedAt;
  int? deletedBy;
  String? description;
  int? durationMin;
  int? id;
  String? name;
  String? serviceImage;
  String? slug;
  int? subCategoryId;
  int? staffCount;
  int? branchCount;
  String? updatedAt;
  int? updatedBy;
  String? startDateTime;
  DateTime? previousTime;

  bool isServiceChecked;

  // for booking-wise service
  num? servicePrice;
  int? serviceId;
  String? serviceName;

  ServiceListData({
    this.categoryId,
    this.createdAt,
    this.createdBy,
    this.defaultPrice,
    this.servicePrice,
    this.deletedAt,
    this.deletedBy,
    this.description,
    this.durationMin,
    this.id,
    this.name,
    this.serviceId,
    this.serviceName,
    this.serviceImage,
    this.slug,
    this.subCategoryId,
    this.staffCount,
    this.branchCount,
    this.updatedAt,
    this.updatedBy,
    this.startDateTime,
    this.previousTime,
    this.isServiceChecked = false,
  });

  factory ServiceListData.fromJson(Map<String, dynamic> json) {
    return ServiceListData(
      categoryId: json['category_id'],
      createdAt: json['created_at'],
      createdBy: json['created_by'],
      defaultPrice: json['default_price'] != null ? num.tryParse(json['default_price'].toString()) : null,
      servicePrice: json['service_price'] != null ? num.tryParse(json['service_price'].toString()) : null,
      deletedAt: json['deleted_at'],
      deletedBy: json['deleted_by'],
      description: json['description'],
      durationMin: json['duration_min'] is int ? json['duration_min'] : int.tryParse(json['duration_min'].toString()),
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      name: json['name'],
      serviceId: json['service_id'] is int ? json['service_id'] : int.tryParse(json['service_id'].toString()),
      serviceName: json['service_name'],
      serviceImage: json['service_image'],
      slug: json['slug'],
      subCategoryId: json['sub_category_id'],
      staffCount: json['staff_count'],
      branchCount: json['branch_count'],
      updatedAt: json['updated_at'],
      updatedBy: json['updated_by'],
      startDateTime: json['start_date_time'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_id'] = categoryId;
    data['created_at'] = createdAt;
    data['created_by'] = createdBy;
    data['default_price'] = defaultPrice;
    data['service_price'] = servicePrice;
    data['description'] = description;
    data['duration_min'] = durationMin;
    data['id'] = id;
    data['name'] = name;
    data['service_id'] = serviceId;
    data['service_name'] = serviceName;
    data['service_image'] = serviceImage;
    data['slug'] = slug;
    data['sub_category_id'] = subCategoryId;
    data['staff_count'] = staffCount;
    data['branch_count'] = branchCount;
      data['updated_at'] = updatedAt;
    data['updated_by'] = updatedBy;
    data['deleted_at'] = deletedAt;
    data['deleted_by'] = deletedBy;
    data['start_date_time'] = startDateTime;
    data['is_service_checked'] = isServiceChecked;
    data['duration_min'] = durationMin;
    return data;
  }

  /// For Save Booking
  Map<String, dynamic> toBookingServiceJson({
    bool isUpdate = false,
    bool isRescheduleBooking = false,
  }) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_id'] = (isUpdate || isRescheduleBooking) ? serviceId : id;
    data['service_price'] = (isUpdate || isRescheduleBooking) ? servicePrice : defaultPrice;
    if (bookingRequestStore.employeeId != -1) {
      data['employee_id'] = bookingRequestStore.employeeId;
    }
    data['duration_min'] = durationMin;
    data['start_date_time'] = startDateTime;
    return data;
  }
}

class ServiceDetailsResponse {
  final bool? status;
  final String? message;
  final ServiceData? data;

  ServiceDetailsResponse({this.status, this.message, this.data});

  factory ServiceDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? ServiceData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class ServiceData {
  final int? id;
  final String? name;
  final String? description;
  final num? price;
  final String? duration;
  final String? image;
  final List<String>? multiImage;
  final String? category;
  final String? subCategory;
  final Ratings? ratings;
  final List<Employee>? employee;
  final List<Branch>? branches;
  final String? expert;

  ServiceData({
    this.id,
    this.name,
    this.description,
    this.price,
    this.category,
    this.subCategory,
    this.duration,
    this.image,
    this.multiImage,
    this.ratings,
    this.employee,
    this.branches,
    this.expert,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['default_price'],
      duration: json['duration_min'] is String ? json['duration_min'] : json['duration_min'].toString(),
      image: json['service_image'],
      multiImage: json['multi_image'] != null ? List<String>.from(json['multi_image']) : null,
      category: json['category_name'],
      subCategory: json['sub_category_name'],
      ratings: json['ratings'] != null ? Ratings.fromJson(json['ratings']) : null,
      employee: json['employee'] != null ? (json['employee'] as List).map((i) => Employee.fromJson(i)).toList() : null,
      branches: json['branches'] != null ? (json['branches'] as List).map((i) => Branch.fromJson(i)).toList() : null,
      expert: json['expert'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "duration": duration,
      "image": image,
      "multi_image": multiImage,
      "category": category,
      "ratings": ratings?.toJson(),
      "expert": expert,
    };
  }
}

class Branch {
  final int? id;
  final String? name;
  final String? address;
  final String? email;
  final String? branchFor;
  final int? status;
  final bool? isOpen;
  final String? image;
  final String? city;
  final String? country;
  final num? ratingStar;
  final num? latitude;
  final num? longitude;

  Branch({
    this.id,
    this.name,
    this.address,
    this.email,
    this.branchFor,
    this.status,
    this.isOpen,
    this.image,
    this.city,
    this.country,
    this.ratingStar,
    this.latitude,
    this.longitude,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as int?,
      name: json['name'] as String?,
      address: json['address'] as String?,
      email: json['email'] as String?,
      branchFor: json['branch_for'] as String?,
      status: json['status'] as int?,
      isOpen: json['is_open'] as bool?,
      image: json['image'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      ratingStar: json['rating_star'] as num?,
      latitude: json['latitude'] as num?,
      longitude: json['longitude'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'email': email,
      'branch_for': branchFor,
      'status': status,
      'is_open': isOpen,
      'image': image,
      'city': city,
      'country': country,
      'rating_star': ratingStar,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Employee {
  final int? id;
  final String? name;
  final String? image;
  final num? rating;
  final String? expert;
  Employee({this.id, this.name, this.image, this.rating, this.expert});
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      image: json['profile_image'],
      rating: json['rating'],
      expert: json['expert'],
    );
  }
}

class Category {
  final int? id;
  final String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}

class Ratings {
  final double? avgRating;
  final int? totalReviews;

  Ratings({this.avgRating, this.totalReviews});

  factory Ratings.fromJson(Map<String, dynamic> json) {
    return Ratings(
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      totalReviews: json['total_reviews'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "avg_rating": avgRating,
      "total_reviews": totalReviews,
    };
  }
}
