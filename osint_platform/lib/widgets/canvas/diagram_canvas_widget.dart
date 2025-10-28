import 'package:flutter/material.dart';
import 'package:diagram_editor/diagram_editor.dart';

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
  Color _selectedColor = Colors.blue;
  bool _isLinkingMode = false;

  @override
  void initState() {
    super.initState();
    diagramEditorContext = DiagramEditorContext(
      policySet: MyPolicySet(
        onColorSelected: () => _selectedColor,
        onNodeTypeSelected: () => _selectedNodeType,
        onEditNodeText: _editNodeText,
      ),
    );
  }

  Future<void> _editNodeText(String componentId, String currentText) async {
    final controller = TextEditingController(text: currentText);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Node Text'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Text',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLines: 3,
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final component = diagramEditorContext.canvasReader.model.getComponent(componentId);
      if (component != null) {
        final nodeData = component.data as NodeData;
        nodeData.text = result;
        diagramEditorContext.canvasWriter.model.updateComponent(componentId);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(context),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
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

            // Actions
            _buildToolSection(
              context,
              title: 'Actions',
              children: [
                _buildToolButton(
                  context,
                  icon: Icons.link,
                  label: 'Connect Nodes (Click two nodes to connect)',
                  isActive: _isLinkingMode,
                  onPressed: () {
                    setState(() => _isLinkingMode = !_isLinkingMode);
                    if (_isLinkingMode) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Linking mode: Click two nodes to connect them with an arrow'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
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

  void _saveDiagram() {
    widget.onSave?.call(diagramEditorContext);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagram saved')),
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
  final Function(String, String) onEditNodeText;

  MyPolicySet({
    required this.onColorSelected,
    required this.onNodeTypeSelected,
    required this.onEditNodeText,
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
    // Component tap is handled by the CanvasControlPolicy
    // which provides default selection behavior
  }

  @override
  onComponentDoubleTap(String componentId) {
    MyPolicySet policySet = this as MyPolicySet;
    final component = canvasReader.model.getComponent(componentId);
    if (component != null) {
      final nodeData = component.data as NodeData;
      policySet.onEditNodeText(componentId, nodeData.text);
    }
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
