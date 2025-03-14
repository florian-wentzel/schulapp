class CustomFeedback {
  static const feedbackTypeKey = "feedbackType";
  static const feedbackTextKey = "feedbackText";
  static const appVersionKey = "appVersion";
  static const imageCodeKey = "imageCode";

  CustomFeedback({
    required this.feedbackType,
    required this.feedbackText,
    required this.appVersion,
  });

  FeedbackType feedbackType;
  String feedbackText;
  String appVersion;

  Map<String, dynamic> toJson() {
    return {
      feedbackTypeKey: feedbackType.toString(),
      feedbackTextKey: feedbackText,
      appVersionKey: appVersion,
    };
  }
}

enum FeedbackType {
  bugReport,
  featureRequest,
  generlFeedback,
}
