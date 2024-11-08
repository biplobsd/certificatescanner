class Certificate {
  final String? examinationTitle;
  final String? groupName;
  final String? rollNumber;
  final String? yearOfPassing;
  final String? result;

  Certificate(
      {this.examinationTitle,
      this.groupName,
      this.rollNumber,
      this.yearOfPassing,
      this.result});

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      examinationTitle: json['examination_title'],
      groupName: json['group_name'],
      rollNumber: json['roll_number'],
      yearOfPassing: json['year_of_passing'],
      result: json['result'],
    );
  }
}
