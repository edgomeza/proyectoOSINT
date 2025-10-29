# Configuración Docker para Plataforma OSINT

Este documento explica cómo configurar y ejecutar los servicios de Elasticsearch, Kibana y Logstash (ELK Stack) para la plataforma OSINT.

## Requisitos Previos

- Docker instalado (versión 20.10 o superior)
- Docker Compose instalado (versión 2.0 o superior)
- Al menos 4GB de RAM disponible para Docker
- Puertos libres: 9200, 9300, 5601, 5044, 8000

## Servicios Incluidos

### Elasticsearch (Puerto 9200, 9300)
Motor de búsqueda y análisis distribuido para almacenar y consultar datos de investigaciones OSINT.

**Características:**
- Modo single-node para desarrollo
- Sin seguridad habilitada (para desarrollo local)
- Persistencia de datos con volúmenes Docker

### Kibana (Puerto 5601)
Interfaz de visualización y análisis de datos almacenados en Elasticsearch.

**Acceso:**
- URL: http://localhost:5601
- Usuario: elastic
- Contraseña: changeme (cambiar en producción)

### Logstash (Puerto 5044, 9600)
Pipeline de procesamiento de datos que ingesta, transforma y envía datos a Elasticsearch.

**Configuración:**
- Pipeline configurado en `logstash/pipeline/logstash.conf`
- Configuración general en `logstash/config/logstash.yml`

### NER Backend (Puerto 8000)
Servicio Python para Named Entity Recognition (Reconocimiento de Entidades Nombradas).

## Iniciar los Servicios

### 1. Configurar variables de entorno
```bash
cp .env.example .env
# Editar .env con tus configuraciones
```

### 2. Iniciar todos los servicios
```bash
docker-compose up -d
```

### 3. Verificar el estado de los servicios
```bash
docker-compose ps
```

### 4. Ver logs de un servicio específico
```bash
# Ver logs de Elasticsearch
docker-compose logs -f elasticsearch

# Ver logs de Kibana
docker-compose logs -f kibana

# Ver logs de Logstash
docker-compose logs -f logstash
```

## Detener los Servicios

```bash
# Detener sin eliminar volúmenes
docker-compose down

# Detener y eliminar volúmenes (¡CUIDADO! Eliminará todos los datos)
docker-compose down -v
```

## Verificar Salud de los Servicios

### Elasticsearch
```bash
curl http://localhost:9200/_cluster/health?pretty
```

### Kibana
```bash
curl http://localhost:5601/api/status
```

### NER Backend
```bash
curl http://localhost:8000/health
```

## Configuración de Indices en Elasticsearch

Los datos se almacenan automáticamente en índices con el formato:
- `osint-YYYY.MM.DD` - Para datos generales
- `{investigation_id}-YYYY.MM.DD` - Para datos de investigaciones específicas

## Troubleshooting

### Elasticsearch no inicia
```bash
# Verificar logs
docker-compose logs elasticsearch

# Verificar memoria asignada
docker stats osint_elasticsearch

# Aumentar memoria si es necesario (en docker-compose.yml)
ES_JAVA_OPTS=-Xms1g -Xmx1g
```

### Kibana no conecta a Elasticsearch
```bash
# Verificar que Elasticsearch esté corriendo
curl http://localhost:9200

# Reiniciar Kibana
docker-compose restart kibana
```

### Error de permisos en volúmenes
```bash
# En Linux, puede ser necesario ajustar permisos
sudo chown -R 1000:1000 elasticsearch_data/
```

## Producción

Para usar en producción, asegúrate de:

1. ✅ Habilitar seguridad en Elasticsearch
2. ✅ Cambiar contraseñas por defecto
3. ✅ Configurar SSL/TLS
4. ✅ Ajustar recursos (memoria, CPU)
5. ✅ Configurar backups automáticos
6. ✅ Implementar monitoreo
7. ✅ Revisar configuración de red

## Recursos Adicionales

- [Documentación de Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Documentación de Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Documentación de Logstash](https://www.elastic.co/guide/en/logstash/current/index.html)

## Soporte

Para problemas o preguntas, consulta la documentación oficial de Elastic o abre un issue en el repositorio del proyecto.
