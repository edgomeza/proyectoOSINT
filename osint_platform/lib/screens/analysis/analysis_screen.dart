import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/common/navigation_drawer.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/common/service_status_card.dart';
import '../../providers/data_forms_provider.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  final String investigationId;

  const AnalysisScreen({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  bool _isInitialized = false;
  final List<ServiceInfo> _elkServices = [
    ServiceInfo(
      name: 'elasticsearch',
      displayName: 'Elasticsearch',
      status: ServiceStatus.stopped,
      version: '8.11.0',
      port: '9200',
      url: 'http://localhost:9200',
    ),
    ServiceInfo(
      name: 'logstash',
      displayName: 'Logstash',
      status: ServiceStatus.stopped,
      version: '8.11.0',
      port: '5044',
    ),
    ServiceInfo(
      name: 'kibana',
      displayName: 'Kibana',
      status: ServiceStatus.stopped,
      version: '8.11.0',
      port: '5601',
      url: 'http://localhost:5601',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkServices();
    });
  }

  Future<void> _checkServices() async {
    // Simular verificación de servicios
    // En producción, esto haría peticiones HTTP a cada servicio
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });

      // Mostrar información sobre los servicios
      _showServiceInfo();
    }
  }

  void _showServiceInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Los servicios ELK deben iniciarse manualmente para visualizar datos',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Entendido',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _refreshDashboards() async {
    // Simular actualización de dashboards
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboards actualizados'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openDashboard(DashboardType type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(type.icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text(type.displayName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type.description),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha:0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Requiere servicios ELK en ejecución',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // En producción, aquí se abriría la URL de Kibana
              _showKibanaUrlDialog();
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Abrir en Kibana'),
          ),
        ],
      ),
    );
  }

  void _showKibanaUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kibana'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Para acceder a los dashboards de Kibana:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha:0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.link, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'http://localhost:5601',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Asegúrate de que los servicios ELK estén en ejecución\n'
              '2. Abre la URL en tu navegador\n'
              '3. Navega a Analytics > Dashboard',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _startService(ServiceInfo service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Iniciar ${service.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Para iniciar ${service.displayName}, ejecuta el siguiente comando:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'docker-compose up ${service.name}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'O inicia todos los servicios con:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'docker-compose up -d',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _openServiceUrl(ServiceInfo service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Abre la siguiente URL en tu navegador:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                service.url!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allForms = ref.watch(dataFormsProvider);
    final investigationForms = allForms
        .where((form) => form.investigationId == widget.investigationId)
        .toList();

    final totalDataPoints = investigationForms.fold<int>(
      0,
      (sum, form) => sum + form.fields.length,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Volver al inicio',
        ),
        title: const Text('Análisis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboards,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: const AppNavigationDrawer(),
      body: !_isInitialized
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verificando servicios...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  FadeInDown(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.analytics,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Centro de Análisis',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '$totalDataPoints puntos de datos recopilados',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Estado de Servicios ELK
                  FadeInLeft(
                    delay: const Duration(milliseconds: 100),
                    child: const Text(
                      'Estado de Servicios ELK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_elkServices.length, (index) {
                    final service = _elkServices[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ServiceStatusCard(
                        service: service,
                        onStart: () => _startService(service),
                        onOpenUrl: service.url != null
                            ? () => _openServiceUrl(service)
                            : null,
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Dashboards Disponibles
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dashboards Disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _refreshDashboards,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Actualizar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grid de Dashboards
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 900
                          ? 3
                          : MediaQuery.of(context).size.width > 600
                              ? 2
                              : 1,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: DashboardType.values.length,
                    itemBuilder: (context, index) {
                      final dashboardType = DashboardType.values[index];
                      return DashboardCard(
                        type: dashboardType,
                        dataPoints: totalDataPoints,
                        lastUpdated: DateTime.now().subtract(
                          Duration(minutes: index * 5),
                        ),
                        onTap: () => _openDashboard(dashboardType),
                        onRefresh: _refreshDashboards,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Acciones Rápidas
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Acciones Rápidas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildQuickAction(
                                  icon: Icons.dashboard,
                                  label: 'Abrir Kibana',
                                  color: Colors.blue,
                                  onTap: _showKibanaUrlDialog,
                                ),
                                _buildQuickAction(
                                  icon: Icons.file_download,
                                  label: 'Exportar Datos',
                                  color: Colors.green,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Exportación disponible próximamente'),
                                      ),
                                    );
                                  },
                                ),
                                _buildQuickAction(
                                  icon: Icons.settings,
                                  label: 'Configurar',
                                  color: Colors.orange,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Configuración disponible próximamente'),
                                      ),
                                    );
                                  },
                                ),
                                _buildQuickAction(
                                  icon: Icons.help_outline,
                                  label: 'Ayuda',
                                  color: Colors.purple,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Ayuda - Centro de Análisis'),
                                        content: const SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'El Centro de Análisis permite visualizar y analizar los datos recopilados mediante dashboards interactivos.',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                'Pasos para comenzar:',
                                                style: TextStyle(fontWeight: FontWeight.w700),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                '1. Inicia los servicios ELK (Elasticsearch, Logstash, Kibana)\n'
                                                '2. Los datos procesados se enviarán automáticamente a Elasticsearch\n'
                                                '3. Visualiza los dashboards en esta pantalla o en Kibana\n'
                                                '4. Configura alertas y reportes personalizados',
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Cerrar'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha:0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
