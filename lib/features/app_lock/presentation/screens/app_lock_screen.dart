import 'package:disciplinum/features/app_lock/domain/entities/app_lock_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';

/// Tela de bloqueio premium dark
/// AppLock style com disciplina consciente
class AppLockScreen extends StatelessWidget {
  final AppLockEvent lockEvent;

  const AppLockScreen({
    super.key,
    required this.lockEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo preto com transparência
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar transparente
            Container(
              height: 24,
              color: Colors.transparent,
            ),
            
            // Conteúdo principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mensagem personalizada do módulo (acima)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyan.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '⚠️ ATENÇÃO',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Mensagem personalizada do módulo
                          Text(
                            lockEvent.alertMessage,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Logo do app com ícone REAL do pacote
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.cyan.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: FutureBuilder<Uint8List?>(
                        // Usar appIconBytes do lockEvent se disponível, senão buscar
                        future: lockEvent.appIconBytes != null 
                            ? Future.value(lockEvent.appIconBytes)
                            : InstalledAppService().getAppIcon(lockEvent.packageName),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                snapshot.data!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            );
                          }

                          // Fallback enquanto carrega ou se falhar
                          return const Center(
                            child: Icon(
                              Icons.android,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Nome do app abaixo do ícone
                    Text(
                      lockEvent.appName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Botões de decisão
                    Row(
                      children: [
                        // Botão Sair do app
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              lockEvent.onExitApp();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.withValues(alpha: 0.2),
                              foregroundColor: Colors.cyan.withValues(alpha: 0.8),
                              side: BorderSide(
                                color: Colors.cyan.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: Colors.cyan.withValues(alpha: 0.8),
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sair do app',
                                  style: TextStyle(
                                    color: Colors.cyan.withValues(alpha: 0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Botão Abrir app
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              lockEvent.onOpenApp();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan.withValues(alpha: 0.1),
                              foregroundColor: Colors.cyan,
                              side: BorderSide(
                                color: Colors.cyan.withValues(alpha: 0.5),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.open_in_new,
                                  color: Colors.cyan,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Abrir app',
                                  style: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'e resetar progresso',
                                  style: TextStyle(
                                    color: Colors.cyan.withValues(alpha: 0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
