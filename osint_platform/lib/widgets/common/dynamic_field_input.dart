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

          // B.7 Tecnologías Web
          {'label': 'Servidor web', 'hint': 'Apache, Nginx, IIS', 'icon': Icons.storage, 'required': false},
          {'label': 'Frameworks de aplicación', 'hint': 'React, Angular, Laravel', 'icon': Icons.web, 'required': false},
          {'label': 'CMS identificado', 'hint': 'WordPress, Drupal, Joomla', 'icon': Icons.dashboard, 'required': false},
          {'label': 'Librerías JavaScript', 'hint': 'jQuery, Bootstrap', 'icon': Icons.code, 'required': false},
          {'label': 'CDN utilizado', 'hint': 'Cloudflare, Akamai', 'icon': Icons.cloud_queue, 'required': false},
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
        ];
    }
  }
}
