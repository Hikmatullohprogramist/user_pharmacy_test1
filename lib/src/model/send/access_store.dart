class AccessStore {
  double lat;
  double lng;
  List<ProductsStore> products;

  AccessStore({
    required this.lat,
    required this.lng,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['products'] = this.products.map((v) => v.toJson()).toList();
    return data;
  }
}

class ProductsStore {
  int drugId;
  int qty;

  ProductsStore({required this.drugId, required this.qty});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['drug_id'] = this.drugId;
    data['qty'] = this.qty;
    return data;
  }
}
