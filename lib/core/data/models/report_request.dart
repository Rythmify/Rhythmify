class ReportRequest {
  final String resourceId;
  final String resourceType;
  final String reason;
  final String description;

  ReportRequest({
    required this.resourceId,
    this.resourceType = 'track',
    required this.reason,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      "resource_id": resourceId,
      "resource_type": resourceType,
      "reason": reason,
      "description": description,
    };
  }
}
