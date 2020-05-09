class Task {
  final int id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String venue;

  Task({
    this.id,
    this.title,
    this.startTime,
    this.endTime,
    this.date,
    this.venue,
  });

  String get taskDate {
    return date;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json["id"] as int,
      title: json["title"],
      date: json["date"],
      startTime: json["start_time"],
      endTime: json["end_time"],
      venue: json["venue"],
    );
  }
}
