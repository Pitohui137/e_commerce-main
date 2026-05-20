enum OrderStatus {
  prosesPengantaran,
  diterima,
}

extension OrderStatusX on OrderStatus {
  String get dbValue => switch (this) {
        OrderStatus.prosesPengantaran => 'proses_pengantaran',
        OrderStatus.diterima => 'diterima',
      };

  String get label => switch (this) {
        OrderStatus.prosesPengantaran => 'Proses pengantaran',
        OrderStatus.diterima => 'Diterima',
      };

  static OrderStatus fromDb(String value) {
    switch (value) {
      case 'diterima':
        return OrderStatus.diterima;
      case 'proses_pengantaran':
      default:
        return OrderStatus.prosesPengantaran;
    }
  }
}
