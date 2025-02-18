class BookingSlot {
  String? bookingId;
  String? facilityId;
  String? userEmail;
  String? userName;
  String? bookingDate;
  String? bookingPurpose;
  String? slot8;
  String? slot9;
  String? slot10;
  String? slot11;
  String? slot12;
  String? slot13;
  String? slot14;
  String? slot15;
  String? slot16;
  String? slot17;
  String? slot18;
  String? slot19;
  String? slot20;
  String? slot21;
  String? slot22;
  String? bookingCode;
  String? dateCreated;

  BookingSlot(
      {this.bookingId,
      this.facilityId,
      this.userEmail,
      this.userName,
      this.bookingDate,
      this.bookingPurpose,
      this.slot8,
      this.slot9,
      this.slot10,
      this.slot11,
      this.slot12,
      this.slot13,
      this.slot14,
      this.slot15,
      this.slot16,
      this.slot17,
      this.slot18,
      this.slot19,
      this.slot20,
      this.slot21,
      this.slot22,
      this.bookingCode,
      this.dateCreated});

  BookingSlot.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    facilityId = json['facility_id'];
    userEmail = json['user_email'];
    userName = json['user_name'];
    bookingDate = json['booking_date'];
    bookingPurpose = json['booking_purpose'];
    slot8 = json['slot_8'];
    slot9 = json['slot_9'];
    slot10 = json['slot_10'];
    slot11 = json['slot_11'];
    slot12 = json['slot_12'];
    slot13 = json['slot_13'];
    slot14 = json['slot_14'];
    slot15 = json['slot_15'];
    slot16 = json['slot_16'];
    slot17 = json['slot_17'];
    slot18 = json['slot_18'];
    slot19 = json['slot_19'];
    slot20 = json['slot_20'];
    slot21 = json['slot_21'];
    slot22 = json['slot_22'];
    bookingCode = json['booking_code'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = bookingId;
    data['facility_id'] = facilityId;
    data['user_email'] = userEmail;
    data['user_name'] = userName;
    data['booking_date'] = bookingDate;
    data['booking_purpose'] = bookingPurpose;
    data['slot_8'] = slot8;
    data['slot_9'] = slot9;
    data['slot_10'] = slot10;
    data['slot_11'] = slot11;
    data['slot_12'] = slot12;
    data['slot_13'] = slot13;
    data['slot_14'] = slot14;
    data['slot_15'] = slot15;
    data['slot_16'] = slot16;
    data['slot_17'] = slot17;
    data['slot_18'] = slot18;
    data['slot_19'] = slot19;
    data['slot_20'] = slot20;
    data['slot_21'] = slot21;
    data['slot_22'] = slot22;
    data['booking_code'] = bookingCode;
    data['date_created'] = dateCreated;
    return data;
  }
}
