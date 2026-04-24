class ReportRequest {
  final String contentId;
  final String reason;
  final String details;
  final String name;
  final String email;
  final String url;
  final List<String> violations;

  ReportRequest({
    required this.contentId,
    required this.reason,
    required this.details,
    required this.name,
    required this.email,
    required this.url,
    required this.violations,
  });

  Map<String, dynamic> toJson() {
    return {
      "contentId": contentId,
      "reason": reason,
      "details": details,
      "name": name,
      "email": email,
      "url": url,
      "violations": violations,
    };
  }
}