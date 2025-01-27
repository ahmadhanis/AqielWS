class Item {
  String? itemId;
  String? email;
  String? phone;
  String? itemStatus;
  String? itemName;
  String? itemDescription;
  String? price;
  String? itemDate;

  Item(
      {this.itemId,
      this.email,
      this.phone,
      this.itemStatus,
      this.itemName,
      this.itemDescription,
      this.price,
      this.itemDate});

  Item.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'];
    email = json['email'];
    phone = json['phone'];
    itemStatus = json['item_status'];
    itemName = json['item_name'];
    itemDescription = json['item_description'];
    price = json['price'];
    itemDate = json['item_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item_id'] = itemId;
    data['email'] = email;
    data['phone'] = phone;
    data['item_status'] = itemStatus;
    data['item_name'] = itemName;
    data['item_description'] = itemDescription;
    data['price'] = price;
    data['item_date'] = itemDate;
    return data;
  }
}
