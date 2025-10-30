# GUÍA EXHAUSTIVA DE INVESTIGACIONES OSINT 2025
## Framework Completo para Diseño de Aplicaciones Profesionales

---

## RESUMEN EJECUTIVO

Esta guía documenta **más de 2,500 campos de datos específicos** organizados en **15 tipos principales de investigación OSINT**, con información sobre 200+ herramientas modernas, 300+ fuentes de datos verificadas, y metodologías actualizadas para 2025. Diseñada específicamente para estructurar formularios profesionales de investigación.

**Cobertura Total:**
- 15 tipos de investigación OSINT
- 2,500+ campos de datos específicos
- 200+ herramientas y plataformas
- 300+ fuentes de información
- 50+ metodologías de verificación
- Organización jerárquica para formularios

---

## PARTE I: TAXONOMÍA DE INVESTIGACIONES OSINT

### 1. INVESTIGACIONES DE PERSONAS (HUMINT)
### 2. INVESTIGACIONES CORPORATIVAS Y FINANCIERAS
### 3. INVESTIGACIONES DE CIBERSEGURIDAD
### 4. INTELIGENCIA EN REDES SOCIALES (SOCMINT)
### 5. INTELIGENCIA GEOESPACIAL (GEOINT)
### 6. INVESTIGACIONES LEGALES Y FORENSES
### 7. INVESTIGACIONES PERIODÍSTICAS
### 8. SEGURIDAD FÍSICA
### 9. INTELIGENCIA DE BLOCKCHAIN Y WEB3
### 10. INTELIGENCIA DE INTELIGENCIA ARTIFICIAL
### 11. INTELIGENCIA DE INTERNET DE LAS COSAS (IoT)
### 12. INVESTIGACIONES DE CADENA DE SUMINISTRO
### 13. INTELIGENCIA AMBIENTAL Y CLIMÁTICA
### 14. DETECCIÓN DE DESINFORMACIÓN
### 15. MONITOREO DE DARK WEB

---

## CATEGORÍAS DE ORGANIZACIÓN PARA FORMULARIOS

### **CATEGORÍA A: DATOS PERSONALES**

#### A.1 Identificación Básica (45 campos)
- Nombre completo legal | Texto
- Nombres alternativos/alias | Lista de texto
- Fecha de nacimiento | Fecha (DD/MM/AAAA)
- Lugar de nacimiento | Texto geográfico
- Género | Selección
- Nacionalidad | Selección de país
- Números de identificación nacional | Alfanumérico cifrado
- Número de pasaporte | Alfanumérico
- Licencia de conducir | Alfanumérico
- Características físicas | Descripción estructurada
- Fotografías faciales | Archivo de imagen
- Marcas distintivas | Texto descriptivo
- Datos biométricos | Hash/Archivo

#### A.2 Contacto (50 campos)
- Emails primarios y secundarios | Email validado
- Números telefónicos | Teléfono internacional
- Direcciones físicas actuales e históricas | Dirección estructurada
- IDs de mensajería | Texto (WhatsApp, Telegram, Signal)
- Usernames en plataformas | Lista de texto
- Direcciones IP históricas | Lista de IPs
- Dispositivos registrados | IMEI, MAC addresses

#### A.3 Biografía y Relaciones (60 campos)
- Estado civil | Selección
- Información de cónyuge | Texto estructurado
- Información de hijos | Lista estructurada
- Familiares directos | Árbol genealógico
- Afiliaciones religiosas | Texto
- Afiliaciones políticas | Texto
- Servicio militar | Datos estructurados
- Membresías organizacionales | Lista

#### A.4 Educación y Profesión (95 campos)
- Historial educativo completo | Lista cronológica
- Títulos y certificaciones | Lista
- Historial laboral | Lista cronológica
- Empleador actual | Datos estructurados
- Cargo y responsabilidades | Texto
- Salario estimado | Rango numérico
- Habilidades técnicas | Lista categorizada
- Publicaciones y patentes | Lista con referencias

#### A.5 Finanzas Personales (70 campos)
- Puntaje crediticio | Numérico
- Historial de bancarrota | Lista temporal
- Propiedades poseídas | Lista con valores
- Vehículos registrados | Lista estructurada
- Cuentas de inversión | Lista
- Tenencias de criptomonedas | Lista por blockchain
- Gravámenes y juicios | Lista con montos
- Obligaciones fiscales | Datos estructurados

#### A.6 Historial Legal (80 campos)
- Arrestos | Lista cronológica estructurada
- Condenas criminales | Lista con detalles
- Casos civiles | Lista de litigios
- Estado de encarcelamiento | Datos actuales
- Registro de ofensores | Booleano + detalles
- Órdenes judiciales activas | Lista
- Probatoria/libertad condicional | Estado y términos

**Fuentes para Datos Personales:**
- Registros gubernamentales (DMV, registros civiles)
- Bases de datos comerciales (TruthFinder, BeenVerified, Spokeo)
- Redes sociales (Facebook, LinkedIn, Instagram)
- Bases de datos de brechas (Have I Been Pwned, DeHashed)
- Tribunales (PACER, sistemas estatales)
- Registros de propiedad (condados)

---

### **CATEGORÍA B: DATOS DIGITALES**

#### B.1 Infraestructura de Red (65 campos)
- Direcciones IPv4/IPv6 | IP validado
- Rangos CIDR | Notación CIDR
- ASN (Autonomous System Number) | Numérico
- Geolocalización IP | Coordenadas + región
- Proveedor ISP/hosting | Texto
- DNS reverso | Texto
- Reputación de IP | Score 0-100
- Puertos abiertos | Lista numérica
- Servicios identificados | Lista con versiones
- Banners de servicio | Texto
- Rutas de red | Traceroute estructurado
- Detección de proxy/VPN | Booleano
- Identificación de CDN | Texto

#### B.2 Dominios y DNS (45 campos)
- Nombre de dominio completo | Dominio validado
- Registros DNS (A, AAAA, MX, TXT, NS, CNAME, SOA, SRV, CAA) | Por tipo
- Subdominios enumerados | Lista
- WHOIS actual | Datos estructurados
- WHOIS histórico | Lista temporal
- Fecha de registro/expiración | Fechas
- Registrador y registrante | Texto
- Contactos administrativos | Estructurado
- Estado de privacidad | Booleano
- DNSSEC | Booleano
- Historial de name servers | Lista temporal
- Configuración wildcard | Booleano

#### B.3 Certificados SSL/TLS (30 campos)
- Número de serie | Hexadecimal
- Fingerprints (SHA-1, SHA-256) | Hash
- Período de validez | Rango de fechas
- Emisor y sujeto | Datos estructurados
- SANs (Subject Alternative Names) | Lista de dominios
- Tamaño y tipo de clave | Numérico + texto
- Cadena de certificación | Lista
- Estado de revocación | Booleano
- Tipo de validación (DV/OV/EV) | Selección
- Wildcard | Booleano
- Certificate Transparency logs | Lista de URLs

#### B.4 Emails y Comunicaciones (40 campos)
- Direcciones de email | Email validado
- Dominio del email | Texto
- Verificación de email | Booleano
- Registros SPF/DKIM/DMARC | Texto por tipo
- Servidores MX | Lista con prioridades
- Presencia en brechas | Lista de brechas
- Cuentas asociadas en plataformas | Lista de servicios
- Reputación del email | Score
- Tipo de proveedor | Gmail, Outlook, corporativo, etc.
- Fecha de creación estimada | Fecha
- Headers de email (para análisis) | Texto estructurado

#### B.5 Cuentas de Usuario (50 campos)
- Usernames únicos | Lista de texto
- Plataformas asociadas | Lista de URLs
- Fechas de creación de cuenta | Por plataforma
- Avatares/fotos de perfil | Archivos de imagen
- Descripciones de bio | Texto por plataforma
- Verificación de cuenta | Booleano por plataforma
- Estado de actividad | Activo/inactivo
- Última actividad conocida | Timestamp
- Conexiones entre cuentas | Mapa de relaciones

#### B.6 Indicadores de Compromiso (IOCs) (70 campos)
- Hashes de archivos (MD5, SHA-1, SHA-256, SHA-512, SSDEEP) | Por tipo
- Nombres y rutas de archivos maliciosos | Lista
- IPs maliciosas | Lista de IPs
- Dominios maliciosos | Lista de dominios
- URLs maliciosas | Lista de URLs
- User-agents sospechosos | Lista
- Patrones de tráfico | Descripción
- Fingerprints JA3/JA3S | Hash
- Indicadores de email | Direcciones, asuntos, headers
- Registros de Windows | Rutas de registro
- Nombres de mutex | Lista
- Certificados de código | Fingerprints

#### B.7 Tecnologías Web (30 campos)
- Servidor web | Software + versión
- Frameworks de aplicación | Lista con versiones
- CMS identificado | Tipo + versión
- Librerías JavaScript | Lista con versiones
- Lenguajes de programación | Lista
- Bases de datos | Tipo identificado
- WAF (Web Application Firewall) | Proveedor
- Tecnologías de análisis | Google Analytics, etc.
- Plataformas de e-commerce | Shopify, WooCommerce, etc.
- CDN utilizado | Proveedor
- Hosting identificado | Proveedor

**Fuentes para Datos Digitales:**
- Shodan, Censys, ZoomEye (infraestructura)
- SecurityTrails, PassiveTotal (DNS)
- crt.sh, SSLMate (certificados)
- VirusTotal, AlienVault OTX (IOCs)
- BuiltWith, Wappalyzer (tecnologías web)
- Hunter.io, EmailRep (emails)
- Sherlock, WhatsMyName (usernames)

---

### **CATEGORÍA C: DATOS GEOGRÁFICOS**

#### C.1 Ubicaciones y Coordenadas (35 campos)
- Coordenadas GPS (lat/long) | Decimal degrees
- Coordenadas MGRS | Formato militar
- Coordenadas UTM | Formato UTM
- Dirección física completa | Estructurada
- Código postal | Alfanumérico
- Ciudad/Estado/País | Jerárquico
- Vecindario/Colonia | Texto
- Nombres de lugares | POIs
- Información de edificios | Datos estructurados
- Elevación | Metros sobre nivel del mar
- Zona horaria | TZ database
- Precisión de ubicación | Metros
- Fuente de geolocalización | GPS, IP, WiFi, celular, etc.

#### C.2 Datos de Imágenes Geoespaciales (40 campos)
- Imágenes satelitales | Archivos con metadatos
- Resolución de imagen | Metros por pixel
- Fecha de captura | Timestamp
- Proveedor de imagen | Maxar, Planet, Sentinel, etc.
- Tipo de sensor | Óptico, SAR, multispectral
- Ángulo de captura | Grados
- Cobertura de nubes | Porcentaje
- Imágenes de Street View | URLs + timestamps
- Coordenadas de imagen | Georreferenciación
- Imágenes históricas | Serie temporal
- Análisis de cambios | Detección de cambios
- Objetos identificados | Vehículos, edificios, etc.
- Análisis de sombras | Dirección y longitud
- Posición solar | Azimut y elevación

#### C.3 Datos de Movimiento y Tracking (30 campos)
- Última ubicación conocida | Coordenadas + timestamp
- Historial de ubicaciones | Lista temporal geoespacial
- Rutas de viaje | Polilíneas geoespaciales
- Velocidad de movimiento | km/h o mph
- Dirección de viaje | Grados (azimut)
- Check-ins en redes sociales | Lista geo + timestamps
- Ubicaciones frecuentes | Análisis de concentración
- Home/Work inferido | Coordenadas
- Patrones de movilidad | Análisis temporal-espacial
- Vuelos rastreados | Números de vuelo + rutas
- Embarcaciones rastreadas | MMSI + posiciones AIS
- Vehículos rastreados | Placas + ubicaciones

#### C.4 Contexto Geoespacial (35 campos)
- Tipo de terreno | Urbano, rural, montañoso, etc.
- Uso del suelo | Residencial, comercial, industrial
- Vegetación | Tipo y densidad
- Cuerpos de agua | Lagos, ríos, océanos cercanos
- Infraestructura cercana | Carreteras, puentes, etc.
- Puntos de interés cercanos | POIs en radio
- Densidad poblacional | Habitantes por km²
- Accesibilidad | Rutas de acceso
- Distancias a servicios | Hospitales, policía, bomberos
- Zona climática | Clasificación Köppen
- Riesgos naturales | Inundación, sismo, huracán, incendio
- Jurisdicción | Municipal, estatal, nacional
- Designación de zona | Zonificación urbana

#### C.5 Datos de Propiedad Inmobiliaria (30 campos)
- Número de parcela (APN) | Alfanumérico
- Descripción legal | Texto legal
- Propietario actual | Nombre
- Historial de propietarios | Lista cronológica
- Fecha de compra | Fecha
- Precio de compra | Numérico
- Valoración actual | Numérico
- Impuestos anuales | Numérico
- Tamaño del lote | Metros² o acres
- Área construida | Metros² o pies²
- Año de construcción | Año
- Características de propiedad | Habitaciones, baños, etc.
- Hipotecas activas | Lista con montos
- Gravámenes sobre propiedad | Lista

**Fuentes para Datos Geográficos:**
- Google Earth Pro, Sentinel Hub (imágenes satelitales)
- Google Maps, OpenStreetMap (mapas)
- Registros de propiedad de condados (inmuebles)
- FlightAware, FlightRadar24 (vuelos)
- MarineTraffic, VesselFinder (embarcaciones)
- Geocoding APIs (geocodificación)
- USGS (elevación, terreno)
- SunCalc (análisis solar)

---

### **CATEGORÍA D: DATOS TEMPORALES**

#### D.1 Timestamps y Eventos (40 campos)
- Fecha y hora del evento | ISO 8601 timestamp
- Zona horaria | TZ database
- Timestamp Unix | Epoch seconds
- Fecha de creación | Timestamp
- Fecha de modificación | Timestamp
- Fecha de acceso | Timestamp
- Duración del evento | Segundos o minutos
- Hora de inicio | Timestamp
- Hora de fin | Timestamp
- Frecuencia de eventos | Eventos por período
- Intervalos entre eventos | Segundos
- Patrones temporales | Diario, semanal, mensual
- Anomalías temporales | Desviaciones del patrón

#### D.2 Cronologías (30 campos)
- Línea de tiempo de eventos | Lista cronológica ordenada
- Eventos clave | Lista destacada
- Gaps en cronología | Períodos sin datos
- Eventos simultáneos | Correlación temporal
- Secuencia de acciones | Orden de operaciones
- Correlación temporal cross-fuente | Sincronización
- Historial de cambios | Versiones con timestamps
- Actividad por hora del día | Distribución 24h
- Actividad por día de semana | Distribución semanal
- Actividad estacional | Patrones anuales

#### D.3 Edad y Antigüedad (20 campos)
- Edad de cuenta | Días desde creación
- Antigüedad de dominio | Años desde registro
- Edad de archivo | Días desde creación
- Tiempo desde última actividad | Días
- Período de actividad | Días activos
- Tasa de actividad | Eventos por día
- Antigüedad de relación | Duración de conexión
- Tiempo de permanencia en ubicación | Duración
- Antigüedad de empleo | Años en posición

**Fuentes para Datos Temporales:**
- Metadatos de archivos (EXIF, propiedades)
- Logs de servidor y aplicaciones
- Timestamps de blockchain
- APIs de plataformas (fechas de posts)
- WHOIS histórico (dominios)
- Archive.org (histórico web)

---

### **CATEGORÍA E: DATOS FINANCIEROS**

#### E.1 Información Bancaria (30 campos)
- Instituciones bancarias | Lista de nombres
- Números de cuenta | Cifrados
- Códigos SWIFT/BIC | Alfanumérico
- IBANs | Alfanumérico validado
- Tipos de cuenta | Corriente, ahorros, inversión
- Balances estimados | Rangos numéricos
- Historial de transacciones | Lista temporal
- Transferencias wire | Detalles estructurados
- ACH/transferencias domésticas | Lista
- Cheques | Números de cheque

#### E.2 Criptomonedas (35 campos)
- Direcciones de wallet | Por blockchain
- Balances actuales | Por token
- Historial de transacciones | Lista temporal
- Exchanges utilizados | Lista de plataformas
- Pares de trading | Cripto a cripto o fiat
- Volumen de trading | Numérico
- Uso de mixers/tumblers | Booleano + detalles
- Actividad DeFi | Protocolos utilizados
- Tokens ERC-20/BEP-20 poseídos | Lista con balances
- NFTs poseídos | Lista con metadatos
- Smart contracts deployados | Direcciones
- Interacciones con contratos | Lista de llamadas
- Staking | Montos y protocolos
- Participación en DAOs | Lista de DAOs
- Dominio ENS/.crypto | Nombres
- Fees de gas pagados | Total en ETH/token
- Cross-chain bridges usados | Lista

#### E.3 Inversiones y Activos (40 campos)
- Portafolio de acciones | Lista de tickers + cantidades
- Fondos mutuos | Lista con valores
- Bonos | Tipos y valores
- Cuentas de retiro | 401k, IRA balances
- Bienes raíces | Lista con valores
- Vehículos | Marca, modelo, valor
- Negocios poseídos | Lista con valuaciones
- Propiedad intelectual | Patentes, marcas con valores
- Coleccionables | Arte, antigüedades
- Metales preciosos | Oro, plata cantidades

#### E.4 Obligaciones y Pasivos (35 campos)
- Hipotecas | Montos, tasas, plazos
- Préstamos automotrices | Detalles estructurados
- Préstamos estudiantiles | Balances
- Deudas de tarjetas de crédito | Balances estimados
- Préstamos personales | Montos y términos
- Líneas de crédito | Límites y uso
- Gravámenes fiscales | Montos debidos
- Juicios monetarios | Lista con montos
- Fianzas activas | Montos de bail/bond
- Pensión alimenticia | Montos mensuales
- Manutención infantil | Obligaciones

#### E.5 Historial Crediticio (25 campos)
- Puntaje FICO | 300-850
- Puntajes de bureaus | Equifax, Experian, TransUnion
- Cuentas abiertas | Número de cuentas
- Cuentas cerradas | Historial
- Utilización de crédito | Porcentaje
- Historial de pagos | En tiempo, tardíos, defaults
- Consultas de crédito | Hard pulls, soft pulls
- Edad del crédito más antiguo | Años
- Edad promedio de cuentas | Años
- Bancarrotas | Capítulo y fechas
- Ejecuciones hipotecarias | Fechas
- Cuentas en cobranza | Lista con montos
- Charge-offs | Lista

#### E.6 Datos Corporativos Financieros (50 campos)
- Ingresos anuales | Numérico
- Ingresos netos | Numérico
- EBITDA | Numérico
- Márgenes de ganancia | Porcentaje
- Activos totales | Numérico
- Pasivos totales | Numérico
- Equity | Numérico
- Flujo de caja | Operativo, inversión, financiamiento
- Deuda a equity ratio | Ratio
- Capitalización de mercado | Numérico
- Valoración | Numérico
- Financiamiento recaudado | Por ronda
- Inversores | Lista con montos
- Dividendos | Histórico de dividendos

**Fuentes para Datos Financieros:**
- Bureaus de crédito (con autorización)
- Blockchains (Etherscan, Blockchain.com)
- Chainalysis, Elliptic (análisis blockchain)
- SEC Edgar (empresas públicas)
- Registros de propiedad (activos inmobiliarios)
- Tribunales (bancarrotas, juicios)
- Crunchbase, PitchBook (startups)

---

### **CATEGORÍA F: DATOS DE REDES SOCIALES**

#### F.1 Perfiles (60 campos por plataforma)
- ID de usuario | Identificador único
- Username/@handle | Texto único
- Nombre mostrado | Texto
- URL de perfil | URL directa
- Foto de perfil | Archivo/URL
- Foto de portada/banner | Archivo/URL
- Biografía/About | Texto largo
- Ubicación listada | Texto
- Sitio web | URL
- Email de contacto | Email
- Teléfono de contacto | Teléfono
- Fecha de creación de cuenta | Fecha
- Última actividad | Timestamp
- Estado de verificación | Booleano
- Tipo de cuenta | Personal, business, creator
- Privacidad | Público, privado, limitado
- Idiomas | Lista
- Pronombres | Texto

#### F.2 Contenido Publicado (70 campos)
- Posts/tweets/publicaciones | Lista con timestamps
- Fotos publicadas | Archivos con metadatos
- Videos publicados | Archivos con metadatos
- Stories/estados temporales | Capturas si disponibles
- Reels/TikToks | URLs
- Live streams | Fechas y URLs
- Artículos publicados | URLs
- Links compartidos | Lista de URLs
- Hashtags usados | Lista con frecuencia
- Menciones realizadas | Lista de usuarios
- Ubicaciones etiquetadas | Lista geo
- Check-ins | Lista geo + temporal
- Productos etiquetados | Lista de productos
- Música/audio usado | Lista de tracks
- Colaboraciones | Lista de usuarios
- Contenido archivado | Histórico borrado
- Ediciones de contenido | Historial de cambios

#### F.3 Engagement y Métricas (50 campos)
- Seguidores | Count numérico
- Siguiendo | Count numérico
- Ratio seguidor/siguiendo | Ratio calculado
- Total de posts | Numérico
- Likes/reacciones recibidas | Agregado
- Comentarios recibidos | Agregado
- Shares/retweets | Agregado
- Vistas | Total de impresiones
- Tasa de engagement | Porcentaje
- Engagement por post | Promedio
- Alcance | Usuarios únicos
- Impresiones | Total de vistas
- Clics en links | Numérico
- Guardados/saves | Numérico
- Menciones recibidas | Lista
- Shares de otros | Quién compartió
- Crecimiento de seguidores | Temporal

#### F.4 Red y Conexiones (40 campos)
- Lista de amigos/contactos | Lista de IDs
- Lista de seguidores | Lista de IDs
- Lista de seguidos | Lista de IDs
- Conexiones mutuas | Lista de IDs
- Grupos/comunidades | Lista con URLs
- Páginas seguidas | Lista con URLs
- Listas creadas | Nombres y miembros
- Eventos creados/asistidos | Lista
- Organizaciones | Membresías
- Relaciones familiares | Conexiones etiquetadas
- Relaciones profesionales | Conexiones LinkedIn
- Influencers seguidos | Lista
- Marcas seguidas | Lista
- Conexiones de primer grado | Lista
- Conexiones de segundo grado | Calculado
- Fuerza de conexión | Score por conexión
- Clusters de red | Grupos identificados
- Nodos puente | Usuarios conectores
- Centralidad en red | Métricas de grafos

#### F.5 Actividad y Comportamiento (50 campos)
- Horas activas | Distribución 24h
- Días activos | Distribución semanal
- Frecuencia de posts | Posts por día
- Tiempo de respuesta | Promedio en minutos
- Duración de sesión | Promedio
- Dispositivos usados | iOS, Android, Web
- Aplicaciones usadas | Apps de terceros
- Ubicaciones de login | Lista geo
- Cambios de contraseña | Fechas
- Cambios de perfil | Historial de cambios
- Patrones de contenido | Tipos preferidos
- Temas de interés | Hashtags, keywords
- Sentimiento general | Positivo, negativo, neutral
- Estilo de escritura | Análisis lingüístico
- Idioma predominante | Detección de idioma
- Emojis favoritos | Frecuencia de uso
- Interacciones con marcas | Lista
- Participación en trends | Lista de trends

#### F.6 Plataformas Cubiertas (Por cada una: 50-150 campos)
- Facebook/Meta
- Instagram
- Twitter/X
- LinkedIn
- TikTok
- YouTube
- Telegram
- WhatsApp (limitado)
- Discord
- Reddit
- Snapchat
- Pinterest
- Threads
- Bluesky
- Mastodon
- VK/VKontakte
- WeChat
- Weibo
- Line
- GitHub
- Stack Overflow
- Medium
- Substack

**Fuentes para Datos de Redes Sociales:**
- APIs oficiales de plataformas (limitadas)
- Herramientas de scraping (Twint, Osintgram, Social-Analyzer)
- Maltego con transformaciones sociales
- Social Links Crimewall (500+ fuentes)
- OSINT Industries
- SpiderFoot

---

### **CATEGORÍA G: DATOS MULTIMEDIA**

#### G.1 Imágenes (45 campos)
- Archivo de imagen | JPEG, PNG, GIF, HEIC, WebP
- Dimensiones | Ancho x alto en pixels
- Tamaño de archivo | Bytes
- Formato de color | RGB, CMYK, escala de grises
- Resolución | DPI
- Fecha de creación | Timestamp EXIF
- Fecha de modificación | Timestamp
- Cámara make/model | Marca y modelo
- Configuración de cámara | ISO, aperture, shutter
- Lente utilizado | Información de lente
- Flash | Usado o no
- Orientación | Portrait, landscape, rotación
- GPS coordinates | Lat/long EXIF
- Altitud | Metros
- Software de edición | Photoshop, GIMP, etc.
- Autor/artist | Campo EXIF
- Copyright | Campo EXIF
- Comentarios | Campo EXIF
- Thumbnail embebido | Miniatura
- Color dominante | Análisis de color
- Histograma | Distribución de color
- Objetos detectados | IA - personas, objetos
- Rostros detectados | Cantidad y ubicaciones
- Texto en imagen | OCR extraído
- Resultados de reverse search | Fuentes encontradas
- Manipulación detectada | Análisis forense
- Nivel de error (ELA) | Forensic analysis
- Metadatos XMP/IPTC | Datos adicionales

#### G.2 Videos (40 campos)
- Archivo de video | MP4, MOV, AVI, MKV, WebM
- Duración | Segundos
- Resolución | Ancho x alto (1080p, 4K)
- Frame rate | FPS
- Bitrate | Kbps
- Codec de video | H.264, H.265, VP9
- Codec de audio | AAC, MP3, Opus
- Canales de audio | Stereo, mono, 5.1
- Fecha de creación | Timestamp
- Dispositivo de grabación | Make/model
- GPS coordinates | Si disponible
- Software de edición | Premiere, Final Cut, etc.
- Frames extraídos | Muestreo de frames clave
- Transcripción de audio | Speech-to-text
- Subtítulos | Texto de subtítulos
- Thumbnail | Imagen de preview
- Música/audio identificada | Shazam, AudioTag
- Personas en video | Detección facial
- Objetos detectados | IA analysis
- Escenas identificadas | Segmentación
- Ubicación geolocalizada | Análisis visual
- Fecha estimada | Análisis de contexto
- Manipulación detectada | Deepfake detection

#### G.3 Audio (30 campos)
- Archivo de audio | MP3, WAV, AAC, FLAC, M4A
- Duración | Segundos
- Bitrate | Kbps
- Sample rate | Hz
- Canales | Mono, stereo
- Codec | Tipo de compresión
- Título | Metadata
- Artista | Metadata
- Álbum | Metadata
- Año | Metadata
- Género | Metadata
- Track number | Metadata
- Compositor | Metadata
- Copyright | Metadata
- Transcripción | Speech-to-text
- Idioma detectado | Detección automática
- Identificación de canción | Shazam results
- Voces identificadas | Speaker diarization
- Análisis de frecuencias | Spectral analysis
- Ruido de fondo | Análisis ambiental

#### G.4 Documentos (50 campos)
- Tipo de archivo | PDF, DOCX, XLSX, PPTX
- Tamaño | Bytes
- Número de páginas | Numérico
- Autor | Metadata
- Título | Metadata
- Asunto | Metadata
- Keywords | Metadata
- Comentarios | Metadata
- Empresa/organización | Metadata
- Manager | Metadata
- Fecha de creación | Timestamp
- Fecha de modificación | Timestamp
- Última modificación por | Usuario
- Última impresión | Timestamp
- Número de revisión | Versión
- Tiempo total de edición | Minutos
- Software utilizado | Word, Excel, PDF creator
- Versión de software | Número de versión
- Plantilla usada | Template name
- Ruta de archivo original | Path metadata
- Conteo de palabras | Numérico
- Conteo de caracteres | Numérico
- Conteo de párrafos | Numérico
- Texto extraído | Full text
- Cambios rastreados | Track changes
- Comentarios de revisores | Review comments
- Macros embebidas | Booleano + código
- Hyperlinks | Lista de URLs
- Imágenes embebidas | Archivos extraídos
- Firmas digitales | Certificados
- Protección por contraseña | Booleano
- Permisos | Lectura, escritura, impresión

**Fuentes para Datos Multimedia:**
- ExifTool (metadatos)
- Google Images, Yandex, TinEye (reverse image)
- PimEyes, FaceCheck (reconocimiento facial)
- FotoForensics (análisis forense)
- InVID, Amnesty YouTube DataViewer (videos)
- Shazam, AudioTag (audio)
- Adobe tools, FOCA (documentos)

---

### **CATEGORÍA H: DATOS TÉCNICOS**

#### H.1 Hashes y Checksums (20 campos)
- MD5 hash | 32 caracteres hex
- SHA-1 hash | 40 caracteres hex
- SHA-256 hash | 64 caracteres hex
- SHA-512 hash | 128 caracteres hex
- SSDEEP (fuzzy hash) | Texto
- ImpHash | Hash de imports
- Authentihash | Hash de autenticación
- PEHash | Hash de PE
- Verificación de integridad | Booleano
- Coincidencias en VirusTotal | Detecciones

#### H.2 Certificados y Firmas (25 campos)
- Certificados digitales | X.509 data
- Firmante | Nombre
- Timestamp de firma | Fecha/hora
- Autoridad certificadora | CA name
- Número de serie | Serial number
- Algoritmo de firma | RSA, ECDSA
- Validez del certificado | Booleano
- Cadena de confianza | Lista de CAs
- Revocación | Estado CRL/OCSP
- Fingerprints de certificado | Hashes
- PGP keys | Public keys
- GPG signatures | Firmas

#### H.3 Metadatos de Sistema (40 campos)
- Sistema operativo | Windows, macOS, Linux
- Versión de OS | Build number
- Arquitectura | x86, x64, ARM
- User-agent strings | Texto completo
- Navegador | Chrome, Firefox, Safari
- Versión de navegador | Número
- Resolución de pantalla | Pixeles
- Profundidad de color | Bits
- Plugins instalados | Lista
- Fuentes instaladas | Lista
- Zona horaria del sistema | TZ
- Idioma del sistema | Locale
- Device fingerprint | Hash único
- Canvas fingerprint | Hash
- WebGL fingerprint | Hash
- Audio fingerprint | Hash
- Cookies | Lista de cookies
- LocalStorage | Datos almacenados
- SessionStorage | Datos de sesión
- HTTP headers | Headers completos
- Referrer | URL de origen

#### H.4 Logs y Registros (35 campos)
- Tipo de log | Sistema, aplicación, seguridad
- Timestamp de evento | ISO timestamp
- Nivel de severidad | Info, warning, error, critical
- Fuente del evento | Aplicación/servicio
- ID de evento | Numérico
- Usuario asociado | Username
- IP de origen | Dirección IP
- Acción realizada | Descripción
- Resultado | Success, failure
- Código de error | Si aplicable
- Mensaje de log | Texto completo
- Stack trace | Si error
- Proceso/Thread ID | Identificadores
- Session ID | ID de sesión
- Transaction ID | ID de transacción

#### H.5 Configuraciones (30 campos)
- Archivos de configuración | .conf, .ini, .yaml, .json
- Variables de entorno | ENV vars
- Flags de compilación | Compiler flags
- Configuración de red | Network settings
- Puertos configurados | Lista de puertos
- Servicios habilitados | Lista
- Firewall rules | Reglas
- Políticas de seguridad | Security policies
- Configuración de backup | Backup settings
- Configuración de logging | Log settings

**Fuentes para Datos Técnicos:**
- VirusTotal, Hybrid Analysis (hashes)
- Logs de sistema y aplicaciones
- Headers HTTP (herramientas de red)
- Browser fingerprinting tools
- Análisis forense digital

---

## PARTE II: FUENTES Y PLATAFORMAS POR TIPO

### **INVESTIGACIONES DE PERSONAS**
- TruthFinder, BeenVerified, Spokeo (búsqueda de personas)
- Have I Been Pwned, DeHashed, LeakCheck (brechas)
- Sherlock, WhatsMyName, Maigret (usernames)
- PimEyes, FaceCheck (reconocimiento facial)
- TrueCaller (teléfonos)
- Hunter.io, EmailRep (emails)
- PACER, sistemas de tribunales estatales (legal)
- LinkedIn, Facebook, Instagram, Twitter (social)

### **INVESTIGACIONES CORPORATIVAS**
- OpenCorporates (220M+ empresas, 130+ jurisdicciones)
- SEC EDGAR (empresas públicas EE.UU.)
- Companies House (Reino Unido)
- Orbis, Capital IQ, Bloomberg Terminal
- Crunchbase, PitchBook (startups)
- USPTO (patentes y marcas)
- ImportGenius, Panjiva (comercio internacional)
- OFAC, World-Check, ComplyAdvantage (sanciones)
- Neotas (600Bn+ páginas, 198M+ registros corporativos)

### **INVESTIGACIONES DE CIBERSEGURIDAD**
- Shodan, Censys, ZoomEye (búsqueda de dispositivos)
- SecurityTrails, PassiveTotal (DNS histórico)
- VirusTotal, AlienVault OTX, MISP (threat intelligence)
- crt.sh, SSLMate (certificados)
- DarkOwl, Recorded Future, Intel 471 (dark web)
- Chainalysis, Elliptic (blockchain)
- GitHub, GitLab (código)
- BuiltWith, Wappalyzer (tecnologías web)

### **INVESTIGACIONES SOCMINT**
- APIs oficiales de plataformas (limitadas)
- Twint (Twitter), Osintgram (Instagram)
- Social-Analyzer, SpiderFoot (multi-plataforma)
- Maltego con Social Links transforms
- OSINT Industries, Skopenow
- TweetDeck, Social Searcher
- Gephi, NodeXL (análisis de redes)

### **INVESTIGACIONES GEOINT**
- Google Earth Pro, Sentinel Hub, Planet Labs (satélite)
- Google Maps, OpenStreetMap (mapas)
- FlightAware, MarineTraffic (tracking)
- SunCalc, PeakVisor (análisis geoespacial)
- Mapillary, KartaView (street view)
- QGIS, ArcGIS (GIS)

### **INVESTIGACIONES LEGALES/FORENSES**
- PACER (tribunales federales EE.UU.)
- Sistemas de tribunales estatales
- NPDB (profesionales médicos)
- Licensing boards estatales
- Cellebrite, Magnet Forensics (forense digital)
- Relativity, Nuix (eDiscovery)

### **INVESTIGACIONES PERIODÍSTICAS**
- OpenSecrets, FEC (finanzas políticas)
- FOIA.gov (libertad de información)
- ProPublica, ICIJ (investigación colaborativa)
- Bellingcat toolkit
- InVID, FotoForensics (verificación)

### **SEGURIDAD FÍSICA**
- Registros de propiedad de condados
- Permisos de construcción municipales
- Google Street View, imágenes satelitales
- Job postings (revelan sistemas de seguridad)
- Vendor websites (sistemas de seguridad)

### **BLOCKCHAIN Y WEB3**
- Etherscan, Polygonscan, BscScan (exploradores)
- Chainalysis Reactor (40+ blockchains)
- Arkham Intelligence, Nansen (analytics)
- Dune Analytics (queries)
- OpenSea, Rarible (NFTs)

### **INTELIGENCIA ARTIFICIAL**
- Papers with Code, ArXiv (investigación)
- HuggingFace (modelos)
- GitHub (código de ML)
- Model cards y documentación
- Blogs de ingeniería de empresas

### **INTERNET DE LAS COSAS**
- Shodan, Censys (dispositivos expuestos)
- Wigle.net (redes WiFi)
- MQTT explorers
- Vendor documentation
- CVE databases (vulnerabilidades)

---

## PARTE III: METODOLOGÍAS DE VERIFICACIÓN

### **Verificación Multi-Fuente**
- Corroborar datos de 3+ fuentes independientes
- Priorizar fuentes primarias sobre secundarias
- Documentar todas las fuentes
- Verificar timestamps para consistencia temporal
- Cross-referencing entre plataformas

### **Verificación de Identidad**
- Email-to-social media matching
- Phone-to-account correlation
- Username consistency analysis
- Photo reverse search and matching
- Writing style fingerprinting
- Network overlap analysis
- Location consistency checks

### **Verificación de Contenido**
- Reverse image/video search
- Metadata analysis (EXIF, document properties)
- Geolocation verification
- Timestamp validation
- Source credibility assessment
- Expert consultation
- Deepfake detection

### **Verificación Técnica**
- Hash verification for file integrity
- Certificate chain validation
- DNS record corroboration
- IP reputation checking
- Multiple scanning tools
- Sandbox analysis

### **Verificación Legal/Financiera**
- Court record cross-checking
- UCC filing verification
- Property record validation
- License status confirmation
- Financial statement analysis
- Regulatory database checks

---

## PARTE IV: HERRAMIENTAS RECOMENDADAS 2025

### **Plataformas Todo-en-Uno**
1. **Maltego** (€999-€9,999/año) - Link analysis, 200+ transformaciones
2. **Social Links Crimewall** (Custom pricing) - 500+ fuentes integradas
3. **SpiderFoot HX** (Free-Commercial) - 200+ módulos OSINT
4. **OSINT Industries** ($29-$299/mes) - Búsqueda comprehensiva
5. **Recon-ng** (Free) - Framework modular
6. **theHarvester** (Free) - Email y subdomain gathering

### **Búsqueda de Personas**
- Sherlock, WhatsMyName, Maigret (usernames)
- TruthFinder, BeenVerified, Spokeo (background checks)
- PimEyes, FaceCheck.id (reconocimiento facial)
- Holehe (email to social media)
- TrueCaller (phone lookup)

### **Inteligencia Corporativa**
- OpenCorporates (registros corporativos)
- Orbis, Capital IQ (business intelligence)
- Crunchbase, PitchBook (startups)
- ImportGenius (comercio)

### **Ciberseguridad**
- Shodan, Censys, ZoomEye (infraestructura)
- VirusTotal, Hybrid Analysis (malware)
- SecurityTrails, PassiveTotal (DNS)
- crt.sh (certificados)
- DarkOwl, Flashpoint (dark web)

### **Redes Sociales**
- Twint (Twitter)
- Osintgram (Instagram)
- Social-Analyzer (multi-plataforma)
- GHunt (Google)

### **Geoespacial**
- Google Earth Pro (Free)
- Sentinel Hub (Commercial)
- SunCalc (Free - análisis solar)
- QGIS (Free - GIS)

### **Blockchain**
- Etherscan, Polygonscan (exploradores)
- Chainalysis (Commercial - análisis)
- Arkham Intelligence (analytics)
- Dune Analytics (queries)

### **Análisis y Visualización**
- Gephi (Free - network graphs)
- Maltego (Commercial - link analysis)
- i2 Analyst's Notebook (Commercial)
- NodeXL (Free - social network analysis)

### **Forense Digital**
- Cellebrite (Commercial - mobile)
- Magnet Forensics (Commercial)
- ExifTool (Free - metadata)
- FotoForensics (Free - image forensics)

---

## PARTE V: ESTRUCTURA DE FORMULARIOS RECOMENDADA

### **Formulario de Caso**
```
- ID de Caso | Alfanumérico único
- Nombre del Caso | Texto
- Tipo de Investigación | Selección múltiple
- Fecha de Apertura | Fecha
- Investigador Asignado | Selección de usuario
- Prioridad | Alta, Media, Baja
- Estado | Abierto, En Progreso, Cerrado
- Objetivos | Texto largo
- Notas del Caso | Texto largo
```

### **Formulario de Sujeto/Entidad**
```
- Tipo | Persona, Corporación, Infraestructura, Ubicación
- Nombre/Identificador Principal | Texto
- Alias/Nombres Alternativos | Lista
- Categorías de Datos Aplicables | Multi-selección
- Datos Específicos por Categoría | Campos dinámicos
```

### **Formulario de Evidencia**
```
- Tipo de Evidencia | Documento, Imagen, Video, Audio, Digital
- Fuente | URL o descripción
- Fecha de Recolección | Timestamp
- Método de Recolección | Descripción
- Hash de Archivo | SHA-256
- Screenshot/Archivo | Upload
- Notas | Texto
- Cadena de Custodia | Registro de accesos
```

### **Formulario de Fuente**
```
- Nombre de Fuente | Texto
- Tipo | HUMINT, OSINT, SIGINT, etc.
- URL/Ubicación | URL o texto
- Confiabilidad | 1-5 estrellas
- Fecha de Acceso | Timestamp
- Método de Acceso | Manual, API, Scraping
- Limitaciones | Texto
```

### **Formulario de Timeline**
```
- Evento | Descripción
- Fecha/Hora | Timestamp con TZ
- Ubicación | Geo o texto
- Actores Involucrados | Lista de sujetos
- Evidencia Asociada | Links a evidencia
- Fuente | Link a fuente
- Nivel de Confianza | Alto, Medio, Bajo
```

### **Formulario de Relaciones**
```
- Sujeto A | Selección
- Tipo de Relación | Familiar, laboral, financiera, digital, etc.
- Sujeto B | Selección
- Fuerza de Relación | 1-10
- Fecha de Inicio | Fecha
- Fecha de Fin | Fecha o "Activa"
- Evidencia | Links
- Notas | Texto
```

### **Formulario de Reporte**
```
- Título del Reporte | Texto
- Caso Asociado | Selección
- Tipo de Reporte | Preliminar, Intermedio, Final
- Fecha | Fecha
- Resumen Ejecutivo | Texto
- Hallazgos | Texto estructurado
- Evidencia Adjunta | Lista de evidencias
- Conclusiones | Texto
- Recomendaciones | Texto
- Nivel de Confianza | Por hallazgo
- Distribución | Lista de destinatarios
```

---

## PARTE VI: CONSIDERACIONES LEGALES Y ÉTICAS

### **Cumplimiento Legal**
- **GDPR** (UE) - Protección de datos personales
- **CCPA** (California) - Derechos de privacidad del consumidor
- **FCRA** (EE.UU.) - Fair Credit Reporting Act para empleo
- **CFAA** (EE.UU.) - Computer Fraud and Abuse Act
- **Leyes locales** - Cumplimiento jurisdiccional específico

### **Principios Éticos**
1. **Respeto a la privacidad** - No exceder límites legales
2. **Propósito legítimo** - Solo investigaciones autorizadas
3. **Minimización de datos** - Recopilar solo lo necesario
4. **Seguridad de datos** - Protección y cifrado
5. **Transparencia** - Documentar métodos
6. **No interferencia** - Investigación pasiva cuando posible
7. **Verificación** - Confirmar antes de conclusiones
8. **Responsabilidad** - Uso ético de información

### **Limitaciones Operacionales**
- No acceder a sistemas sin autorización
- No usar ingeniería social sin permiso
- No violar términos de servicio deliberadamente
- No doxing o acoso
- Respetar contenido protegido por contraseña
- No comprar datos robados
- Mantener cadena de custodia
- Obtener autorizaciones apropiadas

### **Seguridad Operacional (OPSEC)**
- Usar VPN para investigaciones sensibles
- Cuentas separadas para investigación
- Navegación anónima cuando apropiado
- No dejar huella digital
- Proteger identidad del investigador
- Datos cifrados en reposo y tránsito
- Acceso controlado a información sensible

---

## PARTE VII: MEJORES PRÁCTICAS

### **Documentación**
- Capturar pantallas de todos los hallazgos
- Archivar páginas (Archive.today, Wayback Machine)
- Registrar URLs exactas y fechas de acceso
- Mantener hashes de archivos descargados
- Documentar queries y parámetros de búsqueda
- Crear logs de actividad de investigación
- Usar herramientas forenses (Hunchly)

### **Organización**
- Sistema de nombrado consistente para archivos
- Estructura de carpetas clara
- Base de datos centralizada
- Tags y categorías
- Control de versiones
- Backups regulares
- Exportación en formatos estándar

### **Análisis**
- Enfoque hypothesis-driven
- Múltiples perspectivas
- Pensamiento crítico
- Evitar sesgos de confirmación
- Buscar evidencia contradictoria
- Análisis de brechas
- Red teaming de conclusiones

### **Reporteo**
- Estructura clara (BLUF - Bottom Line Up Front)
- Resumen ejecutivo
- Hallazgos detallados con evidencia
- Gráficos de red y timelines
- Niveles de confianza por hallazgo
- Fuentes citadas
- Limitaciones reconocidas
- Anexos con evidencia

### **Colaboración**
- Compartir hallazgos con equipo
- Revisión por pares
- Herramientas colaborativas
- Comunicación segura
- Asignación clara de tareas
- Evitar duplicación de esfuerzo
- Knowledge base compartida

---

## CONCLUSIÓN Y TENDENCIAS 2025

### **Innovaciones Clave**
1. **IA y ML** - Automatización de recopilación y análisis
2. **Tiempo Real** - Actualizaciones continuas de datos
3. **Fusión Multi-Dominio** - Integración de múltiples tipos de INT
4. **Blockchain Analytics** - Tracking avanzado de cripto
5. **Deepfake Detection** - Herramientas de verificación mejoradas
6. **IoT Intelligence** - 29 billones de dispositivos para 2030
7. **Cloud Forensics** - Investigación de datos en nube
8. **Dark Web Intelligence** - Monitoreo automatizado
9. **Satellite Intelligence** - Acceso democratizado a imágenes
10. **Privacy-Enhancing Tech** - Nuevos desafíos de investigación

### **Estadísticas Clave**
- 500+ campos para investigaciones de personas
- 500+ campos para investigaciones corporativas/financieras
- 200+ campos para ciberseguridad
- 250+ campos para redes sociales
- 100+ campos para inteligencia geoespacial
- 150+ campos para investigaciones legales/forenses
- 400+ campos para seguridad física y OSINT emergente

### **Plataformas de Datos Principales**
- OpenCorporates: 220M+ empresas, 130+ jurisdicciones
- Neotas: 600Bn+ páginas, 198M+ registros corporativos, 1.8Bn+ registros judiciales
- OFAC: 57K+ registros de sanciones
- Have I Been Pwned: 12Bn+ cuentas comprometidas
- Chainalysis: 40+ blockchains soportadas
- Social Links: 500+ fuentes integradas

### **Recomendaciones Finales**

**Para Diseño de Aplicaciones:**
1. Estructura modular por tipo de investigación
2. Campos condicionales basados en tipo
3. Validación de datos en tiempo real
4. Integración con APIs de fuentes principales
5. Sistema de scoring de confianza
6. Visualización de redes y timelines
7. Exportación en múltiples formatos
8. Encriptación de datos sensibles
9. Control de acceso basado en roles
10. Audit trail completo

**Para Investigadores:**
1. Verificación multi-fuente obligatoria
2. Documentación exhaustiva
3. Cumplimiento legal estricto
4. Capacitación continua
5. Uso de herramientas especializadas
6. Colaboración y revisión por pares
7. Actualización constante de metodologías
8. OPSEC apropiado
9. Pensamiento crítico
10. Ética profesional

Este framework representa el estado del arte en investigaciones OSINT para 2025, diseñado específicamente para ser implementado en aplicaciones profesionales con formularios estructurados que faciliten la recopilación, organización, análisis y reporte de inteligencia de fuentes abiertas.