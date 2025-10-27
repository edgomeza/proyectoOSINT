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
      case DataFormCategory.person:
        return [
          {'label': 'Nombre completo', 'hint': 'Nombre y apellidos', 'icon': Icons.person, 'required': true},
          {'label': 'Edad', 'hint': 'Edad aproximada', 'icon': Icons.cake, 'required': false},
          {'label': 'Ocupación', 'hint': 'Profesión o trabajo', 'icon': Icons.work, 'required': false},
          {'label': 'Email', 'hint': 'correo@ejemplo.com', 'icon': Icons.email, 'required': false},
          {'label': 'Teléfono', 'hint': '+34 XXX XXX XXX', 'icon': Icons.phone, 'required': false},
        ];
      case DataFormCategory.company:
        return [
          {'label': 'Nombre de la empresa', 'hint': 'Razón social', 'icon': Icons.business, 'required': true},
          {'label': 'CIF/NIF', 'hint': 'Número de identificación', 'icon': Icons.badge, 'required': false},
          {'label': 'Sector', 'hint': 'Sector de actividad', 'icon': Icons.category, 'required': false},
          {'label': 'Dirección', 'hint': 'Dirección física', 'icon': Icons.location_on, 'required': false},
          {'label': 'Sitio web', 'hint': 'https://ejemplo.com', 'icon': Icons.language, 'required': false},
        ];
      case DataFormCategory.socialNetwork:
        return [
          {'label': 'Plataforma', 'hint': 'Twitter, Facebook, Instagram...', 'icon': Icons.share, 'required': true},
          {'label': 'Usuario', 'hint': '@usuario', 'icon': Icons.account_circle, 'required': true},
          {'label': 'URL del perfil', 'hint': 'https://...', 'icon': Icons.link, 'required': false},
          {'label': 'Número de seguidores', 'hint': 'Cantidad aproximada', 'icon': Icons.people, 'required': false},
          {'label': 'Actividad', 'hint': 'Última actividad conocida', 'icon': Icons.timeline, 'required': false},
        ];
      case DataFormCategory.location:
        return [
          {'label': 'Nombre del lugar', 'hint': 'Identificación del lugar', 'icon': Icons.place, 'required': true},
          {'label': 'Dirección completa', 'hint': 'Calle, número, ciudad', 'icon': Icons.location_on, 'required': false},
          {'label': 'Coordenadas', 'hint': 'Latitud, Longitud', 'icon': Icons.my_location, 'required': false},
          {'label': 'Tipo de lugar', 'hint': 'Residencia, oficina, etc.', 'icon': Icons.category, 'required': false},
        ];
      case DataFormCategory.relationship:
        return [
          {'label': 'Entidad A', 'hint': 'Primera entidad', 'icon': Icons.person, 'required': true},
          {'label': 'Entidad B', 'hint': 'Segunda entidad', 'icon': Icons.person_outline, 'required': true},
          {'label': 'Tipo de relación', 'hint': 'Familiar, laboral, etc.', 'icon': Icons.link, 'required': true},
          {'label': 'Detalles', 'hint': 'Información adicional', 'icon': Icons.info, 'required': false},
        ];
      case DataFormCategory.document:
        return [
          {'label': 'Título del documento', 'hint': 'Nombre identificativo', 'icon': Icons.description, 'required': true},
          {'label': 'Tipo', 'hint': 'PDF, imagen, video...', 'icon': Icons.category, 'required': false},
          {'label': 'Fuente', 'hint': 'Origen del documento', 'icon': Icons.source, 'required': false},
          {'label': 'Fecha', 'hint': 'Fecha del documento', 'icon': Icons.calendar_today, 'required': false},
        ];
      case DataFormCategory.event:
        return [
          {'label': 'Nombre del evento', 'hint': 'Descripción breve', 'icon': Icons.event, 'required': true},
          {'label': 'Fecha', 'hint': 'Cuándo ocurrió', 'icon': Icons.calendar_today, 'required': true},
          {'label': 'Lugar', 'hint': 'Dónde ocurrió', 'icon': Icons.location_on, 'required': false},
          {'label': 'Participantes', 'hint': 'Quiénes participaron', 'icon': Icons.people, 'required': false},
        ];
      case DataFormCategory.other:
        return [
          {'label': 'Título', 'hint': 'Título descriptivo', 'icon': Icons.title, 'required': true},
          {'label': 'Descripción', 'hint': 'Detalles', 'icon': Icons.description, 'required': false},
        ];
    }
  }
}
