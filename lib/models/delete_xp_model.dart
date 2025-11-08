class DeleteXpModel {
  final String message;
  final int remainingToDeduct;

  DeleteXpModel({required this.message, required this.remainingToDeduct});

  factory DeleteXpModel.fromJson(Map<String, dynamic> json) {
    return DeleteXpModel(
      message: json['message'] ?? '',
      remainingToDeduct: json['remaining_to_deduct'] ?? 0,
    );
  }
}
