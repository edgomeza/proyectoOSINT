enum DataFormStatus {
  draft('Borrador'),
  collected('Recopilado'),
  inReview('En Revisión'),
  reviewed('Revisado'),
  sent('Enviado');

  final String displayName;

  const DataFormStatus(this.displayName);
}

enum DataFormCategory {
  person('Persona', 'Información de personas'),
  company('Empresa', 'Información de empresas'),
  socialNetwork('Red Social', 'Perfiles y actividad en redes sociales'),
  location('Ubicación', 'Lugares y direcciones'),
  relationship('Relación', 'Conexiones entre entidades'),
  document('Documento', 'Documentos y archivos'),
  event('Evento', 'Eventos y actividades'),
  other('Otro', 'Otros tipos de información');

  final String displayName;
  final String description;

  const DataFormCategory(this.displayName, this.description);
}
