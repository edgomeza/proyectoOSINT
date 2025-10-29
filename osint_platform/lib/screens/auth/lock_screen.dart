import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/encryption_service.dart';
import '../../providers/theme_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  final bool isFirstLaunch;
  final VoidCallback onUnlocked;

  const LockScreen({
    super.key,
    required this.isFirstLaunch,
    required this.onUnlocked,
  });

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _encryptionService = EncryptionService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.isFirstLaunch) {
        // Configurar contraseña inicial
        if (_passwordController.text.isEmpty) {
          setState(() {
            _errorMessage = 'La contraseña no puede estar vacía';
            _isLoading = false;
          });
          return;
        }

        if (_passwordController.text.length < 6) {
          setState(() {
            _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
            _isLoading = false;
          });
          return;
        }

        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() {
            _errorMessage = 'Las contraseñas no coinciden';
            _isLoading = false;
          });
          return;
        }

        final success = await _encryptionService.setInitialPassword(_passwordController.text);
        if (success) {
          widget.onUnlocked();
        } else {
          setState(() {
            _errorMessage = 'Error al configurar la contraseña';
            _isLoading = false;
          });
        }
      } else {
        // Desbloquear con contraseña existente
        final success = await _encryptionService.unlockWithPassword(_passwordController.text);
        if (success) {
          await _encryptionService.decryptDatabase();
          widget.onUnlocked();
        } else {
          setState(() {
            _errorMessage = 'Contraseña incorrecta';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF0A0E27),
                    const Color(0xFF1A1F3A),
                    const Color(0xFF2A3F5F),
                  ]
                : [
                    const Color(0xFFFFF8E1),
                    const Color(0xFFFFE0B2),
                    const Color(0xFFFFCC80),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeInDown(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo/Icono
                        FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                    ? [
                                        const Color(0xFF6C63FF),
                                        const Color(0xFF00D9FF),
                                      ]
                                    : [
                                        const Color(0xFFFF9800),
                                        const Color(0xFFFF6F00),
                                      ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Título
                        FadeInDown(
                          delay: const Duration(milliseconds: 400),
                          child: Text(
                            widget.isFirstLaunch
                                ? 'Configurar Contraseña'
                                : 'Desbloquear Aplicación',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtítulo
                        FadeInDown(
                          delay: const Duration(milliseconds: 600),
                          child: Text(
                            widget.isFirstLaunch
                                ? 'Establece una contraseña segura para proteger tu información'
                                : 'Ingresa tu contraseña para acceder',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Campo de contraseña
                        FadeInUp(
                          delay: const Duration(milliseconds: 800),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            onSubmitted: widget.isFirstLaunch ? null : (_) => _handleSubmit(),
                          ),
                        ),

                        // Campo de confirmación (solo para primera vez)
                        if (widget.isFirstLaunch) ...[
                          const SizedBox(height: 16),
                          FadeInUp(
                            delay: const Duration(milliseconds: 1000),
                            child: TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              decoration: InputDecoration(
                                labelText: 'Confirmar Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    });
                                  },
                                ),
                              ),
                              onSubmitted: (_) => _handleSubmit(),
                            ),
                          ),
                        ],

                        // Mensaje de error
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          FadeIn(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Botón de submit
                        FadeInUp(
                          delay: const Duration(milliseconds: 1200),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      widget.isFirstLaunch ? 'Configurar' : 'Desbloquear',
                                      style: const TextStyle(
                                        inherit: false,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
