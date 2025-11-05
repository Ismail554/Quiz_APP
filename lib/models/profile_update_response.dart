class ProfileUpdateResponse {
  final String message;
  final ProfileData? data;

  ProfileUpdateResponse({
    required this.message,
    this.data,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProfileData.fromJson(json['data'])
          : null,
    );
  }
}

class ProfileData {
  final String fullName;
  final String profilePic;

  ProfileData({
    required this.fullName,
    required this.profilePic,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      fullName: json['full_name'] ?? '',
      profilePic: json['profile_pic'] ?? '',
    );
  }
}
