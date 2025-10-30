import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/data_form_status.dart';

class DynamicFieldInput extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool isRequired;
  final VoidCallback? onRemove;
  final IconData? icon;

  const DynamicFieldInput({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.isRequired = false,
    this.onRemove,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: onRemove != null
              ? IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: onRemove,
                  tooltip: 'Eliminar campo',
                )
              : null,
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo es requerido';
                }
                return null;
              }
            : null,
      ),
    );
  }
}

class CategoryFieldsGenerator {
  static List<Map<String, dynamic>> getDefaultFields(DataFormCategory category) {
    switch (category) {
      // CATEGORÍA A: DATOS PERSONALES
      case DataFormCategory.personalData:
        return [
          // A.1 Identificación Básica
          {'label': 'Nombre completo legal', 'hint': 'Nombre completo', 'icon': Icons.person, 'required': true},
          {'label': 'Nombres alternativos/alias', 'hint': 'Apodos, seudónimos', 'icon': Icons.person_outline, 'required': false},
          {'label': 'Fecha de nacimiento', 'hint': 'DD/MM/AAAA', 'icon': Icons.cake, 'required': false},
          {'label': 'Lugar de nacimiento', 'hint': 'Ciudad, país', 'icon': Icons.location_city, 'required': false},
          {'label': 'Género', 'hint': 'Género', 'icon': Icons.wc, 'required': false},
          {'label': 'Nacionalidad', 'hint': 'País de nacionalidad', 'icon': Icons.flag, 'required': false},
          {'label': 'Números de identificación nacional', 'hint': 'DNI, NIF, Pasaporte', 'icon': Icons.badge, 'required': false},
          {'label': 'Características físicas', 'hint': 'Altura, peso, color de ojos, cabello', 'icon': Icons.face, 'required': false},
          {'label': 'Marcas distintivas', 'hint': 'Tatuajes, cicatrices', 'icon': Icons.person_pin, 'required': false},

          // A.2 Contacto
          {'label': 'Email principal', 'hint': 'correo@ejemplo.com', 'icon': Icons.email, 'required': false},
          {'label': 'Emails secundarios', 'hint': 'Otros emails separados por coma', 'icon': Icons.alternate_email, 'required': false},
          {'label': 'Teléfono móvil', 'hint': '+XX XXX XXX XXX', 'icon': Icons.phone_android, 'required': false},
          {'label': 'Teléfono fijo', 'hint': '+XX XXX XXX XXX', 'icon': Icons.phone, 'required': false},
          {'label': 'Dirección física actual', 'hint': 'Calle, número, ciudad, CP', 'icon': Icons.home, 'required': false},
          {'label': 'Direcciones físicas históricas', 'hint': 'Direcciones anteriores', 'icon': Icons.history, 'required': false},
          {'label': 'IDs de mensajería', 'hint': 'WhatsApp, Telegram, Signal', 'icon': Icons.message, 'required': false},
          {'label': 'Usernames en plataformas', 'hint': 'Usuarios en redes sociales', 'icon': Icons.account_circle, 'required': false},

          // A.3 Biografía y Relaciones
          {'label': 'Estado civil', 'hint': 'Soltero, casado, divorciado', 'icon': Icons.favorite, 'required': false},
          {'label': 'Información de cónyuge', 'hint': 'Nombre del cónyuge', 'icon': Icons.people, 'required': false},
          {'label': 'Información de hijos', 'hint': 'Nombres y edades', 'icon': Icons.child_care, 'required': false},
          {'label': 'Familiares directos', 'hint': 'Padres, hermanos', 'icon': Icons.family_restroom, 'required': false},
          {'label': 'Afiliaciones religiosas', 'hint': 'Religión', 'icon': Icons.church, 'required': false},
          {'label': 'Afiliaciones políticas', 'hint': 'Partido político', 'icon': Icons.how_to_vote, 'required': false},

          // A.4 Educación y Profesión
          {'label': 'Educación actual/última', 'hint': 'Universidad, título', 'icon': Icons.school, 'required': false},
          {'label': 'Historial educativo', 'hint': 'Instituciones educativas', 'icon': Icons.history_edu, 'required': false},
          {'label': 'Títulos y certificaciones', 'hint': 'Grados, certificados', 'icon': Icons.workspace_premium, 'required': false},
          {'label': 'Empleador actual', 'hint': 'Empresa actual', 'icon': Icons.business, 'required': false},
          {'label': 'Cargo actual', 'hint': 'Puesto de trabajo', 'icon': Icons.work, 'required': false},
          {'label': 'Historial laboral', 'hint': 'Empleos anteriores', 'icon': Icons.work_history, 'required': false},
          {'label': 'Habilidades técnicas', 'hint': 'Competencias profesionales', 'icon': Icons.engineering, 'required': false},
          {'label': 'Publicaciones y patentes', 'hint': 'Artículos, invenciones', 'icon': Icons.article, 'required': false},

          // A.5 Finanzas Personales
          {'label': 'Rango de ingresos estimado', 'hint': 'Salario anual estimado', 'icon': Icons.attach_money, 'required': false},
          {'label': 'Propiedades poseídas', 'hint': 'Inmuebles', 'icon': Icons.house, 'required': false},
          {'label': 'Vehículos registrados', 'hint': 'Marca, modelo, año', 'icon': Icons.directions_car, 'required': false},

          // A.6 Historial Legal
          {'label': 'Arrestos', 'hint': 'Historial de arrestos', 'icon': Icons.gavel, 'required': false},
          {'label': 'Condenas criminales', 'hint': 'Condenas penales', 'icon': Icons.policy, 'required': false},
          {'label': 'Casos civiles', 'hint': 'Litigios civiles', 'icon': Icons.balance, 'required': false},
          {'label': 'Órdenes judiciales activas', 'hint': 'Órdenes vigentes', 'icon': Icons.warning, 'required': false},
          {'label': 'Estado de encarcelamiento', 'hint': 'Situación carcelaria actual', 'icon': Icons.lock, 'required': false},
          {'label': 'Registro de ofensores', 'hint': 'Registro de delincuentes sexuales u otros', 'icon': Icons.person_off, 'required': false},
          {'label': 'Probatoria/Libertad condicional', 'hint': 'Estado y términos', 'icon': Icons.hourglass_empty, 'required': false},

          // Campos adicionales de identificación
          {'label': 'Licencia de conducir', 'hint': 'Número de licencia', 'icon': Icons.credit_card, 'required': false},
          {'label': 'Número de Seguridad Social', 'hint': 'SSN/Equivalente', 'icon': Icons.security, 'required': false},
          {'label': 'Datos biométricos', 'hint': 'Huellas, iris, ADN', 'icon': Icons.fingerprint, 'required': false},
          {'label': 'Fotografías adicionales', 'hint': 'Otras fotos de identificación', 'icon': Icons.photo_library, 'required': false},

          // A.7 Información adicional completa
          {'label': 'Color de ojos', 'hint': 'Color', 'icon': Icons.visibility, 'required': false},
          {'label': 'Color de cabello', 'hint': 'Color', 'icon': Icons.face, 'required': false},
          {'label': 'Altura', 'hint': 'Centímetros o pies/pulgadas', 'icon': Icons.height, 'required': false},
          {'label': 'Peso', 'hint': 'Kilogramos o libras', 'icon': Icons.monitor_weight, 'required': false},
          {'label': 'Complexión', 'hint': 'Delgado, medio, robusto', 'icon': Icons.accessibility, 'required': false},
          {'label': 'Raza/Etnia', 'hint': 'Origen étnico', 'icon': Icons.people, 'required': false},
          {'label': 'Religión', 'hint': 'Creencia religiosa', 'icon': Icons.temple_buddhist, 'required': false},
          {'label': 'Orientación sexual', 'hint': 'Orientación', 'icon': Icons.favorite, 'required': false},
          {'label': 'Discapacidades', 'hint': 'Discapacidades conocidas', 'icon': Icons.accessible, 'required': false},
          {'label': 'Idiomas hablados', 'hint': 'Lista de idiomas', 'icon': Icons.language, 'required': false},
          {'label': 'Pasatiempos e intereses', 'hint': 'Hobbies', 'icon': Icons.sports_esports, 'required': false},
          {'label': 'Membresías en clubs', 'hint': 'Clubes y organizaciones', 'icon': Icons.card_membership, 'required': false},
          {'label': 'Voluntariado', 'hint': 'Actividades de voluntariado', 'icon': Icons.volunteer_activism, 'required': false},
          {'label': 'Premios y reconocimientos personales', 'hint': 'Premios recibidos', 'icon': Icons.military_tech, 'required': false},
          {'label': 'Referencias personales', 'hint': 'Personas de referencia', 'icon': Icons.contact_phone, 'required': false},
          {'label': 'Seguro médico', 'hint': 'Proveedor de seguro', 'icon': Icons.local_hospital, 'required': false},
          {'label': 'Condiciones médicas', 'hint': 'Condiciones de salud conocidas', 'icon': Icons.medication, 'required': false},
          {'label': 'Alergias', 'hint': 'Alergias conocidas', 'icon': Icons.warning, 'required': false},
          {'label': 'Tipo de sangre', 'hint': 'A+, O-, etc.', 'icon': Icons.bloodtype, 'required': false},
          {'label': 'Donante de órganos', 'hint': 'Si es donante', 'icon': Icons.favorite_border, 'required': false},

          // A.8 Viajes y Movilidad
          {'label': 'Pasaportes', 'hint': 'Números de pasaporte', 'icon': Icons.card_travel, 'required': false},
          {'label': 'Visas', 'hint': 'Visas activas', 'icon': Icons.travel_explore, 'required': false},
          {'label': 'Historial de viajes', 'hint': 'Países visitados', 'icon': Icons.flight, 'required': false},
          {'label': 'Programa de viajero frecuente', 'hint': 'Membresías de aerolíneas', 'icon': Icons.flight_takeoff, 'required': false},
          {'label': 'Restricciones de viaje', 'hint': 'Prohibiciones de entrada', 'icon': Icons.block, 'required': false},

          // A.9 Digital y Tecnología Personal
          {'label': 'Dispositivos personales', 'hint': 'Smartphones, tablets, laptops', 'icon': Icons.devices, 'required': false},
          {'label': 'Números de teléfono históricos', 'hint': 'Números anteriores', 'icon': Icons.phone_disabled, 'required': false},
          {'label': 'Cuentas de email históricas', 'hint': 'Emails antiguos', 'icon': Icons.mail_outline, 'required': false},
          {'label': 'Nombres de usuario históricos', 'hint': 'Usernames anteriores', 'icon': Icons.person_outline, 'required': false},
          {'label': 'IP addresses conocidas', 'hint': 'IPs asociadas', 'icon': Icons.router, 'required': false},

          // A.10 Militar y Servicios
          {'label': 'Servicio militar', 'hint': 'Rama y rango', 'icon': Icons.shield, 'required': false},
          {'label': 'Número de servicio', 'hint': 'Service number', 'icon': Icons.confirmation_number, 'required': false},
          {'label': 'Años de servicio', 'hint': 'Periodo de servicio', 'icon': Icons.date_range, 'required': false},
          {'label': 'Condecoraciones militares', 'hint': 'Medallas y honores', 'icon': Icons.military_tech, 'required': false},
          {'label': 'Status de veterano', 'hint': 'Estado de veterano', 'icon': Icons.flag, 'required': false},

          // A.11 Antecedentes Adicionales
          {'label': 'Compañeros de trabajo', 'hint': 'Colegas conocidos', 'icon': Icons.work_outline, 'required': false},
          {'label': 'Compañeros de escuela', 'hint': 'Exalumnos', 'icon': Icons.school, 'required': false},
          {'label': 'Vecinos', 'hint': 'Vecinos actuales/anteriores', 'icon': Icons.home, 'required': false},
          {'label': 'Socios comerciales', 'hint': 'Personas con negocios compartidos', 'icon': Icons.handshake, 'required': false},
          {'label': 'Referencias profesionales', 'hint': 'Referencias laborales', 'icon': Icons.recommend, 'required': false},
        ];

      // CATEGORÍA B: DATOS DIGITALES
      case DataFormCategory.digitalData:
        return [
          // B.1 Infraestructura de Red
          {'label': 'Direcciones IPv4/IPv6', 'hint': '192.168.1.1 o 2001:db8::1', 'icon': Icons.network_check, 'required': false},
          {'label': 'Rangos CIDR', 'hint': '192.168.1.0/24', 'icon': Icons.dns, 'required': false},
          {'label': 'ASN (Autonomous System Number)', 'hint': 'Número AS', 'icon': Icons.router, 'required': false},
          {'label': 'Geolocalización IP', 'hint': 'País, ciudad de la IP', 'icon': Icons.public, 'required': false},
          {'label': 'Proveedor ISP/hosting', 'hint': 'Proveedor de internet', 'icon': Icons.cloud, 'required': false},
          {'label': 'Puertos abiertos', 'hint': '80, 443, 22', 'icon': Icons.security, 'required': false},
          {'label': 'Servicios identificados', 'hint': 'HTTP, SSH, FTP', 'icon': Icons.settings_ethernet, 'required': false},

          // B.2 Dominios y DNS
          {'label': 'Nombre de dominio', 'hint': 'ejemplo.com', 'icon': Icons.language, 'required': true},
          {'label': 'Registros DNS A', 'hint': 'Dirección IP del dominio', 'icon': Icons.pin_drop, 'required': false},
          {'label': 'Registros DNS MX', 'hint': 'Servidores de correo', 'icon': Icons.mail, 'required': false},
          {'label': 'Registros DNS TXT', 'hint': 'SPF, DKIM, DMARC', 'icon': Icons.text_fields, 'required': false},
          {'label': 'Subdominios enumerados', 'hint': 'www, mail, ftp', 'icon': Icons.subdirectory_arrow_right, 'required': false},
          {'label': 'WHOIS actual', 'hint': 'Información de registro del dominio', 'icon': Icons.info, 'required': false},
          {'label': 'Fecha de registro del dominio', 'hint': 'DD/MM/AAAA', 'icon': Icons.calendar_today, 'required': false},
          {'label': 'Fecha de expiración', 'hint': 'DD/MM/AAAA', 'icon': Icons.event_busy, 'required': false},
          {'label': 'Registrador', 'hint': 'Empresa registradora', 'icon': Icons.business_center, 'required': false},

          // B.3 Certificados SSL/TLS
          {'label': 'Fingerprint SHA-256', 'hint': 'Hash del certificado', 'icon': Icons.fingerprint, 'required': false},
          {'label': 'Emisor del certificado', 'hint': 'CA emisora', 'icon': Icons.verified_user, 'required': false},
          {'label': 'Validez del certificado', 'hint': 'Desde - Hasta', 'icon': Icons.date_range, 'required': false},
          {'label': 'SANs (Subject Alternative Names)', 'hint': 'Dominios alternativos', 'icon': Icons.list_alt, 'required': false},

          // B.4 Emails y Comunicaciones
          {'label': 'Dirección de email', 'hint': 'correo@ejemplo.com', 'icon': Icons.email, 'required': true},
          {'label': 'Dominio del email', 'hint': 'ejemplo.com', 'icon': Icons.alternate_email, 'required': false},
          {'label': 'Verificación de email', 'hint': 'Email verificado o no', 'icon': Icons.check_circle, 'required': false},
          {'label': 'Presencia en brechas de datos', 'hint': 'Brechas conocidas', 'icon': Icons.warning_amber, 'required': false},
          {'label': 'Cuentas asociadas en plataformas', 'hint': 'Servicios registrados', 'icon': Icons.account_tree, 'required': false},

          // B.5 Cuentas de Usuario
          {'label': 'Username único', 'hint': 'Nombre de usuario', 'icon': Icons.person, 'required': true},
          {'label': 'Plataformas asociadas', 'hint': 'Redes sociales, foros', 'icon': Icons.devices, 'required': false},
          {'label': 'Fecha de creación de cuenta', 'hint': 'DD/MM/AAAA', 'icon': Icons.history, 'required': false},
          {'label': 'Última actividad conocida', 'hint': 'Fecha/hora', 'icon': Icons.access_time, 'required': false},
          {'label': 'Estado de la cuenta', 'hint': 'Activa, suspendida, eliminada', 'icon': Icons.toggle_on, 'required': false},

          // B.6 Indicadores de Compromiso (IOCs)
          {'label': 'Hash MD5', 'hint': 'Hash MD5 del archivo', 'icon': Icons.tag, 'required': false},
          {'label': 'Hash SHA-256', 'hint': 'Hash SHA-256 del archivo', 'icon': Icons.vpn_key, 'required': false},
          {'label': 'IPs maliciosas', 'hint': 'Direcciones IP comprometidas', 'icon': Icons.dangerous, 'required': false},
          {'label': 'Dominios maliciosos', 'hint': 'Dominios comprometidos', 'icon': Icons.block, 'required': false},
          {'label': 'URLs maliciosas', 'hint': 'Enlaces maliciosos', 'icon': Icons.link_off, 'required': false},
          {'label': 'Familia de malware', 'hint': 'Tipo de malware identificado', 'icon': Icons.bug_report, 'required': false},
          {'label': 'CVE asociados', 'hint': 'Vulnerabilidades explotadas', 'icon': Icons.security, 'required': false},
          {'label': 'Yara rules', 'hint': 'Reglas Yara que coinciden', 'icon': Icons.rule, 'required': false},
          {'label': 'C2 servers', 'hint': 'Servidores de comando y control', 'icon': Icons.dns, 'required': false},
          {'label': 'Mutex', 'hint': 'Mutex del malware', 'icon': Icons.lock, 'required': false},
          {'label': 'Registry keys', 'hint': 'Claves de registro modificadas', 'icon': Icons.vpn_key, 'required': false},
          {'label': 'File paths', 'hint': 'Rutas de archivos sospechosos', 'icon': Icons.folder, 'required': false},

          // B.7 Tecnologías Web
          {'label': 'Servidor web', 'hint': 'Apache, Nginx, IIS', 'icon': Icons.storage, 'required': false},
          {'label': 'Frameworks de aplicación', 'hint': 'React, Angular, Laravel', 'icon': Icons.web, 'required': false},
          {'label': 'CMS identificado', 'hint': 'WordPress, Drupal, Joomla', 'icon': Icons.dashboard, 'required': false},
          {'label': 'Librerías JavaScript', 'hint': 'jQuery, Bootstrap', 'icon': Icons.code, 'required': false},
          {'label': 'CDN utilizado', 'hint': 'Cloudflare, Akamai', 'icon': Icons.cloud_queue, 'required': false},
          {'label': 'WAF (Web Application Firewall)', 'hint': 'Cloudflare, Imperva, AWS WAF', 'icon': Icons.shield, 'required': false},
          {'label': 'Plataforma de hosting', 'hint': 'AWS, Azure, GCP, DigitalOcean', 'icon': Icons.cloud, 'required': false},
          {'label': 'Tecnologías de análisis', 'hint': 'Google Analytics, Matomo', 'icon': Icons.analytics, 'required': false},
          {'label': 'Plataformas de e-commerce', 'hint': 'Shopify, WooCommerce, Magento', 'icon': Icons.shopping_cart, 'required': false},
          {'label': 'Lenguajes de programación', 'hint': 'PHP, Python, Ruby, Node.js', 'icon': Icons.code, 'required': false},
          {'label': 'Base de datos identificada', 'hint': 'MySQL, PostgreSQL, MongoDB', 'icon': Icons.storage, 'required': false},
          {'label': 'DNS reverso', 'hint': 'PTR record', 'icon': Icons.swap_horiz, 'required': false},
          {'label': 'Reputación de IP', 'hint': 'Score 0-100', 'icon': Icons.grade, 'required': false},
          {'label': 'Banners de servicio', 'hint': 'Banner grabbing', 'icon': Icons.text_snippet, 'required': false},
          {'label': 'Detección de proxy/VPN', 'hint': 'Si usa proxy o VPN', 'icon': Icons.vpn_lock, 'required': false},

          // B.8 APIs y Endpoints
          {'label': 'Endpoints de API', 'hint': 'URLs de API', 'icon': Icons.api, 'required': false},
          {'label': 'Métodos HTTP', 'hint': 'GET, POST, PUT, DELETE', 'icon': Icons.http, 'required': false},
          {'label': 'Autenticación de API', 'hint': 'OAuth, API Key, JWT', 'icon': Icons.vpn_key, 'required': false},
          {'label': 'Rate limits', 'hint': 'Límites de peticiones', 'icon': Icons.speed, 'required': false},
          {'label': 'Versión de API', 'hint': 'v1, v2, etc.', 'icon': Icons.numbers, 'required': false},

          // B.9 Bases de Datos
          {'label': 'Tipo de base de datos', 'hint': 'MySQL, PostgreSQL, MongoDB', 'icon': Icons.storage, 'required': false},
          {'label': 'Versión de DB', 'hint': 'Versión de la base de datos', 'icon': Icons.info, 'required': false},
          {'label': 'Puerto de DB', 'hint': 'Puerto expuesto', 'icon': Icons.input, 'required': false},
          {'label': 'Tablas expuestas', 'hint': 'Nombres de tablas', 'icon': Icons.table_chart, 'required': false},
          {'label': 'Credenciales por defecto', 'hint': 'Si usa credenciales default', 'icon': Icons.warning, 'required': false},

          // B.10 Repositorios de Código
          {'label': 'URL del repositorio', 'hint': 'GitHub, GitLab, Bitbucket', 'icon': Icons.code, 'required': false},
          {'label': 'Commits totales', 'hint': 'Número de commits', 'icon': Icons.commit, 'required': false},
          {'label': 'Contribuidores', 'hint': 'Número de contribuidores', 'icon': Icons.people, 'required': false},
          {'label': 'Issues abiertos', 'hint': 'Número de issues', 'icon': Icons.bug_report, 'required': false},
          {'label': 'Pull requests', 'hint': 'PRs abiertas', 'icon': Icons.merge, 'required': false},
          {'label': 'Lenguajes', 'hint': 'Lenguajes del repositorio', 'icon': Icons.code, 'required': false},
          {'label': 'Licencia', 'hint': 'MIT, GPL, Apache', 'icon': Icons.description, 'required': false},
          {'label': 'Stars/Forks', 'hint': 'Popularidad', 'icon': Icons.star, 'required': false},
          {'label': 'Secretos expuestos', 'hint': 'API keys, passwords', 'icon': Icons.key, 'required': false},

          // B.11 Cloud y Contenedores
          {'label': 'Proveedor cloud', 'hint': 'AWS, Azure, GCP', 'icon': Icons.cloud, 'required': false},
          {'label': 'Región cloud', 'hint': 'us-east-1, eu-west-1', 'icon': Icons.public, 'required': false},
          {'label': 'Buckets S3', 'hint': 'Nombres de buckets', 'icon': Icons.folder_open, 'required': false},
          {'label': 'Buckets públicos', 'hint': 'Buckets sin protección', 'icon': Icons.lock_open, 'required': false},
          {'label': 'Imágenes Docker', 'hint': 'Container images', 'icon': Icons.source, 'required': false},
          {'label': 'Kubernetes clusters', 'hint': 'K8s clusters', 'icon': Icons.cloud_circle, 'required': false},
          {'label': 'Serverless functions', 'hint': 'Lambda, Azure Functions', 'icon': Icons.functions, 'required': false},
        ];

      // CATEGORÍA C: DATOS GEOGRÁFICOS
      case DataFormCategory.geographicData:
        return [
          // C.1 Ubicaciones y Coordenadas
          {'label': 'Coordenadas GPS (lat, long)', 'hint': '40.7128, -74.0060', 'icon': Icons.gps_fixed, 'required': false},
          {'label': 'Dirección física completa', 'hint': 'Calle, número, ciudad, CP, país', 'icon': Icons.location_on, 'required': true},
          {'label': 'Código postal', 'hint': 'CP', 'icon': Icons.markunread_mailbox, 'required': false},
          {'label': 'Ciudad', 'hint': 'Ciudad', 'icon': Icons.location_city, 'required': false},
          {'label': 'Estado/Provincia', 'hint': 'Estado o provincia', 'icon': Icons.map, 'required': false},
          {'label': 'País', 'hint': 'País', 'icon': Icons.flag, 'required': false},
          {'label': 'Vecindario/Colonia', 'hint': 'Barrio', 'icon': Icons.home_work, 'required': false},
          {'label': 'Nombres de lugares', 'hint': 'POIs cercanos', 'icon': Icons.place, 'required': false},
          {'label': 'Elevación', 'hint': 'Metros sobre el nivel del mar', 'icon': Icons.terrain, 'required': false},
          {'label': 'Zona horaria', 'hint': 'GMT-5, UTC+1', 'icon': Icons.access_time, 'required': false},

          // C.2 Datos de Imágenes Geoespaciales
          {'label': 'Proveedor de imagen satelital', 'hint': 'Google Earth, Sentinel, Planet', 'icon': Icons.satellite, 'required': false},
          {'label': 'Fecha de captura de imagen', 'hint': 'DD/MM/AAAA', 'icon': Icons.photo_camera, 'required': false},
          {'label': 'Resolución de imagen', 'hint': 'Metros por pixel', 'icon': Icons.high_quality, 'required': false},
          {'label': 'Tipo de sensor', 'hint': 'Óptico, SAR, multispectral', 'icon': Icons.sensors, 'required': false},

          // C.3 Datos de Movimiento y Tracking
          {'label': 'Última ubicación conocida', 'hint': 'Coordenadas + timestamp', 'icon': Icons.my_location, 'required': false},
          {'label': 'Historial de ubicaciones', 'hint': 'Serie temporal de coordenadas', 'icon': Icons.timeline, 'required': false},
          {'label': 'Velocidad de movimiento', 'hint': 'km/h', 'icon': Icons.speed, 'required': false},
          {'label': 'Dirección de viaje', 'hint': 'Azimut en grados', 'icon': Icons.navigation, 'required': false},
          {'label': 'Check-ins en redes sociales', 'hint': 'Lugares etiquetados', 'icon': Icons.check_circle_outline, 'required': false},

          // C.4 Contexto Geoespacial
          {'label': 'Tipo de terreno', 'hint': 'Urbano, rural, montañoso', 'icon': Icons.landscape, 'required': false},
          {'label': 'Uso del suelo', 'hint': 'Residencial, comercial, industrial', 'icon': Icons.business, 'required': false},
          {'label': 'Puntos de interés cercanos', 'hint': 'POIs en radio de X km', 'icon': Icons.explore, 'required': false},
          {'label': 'Densidad poblacional', 'hint': 'Habitantes por km²', 'icon': Icons.people, 'required': false},

          // C.5 Datos de Propiedad Inmobiliaria
          {'label': 'Número de parcela (APN)', 'hint': 'Identificador catastral', 'icon': Icons.dashboard_customize, 'required': false},
          {'label': 'Propietario actual', 'hint': 'Nombre del propietario', 'icon': Icons.person, 'required': false},
          {'label': 'Fecha de compra', 'hint': 'DD/MM/AAAA', 'icon': Icons.shopping_cart, 'required': false},
          {'label': 'Precio de compra', 'hint': 'Valor en moneda local', 'icon': Icons.attach_money, 'required': false},
          {'label': 'Valoración actual', 'hint': 'Valor actual estimado', 'icon': Icons.price_change, 'required': false},
          {'label': 'Tamaño del lote', 'hint': 'Metros² o acres', 'icon': Icons.straighten, 'required': false},
          {'label': 'Área construida', 'hint': 'Metros² o pies²', 'icon': Icons.square_foot, 'required': false},
          {'label': 'Año de construcción', 'hint': 'AAAA', 'icon': Icons.construction, 'required': false},
          {'label': 'Características de propiedad', 'hint': 'Habitaciones, baños, garaje', 'icon': Icons.home, 'required': false},
          {'label': 'Impuestos anuales', 'hint': 'Monto de impuestos prediales', 'icon': Icons.attach_money, 'required': false},
          {'label': 'Hipotecas activas', 'hint': 'Préstamos hipotecarios', 'icon': Icons.account_balance, 'required': false},
          {'label': 'Gravámenes sobre propiedad', 'hint': 'Gravámenes o embargos', 'icon': Icons.gavel, 'required': false},
          {'label': 'Descripción legal de propiedad', 'hint': 'Descripción legal catastral', 'icon': Icons.description, 'required': false},
          {'label': 'Historial de propietarios', 'hint': 'Propietarios anteriores', 'icon': Icons.history, 'required': false},
          {'label': 'Riesgos naturales de zona', 'hint': 'Inundación, sismo, huracán', 'icon': Icons.warning_amber, 'required': false},
          {'label': 'Zona climática', 'hint': 'Clasificación Köppen', 'icon': Icons.thermostat, 'required': false},
          {'label': 'Jurisdicción legal', 'hint': 'Municipal, estatal, federal', 'icon': Icons.account_balance, 'required': false},
          {'label': 'Designación de zonificación', 'hint': 'Zonificación urbana', 'icon': Icons.map, 'required': false},

          // C.6 Infraestructura y Transporte
          {'label': 'Aeropuertos cercanos', 'hint': 'Aeropuertos en radio', 'icon': Icons.flight, 'required': false},
          {'label': 'Estaciones de tren', 'hint': 'Estaciones ferroviarias', 'icon': Icons.train, 'required': false},
          {'label': 'Puertos marítimos', 'hint': 'Puertos cercanos', 'icon': Icons.directions_boat, 'required': false},
          {'label': 'Carreteras principales', 'hint': 'Autopistas, rutas', 'icon': Icons.route, 'required': false},
          {'label': 'Transporte público', 'hint': 'Metro, bus, tranvía', 'icon': Icons.directions_bus, 'required': false},

          // C.7 Servicios y Amenidades
          {'label': 'Hospitales cercanos', 'hint': 'Hospitales en radio', 'icon': Icons.local_hospital, 'required': false},
          {'label': 'Escuelas cercanas', 'hint': 'Instituciones educativas', 'icon': Icons.school, 'required': false},
          {'label': 'Comisarías', 'hint': 'Estaciones de policía', 'icon': Icons.local_police, 'required': false},
          {'label': 'Estaciones de bomberos', 'hint': 'Bomberos cercanos', 'icon': Icons.fire_truck, 'required': false},
          {'label': 'Centros comerciales', 'hint': 'Shopping centers', 'icon': Icons.shopping_bag, 'required': false},

          // C.8 Análisis Geoespacial
          {'label': 'Índice de vegetación', 'hint': 'NDVI', 'icon': Icons.park, 'required': false},
          {'label': 'Cobertura del suelo', 'hint': 'Land cover classification', 'icon': Icons.terrain, 'required': false},
          {'label': 'Cambios temporales', 'hint': 'Cambios en imágenes satelitales', 'icon': Icons.timeline, 'required': false},
          {'label': 'Análisis de sombras', 'hint': 'Shadow analysis', 'icon': Icons.wb_sunny, 'required': false},
          {'label': 'Distancia a puntos de interés', 'hint': 'Distancias calculadas', 'icon': Icons.social_distance, 'required': false},
        ];

      // CATEGORÍA D: DATOS TEMPORALES
      case DataFormCategory.temporalData:
        return [
          // D.1 Timestamps y Eventos
          {'label': 'Fecha y hora del evento', 'hint': 'DD/MM/AAAA HH:MM:SS', 'icon': Icons.event, 'required': true},
          {'label': 'Zona horaria', 'hint': 'GMT-5, UTC+1', 'icon': Icons.schedule, 'required': false},
          {'label': 'Timestamp Unix', 'hint': 'Epoch seconds', 'icon': Icons.timer, 'required': false},
          {'label': 'Fecha de creación', 'hint': 'DD/MM/AAAA', 'icon': Icons.create, 'required': false},
          {'label': 'Fecha de modificación', 'hint': 'DD/MM/AAAA', 'icon': Icons.edit, 'required': false},
          {'label': 'Fecha de acceso', 'hint': 'DD/MM/AAAA', 'icon': Icons.access_time, 'required': false},
          {'label': 'Duración del evento', 'hint': 'Minutos o segundos', 'icon': Icons.timelapse, 'required': false},

          // D.2 Cronologías
          {'label': 'Descripción del evento', 'hint': 'Qué ocurrió', 'icon': Icons.description, 'required': false},
          {'label': 'Eventos clave relacionados', 'hint': 'Eventos importantes', 'icon': Icons.star, 'required': false},
          {'label': 'Secuencia de acciones', 'hint': 'Orden de operaciones', 'icon': Icons.format_list_numbered, 'required': false},

          // D.3 Edad y Antigüedad
          {'label': 'Edad de cuenta', 'hint': 'Días desde creación', 'icon': Icons.cake, 'required': false},
          {'label': 'Antigüedad de dominio', 'hint': 'Años desde registro', 'icon': Icons.domain, 'required': false},
          {'label': 'Tiempo desde última actividad', 'hint': 'Días', 'icon': Icons.update, 'required': false},
          {'label': 'Edad de archivo', 'hint': 'Días desde creación del archivo', 'icon': Icons.insert_drive_file, 'required': false},
          {'label': 'Período de actividad', 'hint': 'Días activos totales', 'icon': Icons.trending_up, 'required': false},
          {'label': 'Tasa de actividad', 'hint': 'Eventos por día', 'icon': Icons.speed, 'required': false},
          {'label': 'Timestamp Unix (Epoch)', 'hint': 'Segundos desde 1970-01-01', 'icon': Icons.numbers, 'required': false},
          {'label': 'Hora de inicio del evento', 'hint': 'Hora exacta de inicio', 'icon': Icons.play_arrow, 'required': false},
          {'label': 'Hora de fin del evento', 'hint': 'Hora exacta de finalización', 'icon': Icons.stop, 'required': false},
          {'label': 'Intervalos entre eventos', 'hint': 'Segundos o minutos entre eventos', 'icon': Icons.timelapse, 'required': false},
          {'label': 'Patrones temporales', 'hint': 'Diario, semanal, mensual', 'icon': Icons.pattern, 'required': false},
          {'label': 'Anomalías temporales', 'hint': 'Desviaciones del patrón normal', 'icon': Icons.error_outline, 'required': false},
        ];

      // CATEGORÍA E: DATOS FINANCIEROS
      case DataFormCategory.financialData:
        return [
          // E.1 Información Bancaria
          {'label': 'Institución bancaria', 'hint': 'Nombre del banco', 'icon': Icons.account_balance, 'required': false},
          {'label': 'Tipo de cuenta', 'hint': 'Corriente, ahorros, inversión', 'icon': Icons.credit_card, 'required': false},
          {'label': 'Código SWIFT/BIC', 'hint': 'Código internacional', 'icon': Icons.code, 'required': false},
          {'label': 'IBAN', 'hint': 'Número de cuenta internacional', 'icon': Icons.numbers, 'required': false},

          // E.2 Criptomonedas
          {'label': 'Dirección de wallet', 'hint': 'Dirección de billetera cripto', 'icon': Icons.wallet, 'required': true},
          {'label': 'Blockchain', 'hint': 'Bitcoin, Ethereum, etc.', 'icon': Icons.link, 'required': false},
          {'label': 'Balance actual', 'hint': 'Cantidad en cripto', 'icon': Icons.account_balance_wallet, 'required': false},
          {'label': 'Exchanges utilizados', 'hint': 'Binance, Coinbase, etc.', 'icon': Icons.swap_horiz, 'required': false},
          {'label': 'Uso de mixers/tumblers', 'hint': 'Servicios de mezcla', 'icon': Icons.shuffle, 'required': false},
          {'label': 'Tokens poseídos', 'hint': 'ERC-20, BEP-20', 'icon': Icons.token, 'required': false},
          {'label': 'NFTs poseídos', 'hint': 'Tokens no fungibles', 'icon': Icons.photo_library, 'required': false},
          {'label': 'Smart contracts deployados', 'hint': 'Contratos inteligentes', 'icon': Icons.integration_instructions, 'required': false},

          // E.3 Inversiones y Activos
          {'label': 'Portafolio de acciones', 'hint': 'Tickers + cantidades', 'icon': Icons.trending_up, 'required': false},
          {'label': 'Fondos mutuos', 'hint': 'Fondos de inversión', 'icon': Icons.show_chart, 'required': false},
          {'label': 'Bienes raíces', 'hint': 'Propiedades de inversión', 'icon': Icons.home, 'required': false},
          {'label': 'Negocios poseídos', 'hint': 'Empresas propias', 'icon': Icons.business, 'required': false},

          // E.4 Obligaciones y Pasivos
          {'label': 'Hipotecas', 'hint': 'Préstamos hipotecarios', 'icon': Icons.home_work, 'required': false},
          {'label': 'Préstamos automotrices', 'hint': 'Financiamiento de vehículos', 'icon': Icons.directions_car, 'required': false},
          {'label': 'Deudas de tarjetas de crédito', 'hint': 'Saldos pendientes', 'icon': Icons.credit_score, 'required': false},

          // E.5 Historial Crediticio
          {'label': 'Puntaje crediticio', 'hint': '300-850', 'icon': Icons.grade, 'required': false},
          {'label': 'Bancarrotas', 'hint': 'Historial de bancarrotas', 'icon': Icons.money_off, 'required': false},

          // E.6 Datos Corporativos Financieros
          {'label': 'Ingresos anuales', 'hint': 'Revenue anual', 'icon': Icons.attach_money, 'required': false},
          {'label': 'EBITDA', 'hint': 'Ganancias antes de intereses', 'icon': Icons.analytics, 'required': false},
          {'label': 'Capitalización de mercado', 'hint': 'Market cap', 'icon': Icons.pie_chart, 'required': false},
          {'label': 'Financiamiento recaudado', 'hint': 'Rondas de inversión', 'icon': Icons.payments, 'required': false},
          {'label': 'Inversores principales', 'hint': 'VCs, angels', 'icon': Icons.groups, 'required': false},
          {'label': 'Activos totales', 'hint': 'Total assets', 'icon': Icons.account_balance_wallet, 'required': false},
          {'label': 'Pasivos totales', 'hint': 'Total liabilities', 'icon': Icons.money_off, 'required': false},
          {'label': 'Equity patrimonial', 'hint': 'Patrimonio neto', 'icon': Icons.account_balance, 'required': false},
          {'label': 'Flujo de caja operativo', 'hint': 'Operating cash flow', 'icon': Icons.trending_up, 'required': false},
          {'label': 'Deuda a equity ratio', 'hint': 'D/E ratio', 'icon': Icons.calculate, 'required': false},
          {'label': 'Márgenes de ganancia', 'hint': 'Profit margins %', 'icon': Icons.percent, 'required': false},
          {'label': 'Ingresos netos', 'hint': 'Net income', 'icon': Icons.attach_money, 'required': false},
          {'label': 'Valoración actual', 'hint': 'Valuation', 'icon': Icons.price_check, 'required': false},
          {'label': 'Dividendos históricos', 'hint': 'Historial de dividendos', 'icon': Icons.paid, 'required': false},
          {'label': 'Ticker bursátil', 'hint': 'Stock ticker symbol', 'icon': Icons.show_chart, 'required': false},

          // E.7 Transacciones y Movimientos
          {'label': 'Historial de transacciones', 'hint': 'Transacciones registradas', 'icon': Icons.receipt_long, 'required': false},
          {'label': 'Montos promedio de transacción', 'hint': 'Promedio de montos', 'icon': Icons.calculate, 'required': false},
          {'label': 'Frecuencia de transacciones', 'hint': 'Transacciones por mes', 'icon': Icons.sync, 'required': false},
          {'label': 'Transferencias internacionales', 'hint': 'Transferencias cross-border', 'icon': Icons.flight_takeoff, 'required': false},
          {'label': 'Proveedores de pago', 'hint': 'PayPal, Stripe, Wise', 'icon': Icons.payment, 'required': false},

          // E.8 Impuestos y Legal Financiero
          {'label': 'Declaraciones fiscales', 'hint': 'Años de declaración', 'icon': Icons.article, 'required': false},
          {'label': 'Deudas tributarias', 'hint': 'Impuestos pendientes', 'icon': Icons.money_off, 'required': false},
          {'label': 'Auditorías fiscales', 'hint': 'Historial de auditorías', 'icon': Icons.policy, 'required': false},
          {'label': 'Paraísos fiscales', 'hint': 'Cuentas offshore', 'icon': Icons.beach_access, 'required': false},
          {'label': 'Estructuras corporativas complejas', 'hint': 'Holdings, trusts', 'icon': Icons.account_tree, 'required': false},

          // E.9 Seguros y Beneficios
          {'label': 'Pólizas de seguro', 'hint': 'Seguros vigentes', 'icon': Icons.shield, 'required': false},
          {'label': 'Beneficiarios', 'hint': 'Beneficiarios de pólizas', 'icon': Icons.people, 'required': false},
          {'label': 'Pensiones', 'hint': 'Planes de pensión', 'icon': Icons.elderly, 'required': false},
          {'label': 'Fideicomisos', 'hint': 'Trusts establecidos', 'icon': Icons.account_balance, 'required': false},

          // E.10 Criptomonedas Avanzado
          {'label': 'Análisis de transacciones on-chain', 'hint': 'Análisis blockchain', 'icon': Icons.analytics, 'required': false},
          {'label': 'Clustering de direcciones', 'hint': 'Direcciones relacionadas', 'icon': Icons.group_work, 'required': false},
          {'label': 'Participación en DeFi', 'hint': 'Protocolos DeFi', 'icon': Icons.currency_exchange, 'required': false},
          {'label': 'Staking', 'hint': 'Tokens en staking', 'icon': Icons.lock, 'required': false},
          {'label': 'Yield farming', 'hint': 'Farming activo', 'icon': Icons.agriculture, 'required': false},
        ];

      // CATEGORÍA F: DATOS DE REDES SOCIALES
      case DataFormCategory.socialMediaData:
        return [
          // F.1 Perfiles
          {'label': 'Plataforma', 'hint': 'Facebook, Twitter, Instagram, LinkedIn, TikTok', 'icon': Icons.share, 'required': true},
          {'label': 'ID de usuario', 'hint': 'Identificador único', 'icon': Icons.tag, 'required': false},
          {'label': 'Username/@handle', 'hint': '@usuario', 'icon': Icons.alternate_email, 'required': true},
          {'label': 'Nombre mostrado', 'hint': 'Display name', 'icon': Icons.person, 'required': false},
          {'label': 'URL de perfil', 'hint': 'https://...', 'icon': Icons.link, 'required': false},
          {'label': 'Biografía/About', 'hint': 'Descripción del perfil', 'icon': Icons.description, 'required': false},
          {'label': 'Ubicación listada', 'hint': 'Ubicación en perfil', 'icon': Icons.location_on, 'required': false},
          {'label': 'Sitio web', 'hint': 'URL personal o profesional', 'icon': Icons.language, 'required': false},
          {'label': 'Email de contacto', 'hint': 'Email público', 'icon': Icons.email, 'required': false},
          {'label': 'Fecha de creación de cuenta', 'hint': 'DD/MM/AAAA', 'icon': Icons.calendar_today, 'required': false},
          {'label': 'Estado de verificación', 'hint': 'Verificado o no', 'icon': Icons.verified, 'required': false},
          {'label': 'Tipo de cuenta', 'hint': 'Personal, business, creator', 'icon': Icons.account_box, 'required': false},
          {'label': 'Privacidad', 'hint': 'Público, privado', 'icon': Icons.privacy_tip, 'required': false},

          // F.2 Contenido Publicado
          {'label': 'Total de posts/tweets', 'hint': 'Número de publicaciones', 'icon': Icons.post_add, 'required': false},
          {'label': 'Hashtags más usados', 'hint': 'Top hashtags', 'icon': Icons.tag, 'required': false},
          {'label': 'Temas frecuentes', 'hint': 'Temas de publicación', 'icon': Icons.topic, 'required': false},

          // F.3 Engagement y Métricas
          {'label': 'Seguidores', 'hint': 'Número de seguidores', 'icon': Icons.people, 'required': false},
          {'label': 'Siguiendo', 'hint': 'Número de cuentas seguidas', 'icon': Icons.person_add, 'required': false},
          {'label': 'Ratio seguidor/siguiendo', 'hint': 'Ratio calculado', 'icon': Icons.functions, 'required': false},
          {'label': 'Likes/reacciones totales', 'hint': 'Total de likes recibidos', 'icon': Icons.favorite, 'required': false},
          {'label': 'Comentarios totales', 'hint': 'Total de comentarios', 'icon': Icons.comment, 'required': false},
          {'label': 'Shares/retweets', 'hint': 'Total de shares', 'icon': Icons.repeat, 'required': false},
          {'label': 'Tasa de engagement', 'hint': 'Porcentaje de interacción', 'icon': Icons.trending_up, 'required': false},

          // F.4 Red y Conexiones
          {'label': 'Conexiones principales', 'hint': 'Top amigos/seguidos', 'icon': Icons.group, 'required': false},
          {'label': 'Grupos/comunidades', 'hint': 'Grupos a los que pertenece', 'icon': Icons.groups_2, 'required': false},
          {'label': 'Influencers seguidos', 'hint': 'Cuentas influyentes', 'icon': Icons.stars, 'required': false},
          {'label': 'Marcas seguidas', 'hint': 'Marcas de interés', 'icon': Icons.business, 'required': false},

          // F.5 Actividad y Comportamiento
          {'label': 'Horas activas', 'hint': 'Distribución horaria', 'icon': Icons.schedule, 'required': false},
          {'label': 'Días activos', 'hint': 'Días de la semana más activos', 'icon': Icons.date_range, 'required': false},
          {'label': 'Frecuencia de posts', 'hint': 'Posts por día', 'icon': Icons.speed, 'required': false},
          {'label': 'Dispositivos usados', 'hint': 'iOS, Android, Web', 'icon': Icons.devices, 'required': false},
          {'label': 'Sentimiento general', 'hint': 'Positivo, negativo, neutral', 'icon': Icons.sentiment_satisfied, 'required': false},
          {'label': 'Idioma predominante', 'hint': 'Idioma principal', 'icon': Icons.language, 'required': false},
          {'label': 'Tiempo de respuesta promedio', 'hint': 'Minutos de respuesta', 'icon': Icons.timer, 'required': false},
          {'label': 'Duración de sesión', 'hint': 'Tiempo promedio en línea', 'icon': Icons.hourglass_bottom, 'required': false},
          {'label': 'Ubicaciones de login', 'hint': 'Geo de inicios de sesión', 'icon': Icons.location_on, 'required': false},
          {'label': 'Cambios de contraseña', 'hint': 'Fechas de cambios', 'icon': Icons.vpn_key, 'required': false},
          {'label': 'Cambios de perfil históricos', 'hint': 'Historial de cambios', 'icon': Icons.history, 'required': false},
          {'label': 'Estilo de escritura', 'hint': 'Análisis lingüístico', 'icon': Icons.text_fields, 'required': false},
          {'label': 'Emojis favoritos', 'hint': 'Top emojis usados', 'icon': Icons.emoji_emotions, 'required': false},
          {'label': 'Interacciones con marcas', 'hint': 'Marcas con las que interactúa', 'icon': Icons.business, 'required': false},
          {'label': 'Participación en trends', 'hint': 'Hashtags trending', 'icon': Icons.trending_up, 'required': false},
          {'label': 'ID de aplicaciones de terceros', 'hint': 'Apps conectadas', 'icon': Icons.apps, 'required': false},

          // F.6 Contenido y Análisis Avanzado
          {'label': 'Tópicos de interés', 'hint': 'Temas recurrentes', 'icon': Icons.topic, 'required': false},
          {'label': 'Cuentas bloqueadas', 'hint': 'Cuentas que ha bloqueado', 'icon': Icons.block, 'required': false},
          {'label': 'Listas creadas', 'hint': 'Listas de Twitter/X', 'icon': Icons.list, 'required': false},
          {'label': 'Eventos asistidos', 'hint': 'Eventos en Facebook/LinkedIn', 'icon': Icons.event, 'required': false},
          {'label': 'Páginas seguidas', 'hint': 'Páginas de FB', 'icon': Icons.pages, 'required': false},
          {'label': 'Reacciones predominantes', 'hint': 'Like, love, angry', 'icon': Icons.emoji_emotions, 'required': false},
          {'label': 'Stories publicadas', 'hint': 'Frecuencia de stories', 'icon': Icons.auto_stories, 'required': false},
          {'label': 'Lives realizados', 'hint': 'Transmisiones en vivo', 'icon': Icons.live_tv, 'required': false},
          {'label': 'Colaboraciones', 'hint': 'Posts colaborativos', 'icon': Icons.people, 'required': false},
          {'label': 'Menciones recibidas', 'hint': 'Cantidad de menciones', 'icon': Icons.alternate_email, 'required': false},

          // F.7 Seguridad y Privacidad
          {'label': 'Autenticación de dos factores', 'hint': 'Si tiene 2FA', 'icon': Icons.security, 'required': false},
          {'label': 'Emails de recuperación', 'hint': 'Emails alternativos', 'icon': Icons.email, 'required': false},
          {'label': 'Números de recuperación', 'hint': 'Teléfonos de recuperación', 'icon': Icons.phone, 'required': false},
          {'label': 'Sesiones activas', 'hint': 'Dispositivos con sesión', 'icon': Icons.devices, 'required': false},
          {'label': 'Historial de contraseñas', 'hint': 'Cambios de contraseña', 'icon': Icons.history, 'required': false},

          // F.8 Análisis de Red Social
          {'label': 'Centralidad en la red', 'hint': 'Betweenness centrality', 'icon': Icons.hub, 'required': false},
          {'label': 'Comunidades detectadas', 'hint': 'Grupos de amigos', 'icon': Icons.group_work, 'required': false},
          {'label': 'Influenciadores en su red', 'hint': 'Top influencers', 'icon': Icons.stars, 'required': false},
          {'label': 'Puentes entre comunidades', 'hint': 'Bridge nodes', 'icon': Icons.alt_route, 'required': false},
          {'label': 'Grado de conexión', 'hint': 'Degree in network', 'icon': Icons.share, 'required': false},
        ];

      // CATEGORÍA G: DATOS MULTIMEDIA
      case DataFormCategory.multimediaData:
        return [
          // G.1 Imágenes
          {'label': 'Nombre del archivo de imagen', 'hint': 'foto.jpg', 'icon': Icons.image, 'required': true},
          {'label': 'Formato de imagen', 'hint': 'JPEG, PNG, GIF, HEIC', 'icon': Icons.photo, 'required': false},
          {'label': 'Dimensiones', 'hint': 'Ancho x alto en pixels', 'icon': Icons.aspect_ratio, 'required': false},
          {'label': 'Tamaño de archivo', 'hint': 'MB', 'icon': Icons.sd_storage, 'required': false},
          {'label': 'Fecha de creación EXIF', 'hint': 'DD/MM/AAAA HH:MM:SS', 'icon': Icons.date_range, 'required': false},
          {'label': 'Cámara make/model', 'hint': 'Canon, Nikon, iPhone', 'icon': Icons.camera_alt, 'required': false},
          {'label': 'Configuración de cámara', 'hint': 'ISO, aperture, shutter', 'icon': Icons.settings, 'required': false},
          {'label': 'GPS coordinates EXIF', 'hint': 'Lat, Long', 'icon': Icons.gps_fixed, 'required': false},
          {'label': 'Software de edición', 'hint': 'Photoshop, GIMP', 'icon': Icons.edit, 'required': false},
          {'label': 'Objetos detectados', 'hint': 'IA - personas, objetos', 'icon': Icons.visibility, 'required': false},
          {'label': 'Rostros detectados', 'hint': 'Cantidad y ubicaciones', 'icon': Icons.face, 'required': false},
          {'label': 'Texto en imagen (OCR)', 'hint': 'Texto extraído', 'icon': Icons.text_fields, 'required': false},
          {'label': 'Resultados de reverse search', 'hint': 'Fuentes encontradas', 'icon': Icons.search, 'required': false},
          {'label': 'Manipulación detectada', 'hint': 'Análisis forense', 'icon': Icons.warning, 'required': false},

          // G.2 Videos
          {'label': 'Nombre del archivo de video', 'hint': 'video.mp4', 'icon': Icons.video_file, 'required': true},
          {'label': 'Formato de video', 'hint': 'MP4, MOV, AVI', 'icon': Icons.movie, 'required': false},
          {'label': 'Duración', 'hint': 'Segundos o MM:SS', 'icon': Icons.timer, 'required': false},
          {'label': 'Resolución de video', 'hint': '1080p, 4K', 'icon': Icons.high_quality, 'required': false},
          {'label': 'Frame rate', 'hint': 'FPS', 'icon': Icons.speed, 'required': false},
          {'label': 'Codec de video', 'hint': 'H.264, H.265', 'icon': Icons.code, 'required': false},
          {'label': 'Dispositivo de grabación', 'hint': 'Cámara, smartphone', 'icon': Icons.videocam, 'required': false},
          {'label': 'Transcripción de audio', 'hint': 'Speech-to-text', 'icon': Icons.subtitles, 'required': false},
          {'label': 'Personas en video', 'hint': 'Detección facial', 'icon': Icons.people, 'required': false},
          {'label': 'Ubicación geolocalizada', 'hint': 'Análisis visual', 'icon': Icons.map, 'required': false},

          // G.3 Audio
          {'label': 'Nombre del archivo de audio', 'hint': 'audio.mp3', 'icon': Icons.audio_file, 'required': true},
          {'label': 'Formato de audio', 'hint': 'MP3, WAV, AAC', 'icon': Icons.audiotrack, 'required': false},
          {'label': 'Duración de audio', 'hint': 'Segundos o MM:SS', 'icon': Icons.access_time, 'required': false},
          {'label': 'Transcripción', 'hint': 'Texto del audio', 'icon': Icons.record_voice_over, 'required': false},
          {'label': 'Idioma detectado', 'hint': 'Idioma del audio', 'icon': Icons.translate, 'required': false},
          {'label': 'Identificación de canción', 'hint': 'Shazam results', 'icon': Icons.music_note, 'required': false},

          // G.4 Documentos
          {'label': 'Nombre del documento', 'hint': 'documento.pdf', 'icon': Icons.description, 'required': true},
          {'label': 'Tipo de archivo', 'hint': 'PDF, DOCX, XLSX', 'icon': Icons.file_present, 'required': false},
          {'label': 'Número de páginas', 'hint': 'Cantidad', 'icon': Icons.pages, 'required': false},
          {'label': 'Autor (metadata)', 'hint': 'Creador del documento', 'icon': Icons.person, 'required': false},
          {'label': 'Fecha de creación del documento', 'hint': 'DD/MM/AAAA', 'icon': Icons.create, 'required': false},
          {'label': 'Última modificación', 'hint': 'DD/MM/AAAA', 'icon': Icons.edit, 'required': false},
          {'label': 'Software utilizado', 'hint': 'Word, Excel, PDF creator', 'icon': Icons.computer, 'required': false},
          {'label': 'Texto extraído', 'hint': 'Contenido completo', 'icon': Icons.text_snippet, 'required': false},
          {'label': 'Hyperlinks', 'hint': 'URLs en el documento', 'icon': Icons.link, 'required': false},
          {'label': 'Título del documento', 'hint': 'Título en metadata', 'icon': Icons.title, 'required': false},
          {'label': 'Asunto del documento', 'hint': 'Subject en metadata', 'icon': Icons.subject, 'required': false},
          {'label': 'Keywords del documento', 'hint': 'Palabras clave', 'icon': Icons.vpn_key, 'required': false},
          {'label': 'Comentarios en metadata', 'hint': 'Comentarios del autor', 'icon': Icons.comment, 'required': false},
          {'label': 'Empresa/organización', 'hint': 'Company en metadata', 'icon': Icons.business, 'required': false},
          {'label': 'Última impresión', 'hint': 'Fecha de última impresión', 'icon': Icons.print, 'required': false},
          {'label': 'Número de revisión', 'hint': 'Versión del documento', 'icon': Icons.loop, 'required': false},
          {'label': 'Tiempo total de edición', 'hint': 'Minutos editando', 'icon': Icons.edit_note, 'required': false},
          {'label': 'Plantilla usada', 'hint': 'Template name', 'icon': Icons.topic, 'required': false},
          {'label': 'Conteo de palabras', 'hint': 'Total de palabras', 'icon': Icons.short_text, 'required': false},
          {'label': 'Macros embebidas', 'hint': 'Si contiene macros', 'icon': Icons.code, 'required': false},
          {'label': 'Firmas digitales', 'hint': 'Certificados de firma', 'icon': Icons.verified, 'required': false},
          {'label': 'Protección por contraseña', 'hint': 'Si está protegido', 'icon': Icons.lock, 'required': false},
          {'label': 'Idioma del documento', 'hint': 'Idioma detectado', 'icon': Icons.language, 'required': false},
          {'label': 'Versión de formato', 'hint': 'PDF 1.7, DOCX 2016', 'icon': Icons.info, 'required': false},
          {'label': 'Metadatos personalizados', 'hint': 'Custom properties', 'icon': Icons.settings, 'required': false},
          {'label': 'Marcadores/Bookmarks', 'hint': 'Marcadores del PDF', 'icon': Icons.bookmark, 'required': false},
          {'label': 'Anotaciones', 'hint': 'Comentarios y anotaciones', 'icon': Icons.note, 'required': false},
          {'label': 'Capas del documento', 'hint': 'Layers en PDF', 'icon': Icons.layers, 'required': false},
          {'label': 'Scripts embebidos', 'hint': 'JavaScript en PDF', 'icon': Icons.code, 'required': false},
          {'label': 'Formularios', 'hint': 'Si contiene formularios', 'icon': Icons.input, 'required': false},
        ];

      // CATEGORÍA H: DATOS TÉCNICOS
      case DataFormCategory.technicalData:
        return [
          // H.1 Hashes y Checksums
          {'label': 'Hash MD5', 'hint': '32 caracteres hexadecimales', 'icon': Icons.tag, 'required': false},
          {'label': 'Hash SHA-1', 'hint': '40 caracteres hexadecimales', 'icon': Icons.fingerprint, 'required': false},
          {'label': 'Hash SHA-256', 'hint': '64 caracteres hexadecimales', 'icon': Icons.vpn_key, 'required': false},
          {'label': 'Hash SHA-512', 'hint': '128 caracteres hexadecimales', 'icon': Icons.security, 'required': false},
          {'label': 'SSDEEP (fuzzy hash)', 'hint': 'Hash difuso', 'icon': Icons.blur_on, 'required': false},
          {'label': 'Coincidencias en VirusTotal', 'hint': 'Detecciones de malware', 'icon': Icons.bug_report, 'required': false},

          // H.2 Certificados y Firmas
          {'label': 'Certificado digital X.509', 'hint': 'Datos del certificado', 'icon': Icons.verified_user, 'required': false},
          {'label': 'Firmante', 'hint': 'Nombre del firmante', 'icon': Icons.draw, 'required': false},
          {'label': 'Timestamp de firma', 'hint': 'Fecha/hora de firma', 'icon': Icons.access_time, 'required': false},
          {'label': 'Autoridad certificadora', 'hint': 'CA name', 'icon': Icons.admin_panel_settings, 'required': false},
          {'label': 'Validez del certificado', 'hint': 'Válido o revocado', 'icon': Icons.check_circle, 'required': false},

          // H.3 Metadatos de Sistema
          {'label': 'Sistema operativo', 'hint': 'Windows, macOS, Linux', 'icon': Icons.computer, 'required': false},
          {'label': 'Versión de OS', 'hint': 'Build number', 'icon': Icons.info, 'required': false},
          {'label': 'Arquitectura', 'hint': 'x86, x64, ARM', 'icon': Icons.architecture, 'required': false},
          {'label': 'User-agent string', 'hint': 'Identificador de navegador', 'icon': Icons.web, 'required': false},
          {'label': 'Navegador', 'hint': 'Chrome, Firefox, Safari', 'icon': Icons.web_asset, 'required': false},
          {'label': 'Resolución de pantalla', 'hint': 'Pixels', 'icon': Icons.screen_share, 'required': false},
          {'label': 'Zona horaria del sistema', 'hint': 'TZ', 'icon': Icons.public, 'required': false},
          {'label': 'Idioma del sistema', 'hint': 'Locale', 'icon': Icons.language, 'required': false},
          {'label': 'Device fingerprint', 'hint': 'Hash único del dispositivo', 'icon': Icons.fingerprint, 'required': false},

          // H.4 Logs y Registros
          {'label': 'Tipo de log', 'hint': 'Sistema, aplicación, seguridad', 'icon': Icons.list, 'required': false},
          {'label': 'Timestamp de evento', 'hint': 'ISO 8601', 'icon': Icons.event, 'required': false},
          {'label': 'Nivel de severidad', 'hint': 'Info, warning, error, critical', 'icon': Icons.priority_high, 'required': false},
          {'label': 'Fuente del evento', 'hint': 'Aplicación o servicio', 'icon': Icons.source, 'required': false},
          {'label': 'Usuario asociado', 'hint': 'Username', 'icon': Icons.person, 'required': false},
          {'label': 'IP de origen', 'hint': 'Dirección IP', 'icon': Icons.router, 'required': false},
          {'label': 'Acción realizada', 'hint': 'Descripción', 'icon': Icons.play_arrow, 'required': false},
          {'label': 'Resultado', 'hint': 'Success, failure', 'icon': Icons.done_all, 'required': false},

          // H.5 Configuraciones
          {'label': 'Archivo de configuración', 'hint': '.conf, .ini, .yaml, .json', 'icon': Icons.settings, 'required': false},
          {'label': 'Variables de entorno', 'hint': 'ENV vars', 'icon': Icons.code, 'required': false},
          {'label': 'Puertos configurados', 'hint': 'Puertos abiertos', 'icon': Icons.input, 'required': false},
          {'label': 'Servicios habilitados', 'hint': 'Servicios activos', 'icon': Icons.toggle_on, 'required': false},
          {'label': 'Flags de compilación', 'hint': 'Compiler flags', 'icon': Icons.flag, 'required': false},
          {'label': 'Configuración de red', 'hint': 'Network settings', 'icon': Icons.settings_ethernet, 'required': false},
          {'label': 'Firewall rules', 'hint': 'Reglas de firewall', 'icon': Icons.fireplace, 'required': false},
          {'label': 'Políticas de seguridad', 'hint': 'Security policies', 'icon': Icons.security, 'required': false},
          {'label': 'Configuración de backup', 'hint': 'Backup settings', 'icon': Icons.backup, 'required': false},
          {'label': 'Configuración de logging', 'hint': 'Log settings', 'icon': Icons.text_snippet, 'required': false},
          {'label': 'Código de error', 'hint': 'Error code si aplica', 'icon': Icons.error, 'required': false},
          {'label': 'Stack trace', 'hint': 'Traza de error', 'icon': Icons.format_list_numbered, 'required': false},
          {'label': 'Session ID', 'hint': 'ID de sesión', 'icon': Icons.badge, 'required': false},
          {'label': 'Transaction ID', 'hint': 'ID de transacción', 'icon': Icons.receipt, 'required': false},
        ];

      // CATEGORÍA I: DATOS CORPORATIVOS
      case DataFormCategory.corporateData:
        return [
          {'label': 'Nombre de la empresa', 'hint': 'Razón social', 'icon': Icons.business, 'required': true},
          {'label': 'CIF/NIF/Tax ID', 'hint': 'Número de identificación fiscal', 'icon': Icons.badge, 'required': false},
          {'label': 'Fecha de constitución', 'hint': 'DD/MM/AAAA', 'icon': Icons.calendar_today, 'required': false},
          {'label': 'Jurisdicción de registro', 'hint': 'País/Estado', 'icon': Icons.location_on, 'required': false},
          {'label': 'Tipo de entidad', 'hint': 'LLC, SA, SL, Corp', 'icon': Icons.category, 'required': false},
          {'label': 'Sector industrial', 'hint': 'Tecnología, finanzas, etc.', 'icon': Icons.business_center, 'required': false},
          {'label': 'Dirección de sede principal', 'hint': 'Dirección física', 'icon': Icons.location_city, 'required': false},
          {'label': 'Sitio web corporativo', 'hint': 'https://ejemplo.com', 'icon': Icons.language, 'required': false},
          {'label': 'Email corporativo', 'hint': 'info@empresa.com', 'icon': Icons.email, 'required': false},
          {'label': 'Teléfono corporativo', 'hint': '+XX XXX XXX XXX', 'icon': Icons.phone, 'required': false},
          {'label': 'Número de empleados', 'hint': 'Cantidad aproximada', 'icon': Icons.groups, 'required': false},
          {'label': 'CEO/Presidente', 'hint': 'Nombre', 'icon': Icons.person, 'required': false},
          {'label': 'Junta directiva', 'hint': 'Miembros del board', 'icon': Icons.people, 'required': false},
          {'label': 'Estructura de propiedad', 'hint': 'Accionistas principales', 'icon': Icons.pie_chart, 'required': false},
          {'label': 'Empresas subsidiarias', 'hint': 'Filiales', 'icon': Icons.account_tree, 'required': false},
          {'label': 'Empresa matriz', 'hint': 'Parent company', 'icon': Icons.corporate_fare, 'required': false},
          {'label': 'Partners estratégicos', 'hint': 'Socios comerciales', 'icon': Icons.handshake, 'required': false},
          {'label': 'Competidores principales', 'hint': 'Empresas competidoras', 'icon': Icons.trending_up, 'required': false},
          {'label': 'Estado de la empresa', 'hint': 'Activa, disuelta, en quiebra', 'icon': Icons.toggle_on, 'required': false},
          {'label': 'Licencias y permisos', 'hint': 'Licencias operativas', 'icon': Icons.verified, 'required': false},
          {'label': 'Presencia en redes sociales', 'hint': 'Perfiles corporativos', 'icon': Icons.share, 'required': false},
          {'label': 'Código NAICS', 'hint': 'Clasificación industrial', 'icon': Icons.category, 'required': false},
          {'label': 'Código SIC', 'hint': 'Standard Industrial Classification', 'icon': Icons.business, 'required': false},
          {'label': 'DUNS Number', 'hint': 'D&B número', 'icon': Icons.numbers, 'required': false},
          {'label': 'Número de registro corporativo', 'hint': 'Registration number', 'icon': Icons.app_registration, 'required': false},
          {'label': 'Agente registrado', 'hint': 'Registered agent', 'icon': Icons.person_pin, 'required': false},
          {'label': 'Informes anuales', 'hint': 'Annual reports', 'icon': Icons.article, 'required': false},
          {'label': 'Historial de nombres', 'hint': 'Nombres anteriores DBA', 'icon': Icons.history, 'required': false},
          {'label': 'Marcas registradas', 'hint': 'Trademarks', 'icon': Icons.label, 'required': false},
          {'label': 'Patentes poseídas', 'hint': 'Patents', 'icon': Icons.lightbulb, 'required': false},
          {'label': 'Proveedores principales', 'hint': 'Main suppliers', 'icon': Icons.local_shipping, 'required': false},
          {'label': 'Clientes principales', 'hint': 'Major customers', 'icon': Icons.people, 'required': false},
          {'label': 'Certificaciones', 'hint': 'ISO, SOC, etc.', 'icon': Icons.military_tech, 'required': false},
          {'label': 'Premios y reconocimientos', 'hint': 'Awards', 'icon': Icons.emoji_events, 'required': false},
          {'label': 'Historial de fusiones/adquisiciones', 'hint': 'M&A history', 'icon': Icons.merge, 'required': false},
          {'label': 'Litigios activos', 'hint': 'Casos legales pendientes', 'icon': Icons.gavel, 'required': false},
          {'label': 'Sanciones/multas', 'hint': 'Penalizaciones recibidas', 'icon': Icons.warning, 'required': false},
          {'label': 'Políticas corporativas', 'hint': 'Corporate policies', 'icon': Icons.policy, 'required': false},
          {'label': 'Responsabilidad social corporativa', 'hint': 'CSR initiatives', 'icon': Icons.volunteer_activism, 'required': false},
          {'label': 'Impacto ambiental', 'hint': 'Environmental impact', 'icon': Icons.eco, 'required': false},
        ];
    }
  }
}
