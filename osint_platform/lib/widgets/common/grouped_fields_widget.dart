import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/data_form_status.dart';
import 'dynamic_field_input.dart';

/// Widget que agrupa campos en subcategorías desplegables
class GroupedFieldsWidget extends StatefulWidget {
  final DataFormCategory category;
  final Map<String, TextEditingController> controllers;
  final List<Map<String, dynamic>> fields;
  final Function(int) onRemoveField;

  const GroupedFieldsWidget({
    super.key,
    required this.category,
    required this.controllers,
    required this.fields,
    required this.onRemoveField,
  });

  @override
  State<GroupedFieldsWidget> createState() => _GroupedFieldsWidgetState();
}

class _GroupedFieldsWidgetState extends State<GroupedFieldsWidget> {
  final Map<String, bool> _expandedGroups = {};

  @override
  Widget build(BuildContext context) {
    final groupedFields = _getGroupedFields();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...groupedFields.entries.map((entry) {
          final groupName = entry.key;
          final groupFields = entry.value;
          final isExpanded = _expandedGroups[groupName] ?? false;

          return FadeIn(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _expandedGroups[groupName] = !isExpanded;
                      });
                    },
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isExpanded ? Colors.blue.shade50 : Colors.grey[50],
                        borderRadius: isExpanded
                            ? const BorderRadius.vertical(top: Radius.circular(12))
                            : BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              groupName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${groupFields.length} campo${groupFields.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: groupFields.asMap().entries.map((fieldEntry) {
                          final fieldIndex = fieldEntry.key;
                          final field = fieldEntry.value;
                          final globalIndex = widget.fields.indexOf(field);
                          final controller = widget.controllers['field_$globalIndex'];
                          final isCustom = field['custom'] == true;

                          if (controller == null) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: fieldIndex < groupFields.length - 1 ? 16 : 0,
                            ),
                            child: FadeIn(
                              key: ValueKey('field_$globalIndex'),
                              child: DynamicFieldInput(
                                label: field['label'],
                                hint: field['hint'],
                                controller: controller,
                                isRequired: field['required'] ?? false,
                                icon: field['icon'],
                                onRemove: isCustom
                                    ? () => widget.onRemoveField(globalIndex)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> _getGroupedFields() {
    return CategoryFieldsGrouper.groupFieldsBySubcategory(
      widget.category,
      widget.fields,
    );
  }
}

/// Clase que agrupa campos por subcategorías
class CategoryFieldsGrouper {
  static Map<String, List<Map<String, dynamic>>> groupFieldsBySubcategory(
    DataFormCategory category,
    List<Map<String, dynamic>> fields,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    switch (category) {
      case DataFormCategory.personalData:
        grouped['Identificación Básica'] = [];
        grouped['Contacto'] = [];
        grouped['Biografía y Relaciones'] = [];
        grouped['Educación y Profesión'] = [];
        grouped['Finanzas Personales'] = [];
        grouped['Historial Legal'] = [];
        grouped['Características Físicas'] = [];
        grouped['Viajes y Movilidad'] = [];
        grouped['Digital y Tecnología Personal'] = [];
        grouped['Militar y Servicios'] = [];
        grouped['Antecedentes Adicionales'] = [];
        break;

      case DataFormCategory.digitalData:
        grouped['Infraestructura de Red'] = [];
        grouped['Dominios y DNS'] = [];
        grouped['Certificados SSL/TLS'] = [];
        grouped['Emails y Comunicaciones'] = [];
        grouped['Cuentas de Usuario'] = [];
        grouped['Indicadores de Compromiso (IOCs)'] = [];
        grouped['Tecnologías Web'] = [];
        grouped['APIs y Endpoints'] = [];
        grouped['Bases de Datos'] = [];
        grouped['Repositorios de Código'] = [];
        grouped['Cloud y Contenedores'] = [];
        break;

      case DataFormCategory.geographicData:
        grouped['Ubicaciones y Coordenadas'] = [];
        grouped['Datos de Imágenes Geoespaciales'] = [];
        grouped['Datos de Movimiento y Tracking'] = [];
        grouped['Contexto Geoespacial'] = [];
        grouped['Datos de Propiedad Inmobiliaria'] = [];
        grouped['Infraestructura y Transporte'] = [];
        grouped['Servicios y Amenidades'] = [];
        grouped['Análisis Geoespacial'] = [];
        break;

      case DataFormCategory.temporalData:
        grouped['Timestamps y Eventos'] = [];
        grouped['Cronologías'] = [];
        grouped['Edad y Antigüedad'] = [];
        break;

      case DataFormCategory.financialData:
        grouped['Información Bancaria'] = [];
        grouped['Criptomonedas'] = [];
        grouped['Inversiones y Activos'] = [];
        grouped['Obligaciones y Pasivos'] = [];
        grouped['Historial Crediticio'] = [];
        grouped['Datos Corporativos Financieros'] = [];
        grouped['Transacciones y Movimientos'] = [];
        grouped['Impuestos y Legal Financiero'] = [];
        grouped['Seguros y Beneficios'] = [];
        grouped['Criptomonedas Avanzado'] = [];
        break;

      case DataFormCategory.socialMediaData:
        grouped['Perfiles'] = [];
        grouped['Contenido Publicado'] = [];
        grouped['Engagement y Métricas'] = [];
        grouped['Red y Conexiones'] = [];
        grouped['Actividad y Comportamiento'] = [];
        grouped['Contenido y Análisis Avanzado'] = [];
        grouped['Seguridad y Privacidad'] = [];
        grouped['Análisis de Red Social'] = [];
        break;

      case DataFormCategory.multimediaData:
        grouped['Imágenes'] = [];
        grouped['Videos'] = [];
        grouped['Audio'] = [];
        grouped['Documentos'] = [];
        break;

      case DataFormCategory.technicalData:
        grouped['Hashes y Checksums'] = [];
        grouped['Certificados y Firmas'] = [];
        grouped['Metadatos de Sistema'] = [];
        grouped['Logs y Registros'] = [];
        grouped['Configuraciones'] = [];
        break;

      case DataFormCategory.corporateData:
        grouped['Información Básica de la Empresa'] = [];
        grouped['Estructura y Propiedad'] = [];
        grouped['Finanzas Corporativas'] = [];
        grouped['Legal y Cumplimiento'] = [];
        grouped['Propiedad Intelectual'] = [];
        grouped['Relaciones Comerciales'] = [];
        break;
    }

    // Distribuir los campos en sus grupos correspondientes
    // Por simplicidad, distribuimos los campos en orden entre los grupos
    // En una implementación real, se debería mapear cada campo a su grupo específico
    int groupIndex = 0;
    final groupKeys = grouped.keys.toList();

    for (var field in fields) {
      if (field['custom'] == true) {
        // Los campos personalizados van al último grupo
        grouped[groupKeys.last]!.add(field);
      } else {
        // Distribuir automáticamente entre los grupos disponibles
        grouped[groupKeys[groupIndex % groupKeys.length]]!.add(field);
        groupIndex++;
      }
    }

    // Filtrar grupos vacíos
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }
}
