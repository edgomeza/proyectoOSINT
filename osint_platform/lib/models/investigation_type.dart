import 'data_form_status.dart';

enum InvestigationType {
  people(
    'Investigaciones de Personas (HUMINT)',
    'Información sobre individuos, biografía, contactos, relaciones',
    [
      DataFormCategory.personalData,
      DataFormCategory.digitalData,
      DataFormCategory.geographicData,
      DataFormCategory.temporalData,
      DataFormCategory.financialData,
      DataFormCategory.socialMediaData,
      DataFormCategory.multimediaData,
    ],
  ),
  corporate(
    'Investigaciones Corporativas y Financieras',
    'Empresas, finanzas, inversiones, estructura corporativa',
    [
      DataFormCategory.corporateData,
      DataFormCategory.financialData,
      DataFormCategory.digitalData,
      DataFormCategory.geographicData,
      DataFormCategory.temporalData,
    ],
  ),
  cybersecurity(
    'Investigaciones de Ciberseguridad',
    'Infraestructura, vulnerabilidades, amenazas, IOCs',
    [
      DataFormCategory.digitalData,
      DataFormCategory.technicalData,
      DataFormCategory.temporalData,
    ],
  ),
  socmint(
    'Inteligencia en Redes Sociales (SOCMINT)',
    'Perfiles, contenido, engagement, redes de contactos',
    [
      DataFormCategory.socialMediaData,
      DataFormCategory.digitalData,
      DataFormCategory.multimediaData,
      DataFormCategory.temporalData,
    ],
  ),
  geoint(
    'Inteligencia Geoespacial (GEOINT)',
    'Ubicaciones, coordenadas, imágenes satelitales, tracking',
    [
      DataFormCategory.geographicData,
      DataFormCategory.multimediaData,
      DataFormCategory.temporalData,
    ],
  ),
  legalForensic(
    'Investigaciones Legales y Forenses',
    'Casos legales, evidencia digital, cadena de custodia',
    [
      DataFormCategory.personalData,
      DataFormCategory.digitalData,
      DataFormCategory.multimediaData,
      DataFormCategory.technicalData,
      DataFormCategory.temporalData,
    ],
  ),
  journalistic(
    'Investigaciones Periodísticas',
    'Verificación de hechos, fuentes, investigación de noticias',
    [
      DataFormCategory.personalData,
      DataFormCategory.corporateData,
      DataFormCategory.digitalData,
      DataFormCategory.multimediaData,
      DataFormCategory.temporalData,
    ],
  ),
  physicalSecurity(
    'Seguridad Física',
    'Instalaciones, permisos, sistemas de seguridad',
    [
      DataFormCategory.geographicData,
      DataFormCategory.multimediaData,
      DataFormCategory.temporalData,
    ],
  ),
  blockchain(
    'Inteligencia de Blockchain y Web3',
    'Criptomonedas, wallets, transacciones, smart contracts',
    [
      DataFormCategory.financialData,
      DataFormCategory.digitalData,
      DataFormCategory.technicalData,
      DataFormCategory.temporalData,
    ],
  ),
  ai(
    'Inteligencia de Inteligencia Artificial',
    'Modelos de IA, datasets, capacidades, riesgos',
    [
      DataFormCategory.technicalData,
      DataFormCategory.digitalData,
    ],
  ),
  iot(
    'Inteligencia de Internet de las Cosas (IoT)',
    'Dispositivos conectados, vulnerabilidades, datos de sensores',
    [
      DataFormCategory.technicalData,
      DataFormCategory.digitalData,
      DataFormCategory.geographicData,
    ],
  ),
  supplyChain(
    'Investigaciones de Cadena de Suministro',
    'Proveedores, logística, dependencias, riesgos',
    [
      DataFormCategory.corporateData,
      DataFormCategory.geographicData,
      DataFormCategory.temporalData,
    ],
  ),
  environmental(
    'Inteligencia Ambiental y Climática',
    'Datos ambientales, clima, desastres naturales',
    [
      DataFormCategory.geographicData,
      DataFormCategory.multimediaData,
      DataFormCategory.temporalData,
    ],
  ),
  disinformation(
    'Detección de Desinformación',
    'Fake news, narrativas, propagación, verificación',
    [
      DataFormCategory.socialMediaData,
      DataFormCategory.multimediaData,
      DataFormCategory.digitalData,
      DataFormCategory.temporalData,
    ],
  ),
  darkweb(
    'Monitoreo de Dark Web',
    'Mercados, foros, actores maliciosos, datos filtrados',
    [
      DataFormCategory.digitalData,
      DataFormCategory.technicalData,
      DataFormCategory.temporalData,
    ],
  );

  final String displayName;
  final String description;
  final List<DataFormCategory> relevantCategories;

  const InvestigationType(this.displayName, this.description, this.relevantCategories);
}
