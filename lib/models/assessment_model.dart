enum AssessmentType {
  toddler,
  child,
  teen,
}

enum AssessmentStatus {
  notStarted,
  inProgress,
  completed,
  scheduled,
}

enum AutismLikelihood {
  low,
  moderate,
  high,
  unknown,
}

class Assessment {
  final String id;
  final String childProfileId;
  final AssessmentType type;
  final AssessmentStatus status;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final DateTime? scheduledFor;
  final AutismLikelihood likelihood;
  final int? qualityScore;
  final String? videoPath;
  final List<Map<String, dynamic>>? questionnaireResponses;
  
  Assessment({
    required this.id,
    required this.childProfileId,
    required this.type,
    this.status = AssessmentStatus.notStarted,
    this.createdAt,
    this.completedAt,
    this.scheduledFor,
    this.likelihood = AutismLikelihood.unknown,
    this.qualityScore,
    this.videoPath,
    this.questionnaireResponses,
  });

  Assessment copyWith({
    String? id,
    String? childProfileId,
    AssessmentType? type,
    AssessmentStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? scheduledFor,
    AutismLikelihood? likelihood,
    int? qualityScore,
    String? videoPath,
    List<Map<String, dynamic>>? questionnaireResponses,
  }) {
    return Assessment(
      id: id ?? this.id,
      childProfileId: childProfileId ?? this.childProfileId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      likelihood: likelihood ?? this.likelihood,
      qualityScore: qualityScore ?? this.qualityScore,
      videoPath: videoPath ?? this.videoPath,
      questionnaireResponses: questionnaireResponses ?? this.questionnaireResponses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childProfileId': childProfileId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'likelihood': likelihood.toString().split('.').last,
      'qualityScore': qualityScore,
      'videoPath': videoPath,
      'questionnaireResponses': questionnaireResponses,
    };
  }

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'],
      childProfileId: json['childProfileId'],
      type: AssessmentType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
        orElse: () => AssessmentType.toddler,
      ),
      status: AssessmentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == json['status'],
        orElse: () => AssessmentStatus.notStarted,
      ),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      scheduledFor: json['scheduledFor'] != null 
          ? DateTime.parse(json['scheduledFor']) 
          : null,
      likelihood: AutismLikelihood.values.firstWhere(
        (likelihood) => likelihood.toString().split('.').last == json['likelihood'],
        orElse: () => AutismLikelihood.unknown,
      ),
      qualityScore: json['qualityScore'],
      videoPath: json['videoPath'],
      questionnaireResponses: json['questionnaireResponses'] != null
          ? List<Map<String, dynamic>>.from(json['questionnaireResponses'])
          : null,
    );
  }
} 