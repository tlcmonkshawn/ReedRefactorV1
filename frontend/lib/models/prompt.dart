class Prompt {
  final int id;
  final String category;
  final String name;
  final String model;
  final String promptText;
  final String? description;
  final String? useCase;
  final Map<String, dynamic>? metadata;
  final bool active;
  final int version;
  final String? promptType;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prompt({
    required this.id,
    required this.category,
    required this.name,
    required this.model,
    required this.promptText,
    this.description,
    this.useCase,
    this.metadata,
    required this.active,
    required this.version,
    this.promptType,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'] as int,
      category: json['category'] as String,
      name: json['name'] as String,
      model: json['model'] as String,
      promptText: json['prompt_text'] as String,
      description: json['description'] as String?,
      useCase: json['use_case'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      active: json['active'] as bool? ?? true,
      version: json['version'] as int? ?? 1,
      promptType: json['prompt_type'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'model': model,
      'prompt_text': promptText,
      'description': description,
      'use_case': useCase,
      'metadata': metadata,
      'active': active,
      'version': version,
      'prompt_type': promptType,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'category': category,
      'name': name,
      'model': model,
      'prompt_text': promptText,
      'description': description,
      'use_case': useCase,
      'metadata': metadata,
      'active': active,
      'prompt_type': promptType,
      'sort_order': sortOrder,
    };
  }
}

