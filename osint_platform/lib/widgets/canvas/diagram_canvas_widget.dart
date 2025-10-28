import 'package:flutter/material.dart';
import 'package:diagram_editor/diagram_editor.dart';

class DiagramCanvasWidget extends StatefulWidget {
  final Function(DiagramEditorContext)? onSave;
  final DiagramEditorContext? initialContext;

  const DiagramCanvasWidget({
    super.key,
    this.onSave,
    this.initialContext,
  });

  @override
  State<DiagramCanvasWidget> createState() => _DiagramCanvasWidgetState();
}

class _DiagramCanvasWidgetState extends State<DiagramCanvasWidget> {
  late MyPolicySet myPolicySet;
  late DiagramEditorContext diagramEditorContext;
  NodeType _selectedNodeType = NodeType.rectangle;
  bool _showGrid = true;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    myPolicySet = MyPolicySet();
    diagramEditorContext = widget.initialContext ?? DiagramEditorContext(
      policySet: myPolicySet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(context),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _showGrid
                ? Colors.grey.shade50
                : Colors.white,
            ),
            child: Stack(
              children: [
                if (_showGrid) _buildGridBackground(),
                DiagramEditor(
                  diagramEditorContext: diagramEditorContext,
                  componentDataBuilder: (componentData) {
                    return _buildComponent(componentData);
                  },
                  linkDataBuilder: (linkData) {
                    return _buildLink(linkData);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Node Types
            _buildToolSection(
              context,
              title: 'Add Nodes',
              children: [
                _buildToolButton(
                  context,
                  icon: Icons.rectangle_outlined,
                  label: 'Rectangle',
                  isActive: _selectedNodeType == NodeType.rectangle,
                  onPressed: () {
                    setState(() => _selectedNodeType = NodeType.rectangle);
                    _addNode(NodeType.rectangle);
                  },
                ),
                _buildToolButton(
                  context,
                  icon: Icons.circle_outlined,
                  label: 'Circle',
                  isActive: _selectedNodeType == NodeType.circle,
                  onPressed: () {
                    setState(() => _selectedNodeType = NodeType.circle);
                    _addNode(NodeType.circle);
                  },
                ),
                _buildToolButton(
                  context,
                  icon: Icons.change_history_outlined,
                  label: 'Diamond',
                  isActive: _selectedNodeType == NodeType.diamond,
                  onPressed: () {
                    setState(() => _selectedNodeType = NodeType.diamond);
                    _addNode(NodeType.diamond);
                  },
                ),
                _buildToolButton(
                  context,
                  icon: Icons.text_fields,
                  label: 'Text',
                  isActive: _selectedNodeType == NodeType.text,
                  onPressed: () {
                    setState(() => _selectedNodeType = NodeType.text);
                    _addNode(NodeType.text);
                  },
                ),
              ],
            ),
            const VerticalDivider(),

            // Color Selection
            _buildToolSection(
              context,
              title: 'Color',
              children: [
                _buildColorButton(Colors.blue),
                _buildColorButton(Colors.red),
                _buildColorButton(Colors.green),
                _buildColorButton(Colors.orange),
                _buildColorButton(Colors.purple),
                _buildColorButton(Colors.black),
              ],
            ),
            const VerticalDivider(),

            // View Controls
            _buildToolSection(
              context,
              title: 'View',
              children: [
                _buildToolButton(
                  context,
                  icon: _showGrid ? Icons.grid_on : Icons.grid_off,
                  label: 'Grid',
                  isActive: _showGrid,
                  onPressed: () => setState(() => _showGrid = !_showGrid),
                ),
                _buildToolButton(
                  context,
                  icon: Icons.zoom_in,
                  label: 'Zoom In',
                  onPressed: () {
                    diagramEditorContext.canvasModel.scale += 0.1;
                    setState(() {});
                  },
                ),
                _buildToolButton(
                  context,
                  icon: Icons.zoom_out,
                  label: 'Zoom Out',
                  onPressed: () {
                    if (diagramEditorContext.canvasModel.scale > 0.2) {
                      diagramEditorContext.canvasModel.scale -= 0.1;
                      setState(() {});
                    }
                  },
                ),
                _buildToolButton(
                  context,
                  icon: Icons.center_focus_strong,
                  label: 'Reset Zoom',
                  onPressed: () {
                    diagramEditorContext.canvasModel.resetCanvasView();
                    setState(() {});
                  },
                ),
              ],
            ),
            const VerticalDivider(),

            // Actions
            _buildToolSection(
              context,
              title: 'Actions',
              children: [
                _buildToolButton(
                  context,
                  icon: Icons.delete_outline,
                  label: 'Delete Selected',
                  onPressed: () => _deleteSelected(),
                ),
                _buildToolButton(
                  context,
                  icon: Icons.clear_all,
                  label: 'Clear All',
                  onPressed: () => _showClearDialog(context),
                ),
                _buildToolButton(
                  context,
                  icon: Icons.save,
                  label: 'Save',
                  onPressed: () => _saveDiagram(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: label,
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            foregroundColor: isActive
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isActive = _selectedColor == color;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: () => setState(() => _selectedColor = color),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.white : Colors.grey.shade300,
              width: isActive ? 3 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildGridBackground() {
    return CustomPaint(
      painter: GridPainter(
        gridColor: Colors.grey.shade300,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildComponent(ComponentData componentData) {
    final nodeData = componentData.data as NodeData;

    return GestureDetector(
      onTap: () {
        diagramEditorContext.model.selectComponent(componentData.id);
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: nodeData.color.withOpacity(0.1),
          border: Border.all(
            color: nodeData.color,
            width: 2,
          ),
          borderRadius: nodeData.type == NodeType.rectangle
              ? BorderRadius.circular(8)
              : null,
          shape: nodeData.type == NodeType.circle
              ? BoxShape.circle
              : BoxShape.rectangle,
        ),
        child: Stack(
          children: [
            // Node content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  nodeData.text,
                  style: TextStyle(
                    color: nodeData.color,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Connection points
            Positioned(
              top: 0,
              left: componentData.size.width / 2 - 4,
              child: _buildConnectionPoint(componentData.id, Alignment.topCenter),
            ),
            Positioned(
              bottom: 0,
              left: componentData.size.width / 2 - 4,
              child: _buildConnectionPoint(componentData.id, Alignment.bottomCenter),
            ),
            Positioned(
              left: 0,
              top: componentData.size.height / 2 - 4,
              child: _buildConnectionPoint(componentData.id, Alignment.centerLeft),
            ),
            Positioned(
              right: 0,
              top: componentData.size.height / 2 - 4,
              child: _buildConnectionPoint(componentData.id, Alignment.centerRight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionPoint(String componentId, Alignment alignment) {
    return GestureDetector(
      onPanStart: (details) {
        diagramEditorContext.model.startCreatingLink(componentId, alignment);
      },
      onPanUpdate: (details) {
        diagramEditorContext.model.updateCreatingLink(details.globalPosition);
      },
      onPanEnd: (details) {
        diagramEditorContext.model.endCreatingLink();
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
      ),
    );
  }

  Widget _buildLink(LinkData linkData) {
    return CustomPaint(
      painter: LinkPainter(
        linkData: linkData,
        context: diagramEditorContext,
      ),
    );
  }

  void _addNode(NodeType type) {
    final String text;
    switch (type) {
      case NodeType.rectangle:
        text = 'Process';
        break;
      case NodeType.circle:
        text = 'Start/End';
        break;
      case NodeType.diamond:
        text = 'Decision';
        break;
      case NodeType.text:
        text = 'Note';
        break;
    }

    final componentData = ComponentData(
      size: type == NodeType.circle
          ? const Size(100, 100)
          : const Size(120, 60),
      position: Offset(
        100 + (diagramEditorContext.model.componentsMap.length * 20).toDouble(),
        100 + (diagramEditorContext.model.componentsMap.length * 20).toDouble(),
      ),
      data: NodeData(
        type: type,
        text: text,
        color: _selectedColor,
      ),
    );

    diagramEditorContext.model.addComponent(componentData);
    setState(() {});
  }

  void _deleteSelected() {
    final selectedIds = diagramEditorContext.model.selectedComponentIds.toList();
    for (var id in selectedIds) {
      diagramEditorContext.model.removeComponent(id);
    }
    setState(() {});
  }

  void _saveDiagram() {
    widget.onSave?.call(diagramEditorContext);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagram saved')),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Canvas'),
        content: const Text(
          'Are you sure you want to clear the entire diagram? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              diagramEditorContext.model.removeAllComponents();
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// Custom Policy Set
class MyPolicySet extends PolicySet {
  MyPolicySet() : super(
    canvasPolicy: MyCanvasPolicy(),
    componentPolicy: MyComponentPolicy(),
    linkPolicy: MyLinkPolicy(),
  );
}

class MyCanvasPolicy extends CanvasPolicy {
  @override
  onCanvasTapUp(Offset position) {}

  @override
  onCanvasLongPress(Offset position) {}
}

class MyComponentPolicy extends ComponentPolicy {
  @override
  onComponentTap(String componentId) {}

  @override
  onComponentLongPress(String componentId) {}
}

class MyLinkPolicy extends LinkPolicy {
  @override
  onLinkTap(String linkId) {}

  @override
  onLinkLongPress(String linkId) {}
}

// Node Data Model
class NodeData {
  final NodeType type;
  String text;
  Color color;

  NodeData({
    required this.type,
    required this.text,
    required this.color,
  });
}

enum NodeType {
  rectangle,
  circle,
  diamond,
  text,
}

// Grid Painter
class GridPainter extends CustomPainter {
  final Color gridColor;
  final double gridSpacing;

  GridPainter({
    this.gridColor = Colors.grey,
    this.gridSpacing = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Link Painter
class LinkPainter extends CustomPainter {
  final LinkData linkData;
  final DiagramEditorContext context;

  LinkPainter({
    required this.linkData,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final sourceComponent = context.model.getComponent(linkData.sourceComponentId);
    final targetComponent = context.model.getComponent(linkData.targetComponentId);

    if (sourceComponent != null && targetComponent != null) {
      final sourcePoint = sourceComponent.position +
          Offset(sourceComponent.size.width / 2, sourceComponent.size.height / 2);
      final targetPoint = targetComponent.position +
          Offset(targetComponent.size.width / 2, targetComponent.size.height / 2);

      // Draw arrow
      canvas.drawLine(sourcePoint, targetPoint, paint);

      // Draw arrowhead
      final angle = (targetPoint - sourcePoint).direction;
      final arrowSize = 10.0;
      final path = Path();
      path.moveTo(targetPoint.dx, targetPoint.dy);
      path.lineTo(
        targetPoint.dx - arrowSize * (targetPoint.dx - sourcePoint.dx).sign,
        targetPoint.dy - arrowSize * (targetPoint.dy - sourcePoint.dy).sign,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
