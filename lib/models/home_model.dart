class HomeModel {
  final String? fullName;
  final String? email;
  final String? profilePic;

  HomeModel({
    this.fullName,
    this.email,
    this.profilePic,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      profilePic: json['profile_pic'] as String?,
    );
  }
}
