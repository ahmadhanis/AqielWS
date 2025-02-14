class Facility {
  String? facilityId;
  String? facilityName;
  String? facilityPic;
  String? facilityType;
  String? facilityStatus;
  String? facilityCapacity;
  String? dateCreated;

  Facility(
      {this.facilityId,
      this.facilityName,
      this.facilityPic,
      this.facilityType,
      this.facilityStatus,
      this.facilityCapacity,
      this.dateCreated});

  Facility.fromJson(Map<String, dynamic> json) {
    facilityId = json['facility_id'];
    facilityName = json['facility_name'];
    facilityPic = json['facility_pic'];
    facilityType = json['facility_type'];
    facilityStatus = json['facility_status'];
    facilityCapacity = json['facility_capacity'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['facility_id'] = facilityId;
    data['facility_name'] = facilityName;
    data['facility_pic'] = facilityPic;
    data['facility_type'] = facilityType;
    data['facility_status'] = facilityStatus;
    data['facility_capacity'] = facilityCapacity;
    data['date_created'] = dateCreated;
    return data;
  }
}
