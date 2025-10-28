import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';

class DiagramCanvasWidget extends StatefulWidget {
  final Function(PainterController)? onSave;
  final PainterController? initialController;

  const DiagramCanvasWidget({
    super.key,
    this.onSave,
    this.initialController,
  });

  @override
  State<DiagramCanvasWidget> createState() => _DiagramCanvasWidgetState();
}

class _DiagramCanvasWidgetState extends State<DiagramCanvasWidget> {
  late PainterController _controller;
  bool _showGrid = true;
  DrawMode _currentMode = DrawMode.line;

  @override
  void initState() {
    super.initState();
    _controller = widget.initialController ??
        PainterController(
          settings: PainterSettings(
            text: TextSettings(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            freeStyle: const FreeStyleSettings(
              color: Colors.blue,
              strokeWidth: 3,
            ),
            shape: ShapeSettings(
              paint: Paint()
                ..strokeWidth = 3
                ..color = Colors.blue
                ..style = PaintingStyle.stroke,
            ),
            scale: const ScaleSettings(
              enabled: true,
              minScale: 0.5,
              maxScale: 5.0,
            ),
          ),
        );
  }

  @override
  void dispose() {
    if (widget.initialController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(context),
        Expanded(
          child: Stack(
            children: [
              // Grid background (optional)
              if (_showGrid) _buildGridBackground(),
              // Canvas
              FlutterPainter(
                controller: _controller,
              ),
            ],
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
            // Drawing Tools
            _buildToolSection(
              context,
              title: 'Draw',
              children: [
                _buildToolButton(
                  context,
                  icon: Icons.edit,
                  label: 'Free',
                  isActive: _currentMode == DrawMode.line,
                  onPressed: () => _setDrawMode(DrawMode.line),
                ),
                _buildToolButton(
                  context,
                  icon: Icons.circle_outlined,
                  label: 'Circle',
                  isActive: _currentMode == DrawMode.circle,
                  onPressed: () => _setDrawMode(DrawMode.circle),
                ),
                _buildToolButton(
                  context,
                  icon: Icons.rectangle_outlined,
                  label: 'Rectangle',
                  isActive: _currentMode == DrawMode.rectangle,
                  onPressed: () => _setDrawMode(DrawMode.rectangle),
                ),
                _buildToolButton(
                  context,
                  icon: Icons.arrow_forward,
                  label: 'Arrow',
                  isActive: _currentMode == DrawMode.arrow,
                  onPressed: () => _setDrawMode(DrawMode.arrow),
                ),
                _buildToolButton(
                  context,
                  icon: Icons.text_fields,
                  label: 'Text',
                  isActive: _currentMode == DrawMode.text,
                  onPressed: () => _setDrawMode(DrawMode.text),
                ),
              ],
            ),
            const VerticalDivider(),

            // Color Selection
            _buildToolSection(
              context,
              title: 'Color',
              children: [
                _buildColorButton(Colors.black),
                _buildColorButton(Colors.blue),
                _buildColorButton(Colors.red),
                _buildColorButton(Colors.green),
                _buildColorButton(Colors.orange),
                _buildColorButton(Colors.purple),
              ],
            ),
            const VerticalDivider(),

            // Line Width
            _buildToolSection(
              context,
              title: 'Width',
              children: [
                _buildToolButton(
                  context,
                  icon: Icons.horizontal_rule,
                  label: 'Thin',
                  onPressed: () => _setStrokeWidth(2),
                ),
                _buildToolButton(
                  context,
                  icon: Icons.remove,
                  label: 'Medium',
                  onPressed: () => _setStrokeWidth(4),
                ),
                _buildToolButton(
                  context,
                  icon: Icons.drag_handle,
                  label: 'Thick',
                  onPressed: () => _setStrokeWidth(6),
                ),
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
                  icon: Icons.undo,
                  label: 'Undo',
                  onPressed: _controller.canUndo ? () => _controller.undo() : null,
                ),
                _buildToolButton(
                  context,
                  icon: Icons.redo,
                  label: 'Redo',
                  onPressed: _controller.canRedo ? () => _controller.redo() : null,
                ),
                _buildToolButton(
                  context,
                  icon: Icons.clear,
                  label: 'Clear',
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
    final isActive = _controller.settings.freeStyle.color == color;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: () => _setColor(color),
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
                      color: color.withValues(alpha:0.5),
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
        gridColor: Theme.of(context).colorScheme.outline.withValues(alpha:0.1),
      ),
      size: Size.infinite,
    );
  }

  void _setDrawMode(DrawMode mode) {
    setState(() {
      _currentMode = mode;

      switch (mode) {
        case DrawMode.line:
          _controller.freeStyleMode = FreeStyleMode.draw;
          break;
        case DrawMode.circle:
          _controller.shapeFactory = CircleFactory();
          break;
        case DrawMode.rectangle:
          _controller.shapeFactory = RectangleFactory();
          break;
        case DrawMode.arrow:
          _controller.shapeFactory = ArrowFactory();
          break;
        case DrawMode.text:
          _controller.addText();
          break;
      }
    });
  }

  void _setColor(Color color) {
    setState(() {
      _controller.freeStyleColor = color;
      _controller.shapePaint = Paint()
        ..strokeWidth = _controller.shapePaint?.strokeWidth ?? 3
        ..color = color
        ..style = PaintingStyle.stroke;
      _controller.textStyle = _controller.textStyle.copyWith(color: color);
    });
  }

  void _setStrokeWidth(double width) {
    setState(() {
      _controller.freeStyleStrokeWidth = width;
      _controller.shapePaint = Paint()
        ..strokeWidth = width
        ..color = _controller.shapePaint?.color ?? Colors.blue
        ..style = PaintingStyle.stroke;
    });
  }

  void _saveDiagram() {
    widget.onSave?.call(_controller);
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
          'Are you sure you want to clear the entire canvas? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _controller.clearDrawables();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

enum DrawMode {
  line,
  circle,
  rectangle,
  arrow,
  text,
}

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
