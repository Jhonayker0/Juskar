enum OrderSortOption {
  fecha('Fecha de entrega'),
  categoria('Categoría'),
  precio('Precio'),
  cliente('Cliente');

  const OrderSortOption(this.displayName);
  final String displayName;
}
