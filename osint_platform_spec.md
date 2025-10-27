# Especificación Completa - Plataforma OSINT Local

## 📋 Resumen Ejecutivo

La plataforma OSINT es una herramienta local de organización de conocimiento diseñada para ayudar a investigadores a gestionar eficientemente grandes volúmenes de información sin sufrir sobrecarga cognitiva. La aplicación combina un enfoque simplificado con funcionalidad completa, permitiendo al usuario alternar entre vistas según sus necesidades.

### Características Principales
- **100% Local**: Sin dependencias externas ni riesgo de filtración de datos
- **Gestión Cognitiva**: Reduce la sobrecarga mental mediante organización inteligente
- **Dual View**: Vista simplificada para foco y vista completa para control total
- **ELK Stack Integrado**: Elasticsearch, Kibana y Logstash para análisis avanzado
- **Flutter Cross-Platform**: Aplicación nativa para múltiples sistemas operativos

## 🏗️ Arquitectura del Sistema

### Stack Tecnológico

#### Frontend
- **Flutter/Dart**: Aplicación principal multiplataforma
- **Responsive UI**: Interfaz adaptable a diferentes tamaños de pantalla
- **Material Design**: Componentes consistentes y familiares

#### Backend Local
- **API REST**: Python Flask/FastAPI para operaciones específicas
- **SQLite**: Base de datos local para metadatos y configuraciones
- **Docker Compose**: Orquestación de servicios ELK

#### Servicios de Análisis
- **Elasticsearch**: Motor de búsqueda y almacenamiento de datos procesados
- **Logstash**: Pipeline de procesamiento e ingestión de datos
- **Kibana**: Interfaz de visualización y análisis avanzado

### Arquitectura de Seguridad Local

#### Aislamiento Completo
- **Sin Conexiones Externas**: Bloqueo total de tráfico saliente
- **Cifrado Local**: Todos los datos cifrados en disco
- **Certificados Auto-firmados**: SSL/TLS sin autoridades externas
- **Firewall Integrado**: Reglas restrictivas por defecto

#### Gestión de Datos
- **Backups Cifrados**: Respaldos locales con cifrado fuerte
- **Borrado Seguro**: Eliminación segura de datos sensibles
- **Auditoría Local**: Logs de acceso almacenados localmente
- **Compartimentación**: Cada investigación aislada por seguridad

## 🎯 Filosofía de Diseño: Gestión Cognitiva

### Principios Fundamentales

#### Reducción de Carga Cognitiva
- **Información Progresiva**: Mostrar solo lo relevante en cada momento
- **Límites Saludables**: Máximo 7 elementos por vista (regla 7±2)
- **Contextualización**: Cada dato tiene su lugar y propósito claro
- **Flujo Natural**: Guiar al investigador paso a paso sin abrumar

#### Ayudas Inteligentes
- **Priorización Automática**: El sistema sugiere qué revisar primero
- **Sugerencias Contextuales**: Ayudas basadas en la situación actual
- **Detección de Fatiga**: Monitoreo de patrones para sugerir descansos
- **Navegación Predictiva**: Recomendar próximas acciones lógicas

## 📱 Estructura de la Aplicación

### Modelo de Datos Central

#### Investigación (Investigation)
Representa una investigación completa con las siguientes características:
- **Identificación**: ID único, nombre, descripción, fechas
- **Estado**: Fase actual (planificación, recopilación, procesamiento, análisis, informes)
- **Objetivos**: Lista de metas específicas a cumplir (máximo 3-5)
- **Conocimiento**: Información ya conocida y preguntas a responder
- **Métricas Cognitivas**: Completitud, tiempo de sesión, nivel de fatiga

#### Formulario de Datos (DataForm)
Estructura para organizar información recopilada:
- **Categorización**: Tipo de información (persona, empresa, red social, etc.)
- **Campos Dinámicos**: Sistema flexible para diferentes tipos de datos
- **Estados**: Borrador, recopilado, en revisión, revisado, enviado
- **Priorización**: Sistema inteligente para ordenar por importancia
- **Validación**: Advertencias suaves sin bloqueos agresivos

### Pantallas Principales

#### 1. Home Screen - Centro de Control

**Vista Simplificada (Foco Cognitivo)**
- **Investigación Activa**: Una investigación destacada con progreso visible
- **Acciones Rápidas**: Máximo 3 opciones principales
- **Lista Colapsada**: Otras investigaciones minimizadas por defecto
- **Recordatorios Contextuales**: Tareas pendientes específicas

**Vista Detallada (Control Completo)**
- **Grid Completo**: Todas las investigaciones con detalles
- **Botones de Fase**: Cambio directo de estado de investigación
- **Estado del Sistema**: Monitoreo de servicios ELK
- **Métricas Avanzadas**: Información detallada de progreso

**Funcionalidades Duales**
- **Toggle de Vista**: Cambio fácil entre modos simple y completo
- **Navegación Inteligente**: Acceso directo a la fase correspondiente
- **Gestión de Estado**: Botones para avanzar fases de investigación
- **Creación Rápida**: Flujo streamlined para nuevas investigaciones

#### 2. Planning Screen - Planificación Inteligente

**Modo Wizard (Enfoque Cognitivo)**
- **Paso 1 - Objetivo Simple**: Una frase clara del propósito de investigación
- **Paso 2 - Información Conocida**: Lista de datos ya disponibles
- **Paso 3 - Preguntas Clave**: Máximo 3 preguntas específicas a responder
- **Paso 4 - Planificación Temporal**: Calendario y cronograma

**Modo Completo (Funcionalidad Extendida)**
- **Formularios Extensos**: Todos los campos de planificación disponibles
- **Metodologías OSINT**: Templates predefinidos para diferentes tipos de investigación
- **Requisitos Detallados**: Lista completa de necesidades y recursos
- **Exportación PDF**: Generación de documentos de planificación formales

**Características Integradas**
- **Autoguardado**: Persistencia automática de cambios
- **Validación Inteligente**: Sugerencias y verificaciones suaves
- **Templates Contextuales**: Formularios prediseñados por tipo de investigación
- **Límites Cognitivos**: Máximo de objetivos y preguntas para mantener foco

#### 3. Collection Screen - Recopilación Organizada

**Sistema de Categorización Automática**
- **Categorías Principales**: Datos personales, redes sociales, empresas, ubicaciones, relaciones
- **Formularios Inteligentes**: Campos sugeridos según la categoría seleccionada
- **Campos Dinámicos**: Sistema "añadir campo" para personalización
- **Limitación Cognitiva**: Máximo 3-6 campos visibles simultáneamente

**Flujo de Entrada de Datos**
- **Selección de Categoría**: Interfaz simple para elegir tipo de información
- **Formularios Progresivos**: Campos esenciales primero, adicionales opcionales
- **Validación en Tiempo Real**: Sugerencias y ejemplos contextuales
- **Guardado Incremental**: Persistencia automática sin pérdida de datos

**Gestión de Formularios**
- **Estados Múltiples**: Borrador, completado, enviado a procesamiento
- **Edición Flexible**: Modificación de campos y estructura
- **Vista Resumida**: Cards compactos de formularios completados
- **Envío Controlado**: Transferencia manual a fase de procesamiento

#### 4. Processing Screen - Revisión Inteligente

**Sistema de Priorización**
- **Algoritmo Inteligente**: Ordenamiento por completitud, confianza y simplicidad
- **Indicadores Visuales**: Barras de progreso y badges de estado
- **Filtros Múltiples**: Por categoría, estado, fecha, prioridad
- **Límite Cognitivo**: Vista de máximo 7 elementos principales

**Cards de Procesamiento**
- **Información Esencial**: Solo 2-3 campos más importantes visibles inicialmente
- **Expansión Controlada**: Opción de ver todos los detalles
- **Estados Duales**: "En revisión" y "Revisado" con transición simple
- **Validación Previa**: Verificación antes del envío a Elasticsearch

**Flujo de Revisión**
- **Navegación Secuencial**: Orden lógico de revisión sugerido
- **Edición In-Situ**: Modificación directa sin cambiar pantalla
- **Batch Operations**: Acciones múltiples para eficiencia
- **Integración ELK**: Envío directo a Elasticsearch via Logstash

#### 5. Analysis Screen - Acceso a Kibana

**Funcionalidades Simples**
- **Estado del Sistema**: Verificación de servicios ELK funcionando
- **Acceso Directo**: Botón para abrir Kibana en navegador
- **Preview Opcional**: iFrame embebido de dashboards principales
- **Enlaces Contextuales**: Accesos rápidos a visualizaciones específicas

#### 6. Reports Screen - Futuras Funcionalidades

**Estado Actual**
- **Mensaje "En Mantenimiento"**: Indicación clara de desarrollo futuro
- **Roadmap Visible**: Lista de funcionalidades planificadas
- **Fecha Estimada**: Timeline aproximado de implementación

## ⚙️ Servicios y Funcionalidades Técnicas

### Docker Service
Gestión automática de la infraestructura ELK:
- **Inicio Automático**: Levantamiento de servicios al arrancar la app
- **Monitoreo de Estado**: Verificación continua de salud de servicios
- **Gestión de Puertos**: Configuración de accesos locales seguros
- **Logs de Sistema**: Registro de actividad de contenedores

### API Service
Comunicación entre Flutter y backend local:
- **CRUD Investigaciones**: Gestión completa de investigaciones
- **Gestión de Formularios**: Operaciones sobre formularios de datos
- **Integración Elasticsearch**: Envío de datos procesados
- **Métricas Cognitivas**: Tracking de uso y sugerencias

### Database Service (SQLite)
Persistencia local de metadatos:
- **Configuraciones**: Settings de aplicación y usuario
- **Metadatos de Investigación**: Información no indexada en ES
- **Historial de Actividad**: Log de acciones para análisis cognitivo
- **Templates y Configuraciones**: Formularios predefinidos

### Cognitive Service (Nuevo)
Motor de ayudas inteligentes:
- **Generación de Sugerencias**: Recomendaciones contextuales
- **Cálculo de Prioridades**: Algoritmos de ordenamiento inteligente
- **Detección de Fatiga**: Análisis de patrones de uso
- **Navegación Predictiva**: Sugerencia de próximas acciones

## 🔄 Flujos de Trabajo Principales

### Flujo Completo de Investigación

#### 1. Creación de Investigación
- **Acceso**: Botón en Home Screen o menú principal
- **Modo Simple**: Wizard de 3-4 pasos básicos
- **Modo Completo**: Formulario extendido con todas las opciones
- **Resultado**: Nueva investigación en fase de planificación

#### 2. Planificación Inteligente
- **Definición de Objetivos**: Máximo 3-5 objetivos específicos
- **Inventario de Conocimiento**: Lista de información ya disponible
- **Identificación de Brechas**: Preguntas específicas a responder
- **Planificación Temporal**: Cronograma y hitos importantes

#### 3. Recopilación Organizada
- **Selección de Categorías**: Tipos de información a recopilar
- **Formularios Dinámicos**: Campos personalizables por categoría
- **Entrada Progresiva**: Información esencial primero, detalles después
- **Validación Continua**: Sugerencias y verificaciones suaves

#### 4. Procesamiento Inteligente
- **Priorización Automática**: Orden sugerido de revisión
- **Revisión Secuencial**: Proceso estructurado de validación
- **Edición In-Situ**: Correcciones sin cambio de contexto
- **Envío Controlado**: Transferencia a Elasticsearch cuando esté listo

#### 5. Análisis Avanzado
- **Acceso a Kibana**: Interfaz completa de visualización
- **Dashboards Específicos**: Vistas personalizadas por investigación
- **Búsquedas Complejas**: Queries avanzadas en datos procesados
- **Visualizaciones**: Gráficos, mapas, líneas de tiempo

### Flujo de Gestión Cognitiva

#### Prevención de Sobrecarga
- **Monitoreo de Sesión**: Tracking de tiempo y actividad
- **Límites Visuales**: Máximo elementos mostrados simultáneamente
- **Sugerencias de Descanso**: Alertas basadas en patrones de fatiga
- **Priorización Inteligente**: Enfoque en lo más importante primero

#### Ayudas Contextuales
- **Sugerencias de Acción**: Recomendaciones de próximos pasos
- **Validación Suave**: Avisos amigables sin bloqueos
- **Navegación Predictiva**: Accesos directos a acciones probables
- **Métricas de Progreso**: Indicadores visuales de avance

## 🛡️ Consideraciones de Seguridad

### Aislamiento Local
- **Red Cerrada**: Sin acceso a internet para evitar filtraciones
- **Cifrado de Datos**: Toda la información sensible cifrada en disco
- **Autenticación Local**: Sistema de usuarios completamente offline
- **Auditoría Completa**: Log detallado de todas las actividades

### Gestión de Datos Sensibles
- **Compartimentación**: Investigaciones aisladas entre sí
- **Borrado Seguro**: Eliminación garantizada de información confidencial
- **Backups Cifrados**: Respaldos locales con protección criptográfica
- **Control de Acceso**: Permisos granulares por usuario y investigación

## 📦 Instalación y Despliegue

### Requisitos del Sistema
- **Hardware Mínimo**: 8GB RAM, 100GB almacenamiento, CPU multi-core
- **Sistemas Operativos**: Windows 10+, macOS 10.14+, Linux Ubuntu 18.04+
- **Docker**: Requerido para servicios ELK
- **Puertos Locales**: 5601 (Kibana), 9200 (Elasticsearch), 8000 (API)

### Proceso de Instalación
1. **Descarga**: Aplicación Flutter compilada + Docker Compose
2. **Configuración Automática**: Script de setup inicial
3. **Verificación**: Tests de funcionamiento de servicios
4. **Primer Uso**: Tutorial integrado y configuración inicial

### Estructura de Directorios
```
osint-platform/
├── app/                    # Aplicación Flutter compilada
├── docker-compose.yml      # Configuración ELK Stack
├── data/
│   ├── elasticsearch/      # Datos de ES
│   ├── database.sqlite     # Metadatos locales
│   ├── uploads/           # Archivos importados
│   └── backups/           # Respaldos cifrados
├── config/
│   ├── logstash/          # Pipelines de procesamiento
│   └── certificates/      # Certificados SSL locales
└── api/                   # Backend Python
```

## 🚀 Roadmap de Desarrollo

### Fase 1 - MVP (Funcionalidad Core)
- **Aplicación Flutter**: Pantallas principales y navegación
- **Base de Datos Local**: SQLite con modelos básicos
- **Docker Integration**: Levantamiento automático de ELK Stack
- **Formularios Dinámicos**: Sistema de recopilación de datos

### Fase 2 - Funcionalidades Cognitivas
- **Priorización Inteligente**: Algoritmos de ordenamiento
- **Sugerencias Contextuales**: Sistema de ayudas inteligentes
- **Detección de Fatiga**: Monitoreo de patrones de uso
- **Vistas Duales**: Toggle entre modo simple y completo

### Fase 3 - Análisis Avanzado
- **Integración Kibana**: Acceso seamless desde la aplicación
- **Dashboards Personalizados**: Vistas específicas por investigación
- **Exportación Avanzada**: Múltiples formatos de salida
- **Templates de Investigación**: Metodologías predefinidas

### Fase 4 - Optimización y Seguridad
- **Rendimiento**: Optimización de consultas y visualizaciones
- **Seguridad Avanzada**: Cifrado extremo a extremo
- **Backup Automático**: Sistema de respaldos inteligente
- **Documentación Completa**: Manuales de usuario y administración

## 📈 Métricas de Éxito

### Eficiencia del Investigador
- **Tiempo de Recopilación**: Reducción del tiempo necesario para organizar datos
- **Errores de Clasificación**: Minimización de categorización incorrecta
- **Completitud de Investigaciones**: Porcentaje de investigaciones terminadas exitosamente
- **Satisfacción de Usuario**: Feedback sobre usabilidad y utilidad

### Rendimiento del Sistema
- **Tiempo de Respuesta**: Latencia de operaciones principales
- **Uso de Memoria**: Eficiencia en consumo de recursos
- **Estabilidad**: Tiempo promedio entre errores o crashes
- **Capacidad**: Número máximo de investigaciones simultáneas

### Impacto Cognitivo
- **Reducción de Sobrecarga**: Métricas de fatiga y estrés del usuario
- **Mejora de Foco**: Tiempo dedicado a tareas relevantes vs. navegación
- **Retención de Información**: Capacidad de recordar y recuperar datos
- **Productividad General**: Output de investigación por hora trabajada

---

*Esta especificación sirve como base para el desarrollo de la plataforma OSINT local, proporcionando una guía clara de funcionalidades, arquitectura y objetivos del proyecto.*