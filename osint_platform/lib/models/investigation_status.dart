enum InvestigationStatus {
  active('Activa', 'active'),
  inactive('Inactiva', 'inactive'),
  closed('Cerrada', 'closed');

  final String displayName;
  final String value;

  const InvestigationStatus(this.displayName, this.value);
}
