class ModuleModel {
  final String id;
  final String moduleName;

  ModuleModel({
    required this.id,
    required this.moduleName,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'],
      moduleName: json['module_name'],
    );
  }
}
