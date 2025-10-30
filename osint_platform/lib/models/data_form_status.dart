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
  // CATEGORÍA A: DATOS PERSONALES
  personalData('Datos Personales', 'Identificación, contacto, biografía, educación, finanzas personales, historial legal'),

  // CATEGORÍA B: DATOS DIGITALES
  digitalData('Datos Digitales', 'Infraestructura de red, dominios, DNS, certificados SSL, emails, cuentas de usuario, IOCs'),

  // CATEGORÍA C: DATOS GEOGRÁFICOS
  geographicData('Datos Geográficos', 'Ubicaciones, coordenadas, imágenes satelitales, tracking, propiedades inmobiliarias'),

  // CATEGORÍA D: DATOS TEMPORALES
  temporalData('Datos Temporales', 'Timestamps, cronologías, edad y antigüedad de datos'),

  // CATEGORÍA E: DATOS FINANCIEROS
  financialData('Datos Financieros', 'Información bancaria, criptomonedas, inversiones, obligaciones, crédito'),

  // CATEGORÍA F: DATOS DE REDES SOCIALES
  socialMediaData('Datos de Redes Sociales', 'Perfiles, contenido publicado, engagement, red de conexiones, actividad'),

  // CATEGORÍA G: DATOS MULTIMEDIA
  multimediaData('Datos Multimedia', 'Imágenes, videos, audio, documentos y sus metadatos'),

  // CATEGORÍA H: DATOS TÉCNICOS
  technicalData('Datos Técnicos', 'Hashes, certificados, metadatos de sistema, logs, configuraciones'),

  // CATEGORÍA I: DATOS CORPORATIVOS
  corporateData('Datos Corporativos', 'Información empresarial, estructura, finanzas corporativas, empleados');

  final String displayName;
  final String description;

  const DataFormCategory(this.displayName, this.description);
}
