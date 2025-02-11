class Report {
  String? reportId;
  String? email;
  String? phone;
  String? reportType;
  String? reportTitle;
  String? reportDescription;
  String? reportBuilding;
  String? reportDate;

  Report(
      {this.reportId,
      this.email,
      this.phone,
      this.reportType,
      this.reportTitle,
      this.reportDescription,
      this.reportBuilding,
      this.reportDate});

  Report.fromJson(Map<String, dynamic> json) {
    reportId = json['report_id'];
    email = json['email'];
    phone = json['phone'];
    reportType = json['report_type'];
    reportTitle = json['report_title'];
    reportDescription = json['report_description'];
    reportBuilding = json['report_building'];
    reportDate = json['report_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['report_id'] = reportId;
    data['email'] = email;
    data['phone'] = phone;
    data['report_type'] = reportType;
    data['report_title'] = reportTitle;
    data['report_description'] = reportDescription;
    data['report_building'] = reportBuilding;
    data['report_date'] = reportDate;
    return data;
  }
}
