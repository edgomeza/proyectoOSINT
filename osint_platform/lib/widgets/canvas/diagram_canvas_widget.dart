import 'package:flutter/material.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'dart:math' as math;

class DiagramCanvasWidget extends StatefulWidget {
  final Function(DiagramEditorContext)? onSave;

  const DiagramCanvasWidget({
    super.key,
    this.onSave,
  });

  @override
  State<DiagramCanvasWidget> createState() => _DiagramCanvasWidgetState();
}

class _DiagramCanvasWidgetState extends State<DiagramCanvasWidget> {
  late DiagramEditorContext diagramEditorContext;
  NodeType _selectedNodeType = NodeType.rectangle;
  bool _showGrid = true;
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    diagramEditorContext = DiagramEditorContext(
      policySet: MyPolicySet(
        onColorSelected: () => _selectedColor,
        onNodeTypeSelected: () => _selectedNodeType,
        onShowGrid: () => _showGrid,
      ),
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
              color: _showGrid ? Colors.grey.shade50 : Colors.white,
            ),
            child: DiagramEditor(
              diagramEditorContext: diagramEditorContext,
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
                  },
                ),
                _buildToolButton(
                  context,
                  icon: Icons.circle_outlined,
                  label: 'Circle',
                  isActive: _selectedNodeType == NodeType.circle,
                  onPressed: () {
                    setState(() => _selectedNodeType = NodeType.circle);
                  },
                ),
                _buildToolButton(
                  context,
                  icon: Icons.change_history_outlined,
                  label: 'Diamond',
                  isActive: _selectedNodeType == NodeType.diamond,
                  onPressed: () {
                    setState(() => _selectedNodeType = NodeType.diamond);
                  },
                ),
                _buildToolButton(
                  context,
                  icon: Icons.text_fields,
                  label: 'Text',
                  isActive: _selectedNodeType == NodeType.text,
                  onPressed: () {
                    setState(() => _selectedNodeType = NodeType.text);
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
                    final currentScale = diagramEditorContext.canvasReader.state.scale;
                    diagramEditorContext.canvasWriter.state.setScale(currentScale + 0.1);
                    setState(() {});
                  },
                ),
                _buildToolButton(
                  context,
                  icon: Icons.zoom_out,
                  label: 'Zoom Out',
                  onPressed: () {
                    final currentScale = diagramEditorContext.canvasReader.state.scale;
                    if (currentScale > 0.2) {
                      diagramEditorContext.canvasWriter.state.setScale(currentScale - 0.1);
                      setState(() {});
                    }
                  },
                ),
                _buildToolButton(
                  context,
                  icon: Icons.center_focus_strong,
                  label: 'Reset Zoom',
                  onPressed: () {
                    diagramEditorContext.canvasWriter.state.resetCanvasView();
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
                      color: color.withValues(alpha: 0.5),
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

  void _deleteSelected() {
    final selectedIds = List<String>.from(
      diagramEditorContext.canvasReader.model.getSelectedComponentIds(),
    );
    for (var id in selectedIds) {
      diagramEditorContext.canvasWriter.model.removeComponent(id);
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
              diagramEditorContext.canvasWriter.model.removeAllComponents();
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

// Policy Set
class MyPolicySet extends PolicySet
    with
        MyInitPolicy,
        MyComponentDesignPolicy,
        MyCanvasPolicy,
        MyComponentPolicy,
        CanvasControlPolicy,
        LinkControlPolicy,
        LinkJointControlPolicy,
        LinkAttachmentRectPolicy {
  final Color Function() onColorSelected;
  final NodeType Function() onNodeTypeSelected;
  final bool Function() onShowGrid;

  MyPolicySet({
    required this.onColorSelected,
    required this.onNodeTypeSelected,
    required this.onShowGrid,
  });
}

// Init Policy
mixin MyInitPolicy implements InitPolicy {
  @override
  initializeDiagramEditor() {
    canvasWriter.state.setCanvasColor(Colors.white);
  }
}

// Canvas Policy - Handle canvas interactions
mixin MyCanvasPolicy implements CanvasPolicy {
  @override
  onCanvasTapUp(TapUpDetails details) {
    MyPolicySet policySet = this as MyPolicySet;
    final nodeType = policySet.onNodeTypeSelected();
    final color = policySet.onColorSelected();

    final String text;
    Size size;

    switch (nodeType) {
      case NodeType.rectangle:
        text = 'Process';
        size = const Size(120, 60);
        break;
      case NodeType.circle:
        text = 'Start/End';
        size = const Size(100, 100);
        break;
      case NodeType.diamond:
        text = 'Decision';
        size = const Size(120, 80);
        break;
      case NodeType.text:
        text = 'Note';
        size = const Size(100, 40);
        break;
    }

    canvasWriter.model.addComponent(
      ComponentData(
        size: size,
        position: canvasReader.state.fromCanvasCoordinates(details.localPosition),
        data: NodeData(
          type: nodeType,
          text: text,
          color: color,
        ),
      ),
    );
  }
}

// Component Policy - Handle component interactions
mixin MyComponentPolicy implements ComponentPolicy {
  @override
  onComponentTap(String componentId) {
    canvasWriter.model.unselectAllComponents();
    canvasWriter.model.selectComponent(componentId);
  }

  @override
  onComponentLongPress(String componentId) {
    _showEditDialog(componentId);
  }

  void _showEditDialog(String componentId) {
    final component = canvasReader.model.getComponent(componentId);
    if (component == null) return;

    final nodeData = component.data as NodeData;
    final textController = TextEditingController(text: nodeData.text);

    // Note: This requires a BuildContext. In a real implementation,
    // you would need to pass context through the policy or use a different approach
  }
}

// Component Design Policy
mixin MyComponentDesignPolicy implements ComponentDesignPolicy {
  @override
  Widget showComponentBody(ComponentData componentData) {
    final nodeData = componentData.data as NodeData;

    Widget child = Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          nodeData.text,
          style: TextStyle(
            color: nodeData.color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    switch (nodeData.type) {
      case NodeType.rectangle:
        return Container(
          decoration: BoxDecoration(
            color: nodeData.color.withValues(alpha: 0.1),
            border: Border.all(color: nodeData.color, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        );

      case NodeType.circle:
        return Container(
          decoration: BoxDecoration(
            color: nodeData.color.withValues(alpha: 0.1),
            border: Border.all(color: nodeData.color, width: 2),
            shape: BoxShape.circle,
          ),
          child: child,
        );

      case NodeType.diamond:
        return CustomPaint(
          painter: DiamondPainter(color: nodeData.color),
          child: child,
        );

      case NodeType.text:
        return Container(
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            border: Border.all(color: Colors.grey.shade400, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: child,
        );
    }
  }
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

// Diamond Painter for diamond-shaped nodes
class DiamondPainter extends CustomPainter {
  final Color color;

  DiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width / 2, 0) // Top
      ..lineTo(size.width, size.height / 2) // Right
      ..lineTo(size.width / 2, size.height) // Bottom
      ..lineTo(0, size.height / 2) // Left
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
