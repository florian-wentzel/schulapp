class CustomFeedback {
  CustomFeedback({
    this.feedbackType,
    this.feedbackText,
    this.rating,
  });

  FeedbackType? feedbackType;
  String? feedbackText;
  FeedbackRating? rating;

  @override
  String toString() {
    return {
      if (rating != null) 'rating': rating.toString(),
      'feedback_type': feedbackType.toString(),
      'feedback_text': feedbackText,
    }.toString();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (rating != null) 'rating': rating.toString(),
      'feedback_type': feedbackType.toString(),
      'feedback_text': feedbackText,
    };
  }
}

enum FeedbackType {
  bugReport,
  featureRequest,
}

enum FeedbackRating {
  bad,
  neutral,
  good,
}
