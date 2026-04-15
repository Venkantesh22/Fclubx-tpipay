class SliderData {
    int? id;
    String? link;
    int? linkId;
    String? name;
    int? status;
    String? type;
    String? sliderImage;

    SliderData({this.id, this.link, this.linkId, this.name, this.status, this.type,this.sliderImage});

    factory SliderData.fromJson(Map<String, dynamic> json) {
        return SliderData(
            id: json['id'], 
            link: json['link'], 
            linkId: json['link_id'], 
            name: json['name'], 
            status: json['status'], 
            type: json['type'],
            sliderImage: json['slider_image'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['link'] = this.link;
        data['link_id'] = this.linkId;
        data['name'] = this.name;
        data['status'] = this.status;
        data['type'] = this.type;
        data['slider_image'] = this.sliderImage;
        return data;
    }
}

class PopularServices {
    int id;
    String slug;
    String name;
    String description;
    int durationMin;
    int defaultPrice;
    int status;
    int categoryId;
    String categoryName;
    int subCategoryId;
    String serviceImage;
    dynamic createdBy;
    dynamic updatedBy;
    dynamic deletedBy;
    String createdAt;
    String updatedAt;
    dynamic deletedAt;

    PopularServices({
        this.id = -1,
        this.slug = "",
        this.name = "",
        this.description = "",
        this.durationMin = -1,
        this.defaultPrice = -1,
        this.status = -1,
        this.categoryId = -1,
        this.categoryName = "",
        this.subCategoryId = -1,
        this.serviceImage = "",
        this.createdBy,
        this.updatedBy,
        this.deletedBy,
        this.createdAt = "",
        this.updatedAt = "",
        this.deletedAt,
    });

    factory PopularServices.fromJson(Map<String, dynamic> json) {
        return PopularServices(
            id: json['id'] is int ? json['id'] : -1,
            slug: json['slug'] is String ? json['slug'] : "",
            name: json['name'] is String ? json['name'] : "",
            description: json['description'] is String ? json['description'] : "",
            durationMin: json['duration_min'] is int ? json['duration_min'] : -1,
            defaultPrice: json['default_price'] is int ? json['default_price'] : -1,
            status: json['status'] is int ? json['status'] : -1,
            categoryId: json['category_id'] is int ? json['category_id'] : -1,
            categoryName:
            json['category_name'] is String ? json['category_name'] : "",
            subCategoryId:
            json['sub_category_id'] is int ? json['sub_category_id'] : -1,
            serviceImage:
            json['service_image'] is String ? json['service_image'] : "",
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
            'slug': slug,
            'name': name,
            'description': description,
            'duration_min': durationMin,
            'default_price': defaultPrice,
            'status': status,
            'category_id': categoryId,
            'category_name': categoryName,
            'sub_category_id': subCategoryId,
            'service_image': serviceImage,
            'created_by': createdBy,
            'updated_by': updatedBy,
            'deleted_by': deletedBy,
            'created_at': createdAt,
            'updated_at': updatedAt,
            'deleted_at': deletedAt,
        };
    }
}
