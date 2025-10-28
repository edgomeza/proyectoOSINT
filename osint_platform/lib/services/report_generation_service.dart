import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/investigation.dart';
import '../models/entity_node.dart';
import '../models/relationship.dart';
import '../models/timeline_event.dart';
import '../models/geo_location.dart';

class ReportGenerationService {
  /// Generate a comprehensive investigation report
  static Future<File> generateInvestigationReport({
    required Investigation investigation,
    required List<EntityNode> nodes,
    required List<Relationship> relationships,
    required List<TimelineEvent> events,
    required List<GeoLocation> locations,
    String? customNotes,
    bool includeGraphs = true,
    bool includeTimeline = true,
    bool includeMap = true,
  }) async {
    final pdf = pw.Document();
    final theme = await _buildTheme();

    // Cover Page
    pdf.addPage(
      pw.Page(
        theme: theme,
        build: (context) => _buildCoverPage(investigation),
      ),
    );

    // Executive Summary
    pdf.addPage(
      pw.Page(
        theme: theme,
        build: (context) => _buildExecutiveSummary(
          investigation,
          nodes,
          relationships,
          events,
        ),
      ),
    );

    // Table of Contents
    pdf.addPage(
      pw.Page(
        theme: theme,
        build: (context) => _buildTableOfContents(),
      ),
    );

    // Investigation Details
    pdf.addPage(
      pw.Page(
        theme: theme,
        build: (context) => _buildInvestigationDetails(investigation),
      ),
    );

    // Entities Section
    if (nodes.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          build: (context) => [
            _buildSectionHeader('Entities'),
            pw.SizedBox(height: 20),
            ..._buildEntitiesSection(nodes),
          ],
        ),
      );
    }

    // Relationships Section
    if (relationships.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          build: (context) => [
            _buildSectionHeader('Relationships'),
            pw.SizedBox(height: 20),
            ..._buildRelationshipsSection(relationships, nodes),
          ],
        ),
      );
    }

    // Timeline Section
    if (includeTimeline && events.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          build: (context) => [
            _buildSectionHeader('Timeline'),
            pw.SizedBox(height: 20),
            ..._buildTimelineSection(events),
          ],
        ),
      );
    }

    // Geographic Analysis
    if (includeMap && locations.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          build: (context) => [
            _buildSectionHeader('Geographic Analysis'),
            pw.SizedBox(height: 20),
            ..._buildGeographicSection(locations),
          ],
        ),
      );
    }

    // Custom Notes
    if (customNotes != null && customNotes.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          theme: theme,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Additional Notes'),
              pw.SizedBox(height: 20),
              pw.Text(customNotes),
            ],
          ),
        ),
      );
    }

    // Save PDF
    final output = await _getOutputFile(investigation.name);
    await output.writeAsBytes(await pdf.save());

    return output;
  }

  /// Generate a summary report (lighter version)
  static Future<File> generateSummaryReport({
    required Investigation investigation,
    required List<EntityNode> nodes,
    required List<Relationship> relationships,
  }) async {
    final pdf = pw.Document();
    final theme = await _buildTheme();

    pdf.addPage(
      pw.Page(
        theme: theme,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildCoverPage(investigation),
            pw.SizedBox(height: 40),
            _buildSectionHeader('Summary'),
            pw.SizedBox(height: 20),
            _buildStatisticsTable(nodes, relationships),
          ],
        ),
      ),
    );

    final output = await _getOutputFile('${investigation.name}_summary');
    await output.writeAsBytes(await pdf.save());

    return output;
  }

  // Private helper methods

  static pw.Widget _buildCoverPage(Investigation investigation) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return pw.Container(
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [
            PdfColor.fromHex('#6C63FF'),
            PdfColor.fromHex('#00D9FF'),
          ],
        ),
      ),
      child: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              'INVESTIGATION REPORT',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              investigation.name,
              style: pw.TextStyle(
                fontSize: 24,
                color: PdfColors.white,
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 40),
            pw.Text(
              'Generated: ${dateFormat.format(DateTime.now())}',
              style: const pw.TextStyle(
                fontSize: 14,
                color: PdfColors.white,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Status: ${investigation.status.name.toUpperCase()}',
              style: const pw.TextStyle(
                fontSize: 14,
                color: PdfColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildExecutiveSummary(
    Investigation investigation,
    List<EntityNode> nodes,
    List<Relationship> relationships,
    List<TimelineEvent> events,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Executive Summary'),
        pw.SizedBox(height: 20),
        pw.Text(
          investigation.description,
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 20),
        _buildSectionHeader('Key Statistics', fontSize: 16),
        pw.SizedBox(height: 10),
        _buildStatisticsTable(nodes, relationships),
        pw.SizedBox(height: 20),
        if (investigation.objectives.isNotEmpty) ...[
          _buildSectionHeader('Objectives', fontSize: 16),
          pw.SizedBox(height: 10),
          pw.BulletList(
            investigation.objectives.map((obj) => pw.Text(obj)).toList(),
          ),
        ],
        pw.SizedBox(height: 20),
        if (investigation.keyQuestions.isNotEmpty) ...[
          _buildSectionHeader('Key Questions', fontSize: 16),
          pw.SizedBox(height: 10),
          pw.BulletList(
            investigation.keyQuestions.map((q) => pw.Text(q)).toList(),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildTableOfContents() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Table of Contents'),
        pw.SizedBox(height: 20),
        _buildTocItem('1. Executive Summary', 2),
        _buildTocItem('2. Investigation Details', 4),
        _buildTocItem('3. Entities', 5),
        _buildTocItem('4. Relationships', 6),
        _buildTocItem('5. Timeline', 7),
        _buildTocItem('6. Geographic Analysis', 8),
        _buildTocItem('7. Additional Notes', 9),
      ],
    );
  }

  static pw.Widget _buildTocItem(String title, int page) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(page.toString(), style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildInvestigationDetails(Investigation investigation) {
    final dateFormat = DateFormat('MMMM dd, yyyy HH:mm');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Investigation Details'),
        pw.SizedBox(height: 20),
        _buildDetailRow('Name', investigation.name),
        _buildDetailRow('Created', dateFormat.format(investigation.createdAt)),
        _buildDetailRow('Last Updated', dateFormat.format(investigation.updatedAt)),
        _buildDetailRow('Current Phase', investigation.currentPhase.name),
        _buildDetailRow('Status', investigation.status.name),
        _buildDetailRow('Completeness', '${(investigation.completeness * 100).toInt()}%'),
      ],
    );
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildEntitiesSection(List<EntityNode> nodes) {
    final byType = <EntityNodeType, List<EntityNode>>{};

    for (final node in nodes) {
      byType.putIfAbsent(node.type, () => []).add(node);
    }

    final widgets = <pw.Widget>[];

    for (final entry in byType.entries) {
      widgets.add(
        pw.Text(
          entry.key.displayName,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 10));

      for (final node in entry.value) {
        widgets.add(_buildEntityCard(node));
        widgets.add(pw.SizedBox(height: 10));
      }

      widgets.add(pw.SizedBox(height: 20));
    }

    return widgets;
  }

  static pw.Widget _buildEntityCard(EntityNode node) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            node.label,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (node.description != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              node.description!,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              _buildBadge('Risk: ${node.riskLevel.displayName}'),
              pw.SizedBox(width: 8),
              _buildBadge('Confidence: ${(node.confidence * 100).toInt()}%'),
            ],
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildRelationshipsSection(
    List<Relationship> relationships,
    List<EntityNode> nodes,
  ) {
    final widgets = <pw.Widget>[];

    for (final rel in relationships) {
      final source = nodes.firstWhere((n) => n.id == rel.sourceNodeId);
      final target = nodes.firstWhere((n) => n.id == rel.targetNodeId);

      widgets.add(_buildRelationshipCard(rel, source, target));
      widgets.add(pw.SizedBox(height: 10));
    }

    return widgets;
  }

  static pw.Widget _buildRelationshipCard(
    Relationship rel,
    EntityNode source,
    EntityNode target,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(source.label, style: const pw.TextStyle(fontSize: 11)),
          ),
          pw.Icon(
            rel.isDirected
                ? const pw.IconData(0xe5cc)
                : const pw.IconData(0xe3e7),
            size: 16,
          ),
          pw.SizedBox(width: 4),
          pw.Text(
            rel.label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Icon(
            const pw.IconData(0xe5cc),
            size: 16,
          ),
          pw.Expanded(
            child: pw.Text(target.label, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildTimelineSection(List<TimelineEvent> events) {
    final widgets = <pw.Widget>[];
    final dateFormat = DateFormat('MMMM dd, yyyy HH:mm');

    for (final event in events) {
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                event.title,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                dateFormat.format(event.timestamp),
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              if (event.description != null) ...[
                pw.SizedBox(height: 6),
                pw.Text(event.description!, style: const pw.TextStyle(fontSize: 10)),
              ],
            ],
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 10));
    }

    return widgets;
  }

  static List<pw.Widget> _buildGeographicSection(List<GeoLocation> locations) {
    final widgets = <pw.Widget>[];

    for (final location in locations) {
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                location.name,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              if (location.address != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(location.address!, style: const pw.TextStyle(fontSize: 10)),
              ],
            ],
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 10));
    }

    return widgets;
  }

  static pw.Widget _buildSectionHeader(String title, {double fontSize = 20}) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: fontSize,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#6C63FF'),
      ),
    );
  }

  static pw.Widget _buildStatisticsTable(
    List<EntityNode> nodes,
    List<Relationship> relationships,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        _buildTableRow('Total Entities', nodes.length.toString(), isHeader: true),
        _buildTableRow('Total Relationships', relationships.length.toString()),
        _buildTableRow(
          'High Risk Entities',
          nodes
              .where((n) =>
                  n.riskLevel == RiskLevel.high ||
                  n.riskLevel == RiskLevel.critical)
              .length
              .toString(),
        ),
        _buildTableRow(
          'Average Confidence',
          nodes.isNotEmpty
              ? '${(nodes.map((n) => n.confidence).reduce((a, b) => a + b) / nodes.length * 100).toInt()}%'
              : 'N/A',
        ),
      ],
    );
  }

  static pw.TableRow _buildTableRow(
    String label,
    String value, {
    bool isHeader = false,
  }) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isHeader ? pw.FontWeight.bold : null,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ),
      ],
    );
  }

  static pw.Widget _buildBadge(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  static Future<pw.ThemeData> _buildTheme() async {
    return pw.ThemeData.withFont(
      base: await PdfGoogleFonts.openSansRegular(),
      bold: await PdfGoogleFonts.openSansBold(),
    );
  }

  static Future<File> _getOutputFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${directory.path}/reports');

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = '${name.replaceAll(' ', '_')}_$timestamp.pdf';

    return File('${reportsDir.path}/$filename');
  }
}
