class OptionalModuleResponse {
  final List<ModulePair> pairs;

  OptionalModuleResponse({required this.pairs});

  factory OptionalModuleResponse.fromJson(List<dynamic> json) {
    return OptionalModuleResponse(
      pairs: json.map((item) => ModulePair.fromJson(item)).toList(),
    );
  }
}

class ModulePair {
  final int pairNumber;
  final List<Module> modules;
  final String? selectedModule;

  ModulePair({
    required this.pairNumber,
    required this.modules,
    this.selectedModule,
  });

  factory ModulePair.fromJson(Map<String, dynamic> json) {
    final selectedModule = json['selected_module'];
    // Handle null, empty string, or whitespace-only strings
    final selectedModuleValue =
        selectedModule != null && selectedModule.toString().trim().isNotEmpty
        ? selectedModule.toString().trim()
        : null;

    return ModulePair(
      pairNumber: json['pair_number'] ?? 0,
      modules:
          (json['modules'] as List<dynamic>?)
              ?.map((item) => Module.fromJson(item))
              .toList() ??
          [],
      selectedModule: selectedModuleValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pair_number': pairNumber,
      'modules': modules.map((m) => m.toJson()).toList(),
      'selected_module': selectedModule,
    };
  }
}

class Module {
  final String id;
  final String moduleName;

  Module({required this.id, required this.moduleName});

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id']?.toString().trim() ?? '',
      moduleName: json['module_name']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'module_name': moduleName};
  }
}
