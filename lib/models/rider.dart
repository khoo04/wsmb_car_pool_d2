class Rider {
  final String? name;
  final String? IC;
  final String? gender;
  final String? email;
  final String? address;
  final String? imageUrl;
  final String role = "rider";
  final String? phone;

  Rider({
    this.IC,
    this.name,
    this.gender,
    this.email,
    this.address,
    this.imageUrl,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      "IC": IC,
      "name": name,
      "gender": gender,
      "role": role,
      "email": email,
      "phone": phone,
      "address": address,
      "imageUrl": imageUrl,
    };
  }

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      IC: json["IC"],
      name: json["name"],
      gender: json["gender"],
      email: json["email"],
      address: json["address"],
      phone: json["phone"],
      imageUrl: json["imageUrl"],
    );
  }
}
