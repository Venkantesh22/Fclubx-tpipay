class ReferralModel {
  final int? id;
  final String? name;
  final String? referralCode;
  final String? referralLink;

  ReferralModel({
    this.id,
    this.name,
    this.referralCode,
    this.referralLink,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) => ReferralModel(
        id: json["id"],
        name: json["name"],
        referralCode: json["referral_code"],
        referralLink: json["referral_link"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "referral_code": referralCode,
        "referral_link": referralLink,
      };
}
