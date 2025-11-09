class Bootie {
  final int id;
  final String title;
  final String? description;
  final String category;
  final String status;
  final double? recommendedBounty;
  final double? finalBounty;
  final String? primaryImageUrl;
  final List<String> alternateImageUrls;
  final List<String> editedImageUrls;
  final Location? location;
  final DateTime createdAt;
  final DateTime? finalizedAt;
  final String? researchSummary;
  final String? researchReasoning;

  Bootie({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.status,
    this.recommendedBounty,
    this.finalBounty,
    this.primaryImageUrl,
    this.alternateImageUrls = const [],
    this.editedImageUrls = const [],
    this.location,
    required this.createdAt,
    this.finalizedAt,
    this.researchSummary,
    this.researchReasoning,
  });

  factory Bootie.fromJson(Map<String, dynamic> json) {
    return Bootie(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      status: json['status'] as String,
      recommendedBounty: json['recommended_bounty'] != null
          ? (json['recommended_bounty'] as num).toDouble()
          : null,
      finalBounty: json['final_bounty'] != null
          ? (json['final_bounty'] as num).toDouble()
          : null,
      primaryImageUrl: json['primary_image_url'] as String?,
      alternateImageUrls: (json['alternate_image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      editedImageUrls: (json['edited_image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      finalizedAt: json['finalized_at'] != null
          ? DateTime.parse(json['finalized_at'] as String)
          : null,
      researchSummary: json['research_summary'] as String?,
      researchReasoning: json['research_reasoning'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'status': status,
      'recommended_bounty': recommendedBounty,
      'final_bounty': finalBounty,
      'primary_image_url': primaryImageUrl,
      'alternate_image_urls': alternateImageUrls,
      'edited_image_urls': editedImageUrls,
      'location': location?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'finalized_at': finalizedAt?.toIso8601String(),
      'research_summary': researchSummary,
      'research_reasoning': researchReasoning,
    };
  }

  bool get isCaptured => status == 'captured';
  bool get isSubmitted => status == 'submitted';
  bool get isResearching => status == 'researching';
  bool get isResearched => status == 'researched';
  bool get isFinalized => status == 'finalized';

  String get statusDisplayName {
    switch (status) {
      case 'captured':
        return 'Captured';
      case 'submitted':
        return 'Submitted';
      case 'researching':
        return 'Researching';
      case 'researched':
        return 'Researched';
      case 'finalized':
        return 'Finalized';
      default:
        return status;
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case 'used_goods':
        return 'Used Goods';
      case 'antiques':
        return 'Antiques';
      case 'electronics':
        return 'Electronics';
      case 'collectibles':
        return 'Collectibles';
      case 'weaponry':
        return 'Weaponry';
      case 'artifacts':
        return 'Artifacts';
      case 'data_logs':
        return 'Data Logs';
      case 'miscellaneous':
        return 'Miscellaneous';
      default:
        return category;
    }
  }
}

class Location {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? fullAddress;
  final bool active;

  Location({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.fullAddress,
    required this.active,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      fullAddress: json['full_address'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'full_address': fullAddress,
      'active': active,
    };
  }
}

