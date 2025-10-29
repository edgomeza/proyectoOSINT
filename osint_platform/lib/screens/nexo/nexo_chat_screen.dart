import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/theme_provider.dart';
import '../../config/theme.dart';
import '../../widgets/common/theme_toggle_button.dart';
import '../../widgets/common/language_selector.dart';
import '../../widgets/common/nexo_avatar.dart';

class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class NexoChatScreen extends ConsumerStatefulWidget {
  const NexoChatScreen({super.key});

  @override
  ConsumerState<NexoChatScreen> createState() => _NexoChatScreenState();
}

class _NexoChatScreenState extends ConsumerState<NexoChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Mensaje de bienvenida
    _messages.add(Message(
      content: '¡Hola! Soy Nexo, tu asistente inteligente para investigaciones OSINT. '
          '¿En qué puedo ayudarte hoy?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(Message(
        content: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simular respuesta de Nexo (aquí se integraría con un backend real)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(Message(
            content: _generateNexoResponse(userMessage),
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  String _generateNexoResponse(String userMessage) {
    // Respuestas simuladas basadas en palabras clave
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hola') || lowerMessage.contains('hi')) {
      return '¡Hola! ¿Cómo puedo asistirte en tu investigación?';
    } else if (lowerMessage.contains('ayuda') || lowerMessage.contains('help')) {
      return 'Puedo ayudarte con:\n\n'
          '• Búsqueda y recopilación de información\n'
          '• Análisis de datos\n'
          '• Extracción de entidades\n'
          '• Generación de informes\n'
          '• Sugerencias de fuentes\n\n'
          '¿Qué necesitas específicamente?';
    } else if (lowerMessage.contains('investigación') || lowerMessage.contains('caso')) {
      return 'Para crear una nueva investigación, ve a la sección de Investigaciones. '
          'Puedo ayudarte a planificar tu investigación, sugerir fuentes de datos '
          'y analizar la información recopilada.';
    } else if (lowerMessage.contains('análisis') || lowerMessage.contains('analizar')) {
      return 'Puedo realizar varios tipos de análisis:\n\n'
          '• Análisis de redes sociales\n'
          '• Extracción de entidades (NER)\n'
          '• Análisis de patrones\n'
          '• Correlación de datos\n'
          '• Visualización de relaciones\n\n'
          '¿Qué tipo de análisis necesitas?';
    } else if (lowerMessage.contains('gracias') || lowerMessage.contains('thank')) {
      return '¡De nada! Estoy aquí para ayudarte. Si necesitas algo más, no dudes en preguntar.';
    } else {
      return 'Entiendo tu consulta. Como asistente OSINT, puedo ayudarte con '
          'investigaciones, análisis de datos, extracción de información y mucho más. '
          '¿Podrías darme más detalles sobre lo que necesitas?';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header personalizado
              _buildHeader(context, isDarkMode),

              // Lista de mensajes
              Expanded(
                child: _messages.isEmpty
                    ? _buildEmptyState(context, isDarkMode)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isTyping) {
                            return _buildTypingIndicator(isDarkMode);
                          }
                          return _buildMessageBubble(_messages[index], isDarkMode);
                        },
                      ),
              ),

              // Input de mensaje
              _buildMessageInput(context, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón de regreso
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),

          const SizedBox(width: 12),

          // Avatar de Nexo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? AppTheme.darkPrimaryGradient
                  : AppTheme.lightPrimaryGradient,
              shape: BoxShape.circle,
            ),
            child: const NexoAvatar(size: 28),
          ),

          const SizedBox(width: 12),

          // Nombre y estado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nexo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'En línea',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Acciones
          const LanguageSelector(),
          const SizedBox(width: 8),
          const ThemeToggleButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? AppTheme.darkPrimaryGradient
                    : AppTheme.lightPrimaryGradient,
                shape: BoxShape.circle,
              ),
              child: const NexoAvatar(size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Hola! Soy Nexo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tu asistente inteligente para investigaciones OSINT',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isDarkMode) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment:
              message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? AppTheme.darkPrimaryGradient
                      : AppTheme.lightPrimaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const NexoAvatar(size: 20),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: message.isUser
                      ? (isDarkMode
                          ? AppTheme.darkPrimaryGradient
                          : AppTheme.lightPrimaryGradient)
                      : null,
                  color: message.isUser
                      ? null
                      : (isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 15,
                    color: message.isUser
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black87),
                  ),
                ),
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person_outline,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? AppTheme.darkPrimaryGradient
                  : AppTheme.lightPrimaryGradient,
              shape: BoxShape.circle,
            ),
            child: const NexoAvatar(size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(isDarkMode, 0),
                const SizedBox(width: 4),
                _buildDot(isDarkMode, 1),
                const SizedBox(width: 4),
                _buildDot(isDarkMode, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isDarkMode, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final opacity = (value - delay).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white : Colors.black54,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? AppTheme.darkPrimaryGradient
                  : AppTheme.lightPrimaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? AppTheme.darkPrimary : AppTheme.lightPrimary)
                      .withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _handleSendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
