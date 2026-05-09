import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';

import '../../gamification/domain/entities/digital_detox_fasting_break_info.dart';
import '../../gamification/domain/repositories/digital_detox_fasting_break_domain_repository.dart';
import '../providers/digital_detox_providers.dart';

/// Tela para gerenciar Quebras de Jejum Digital (FASE 7)
class DigitalDetoxFastingBreaksScreen extends ConsumerStatefulWidget {
  const DigitalDetoxFastingBreaksScreen({super.key});

  @override
  ConsumerState<DigitalDetoxFastingBreaksScreen> createState() => _DigitalDetoxFastingBreaksScreenState();
}

class _DigitalDetoxFastingBreaksScreenState extends ConsumerState<DigitalDetoxFastingBreaksScreen> {
  late DigitalDetoxFastingBreakRepository _repository;
  List<DigitalDetoxFastingBreakInfo> _availableBreaks = [];

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _loadAvailableBreaks();
  }

  void _initializeRepository() {
    final store = ObjectBoxService.instance.store;
    _repository = DigitalDetoxFastingBreakRepository(store.box<DigitalDetoxFastingBreakInfo>());
  }

  Future<void> _loadAvailableBreaks() async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      _availableBreaks = _repository.getActiveForUser(userId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar quebras: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quebras de Jejum'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _availableBreaks.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma quebra disponível\n\nToque as regras para ganhar novas!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _availableBreaks.length,
              itemBuilder: (context, index) {
                final breakInfo = _availableBreaks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      breakInfo.isActive ? Icons.local_cafe : Icons.coffee,
                      color: breakInfo.isActive ? Colors.green : Colors.grey,
                    ),
                    title: Text(breakInfo.formattedRequiredDays),
                    subtitle: Text(breakInfo.formattedCreatedAt),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(breakInfo.formattedExpiresAt),
                        const SizedBox(width: 8),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'use',
                              child: const Text('Usar Quebra'),
                            ),
                            PopupMenuItem(
                              value: 'cancel',
                              child: const Text('Cancelar Quebra'),
                            ),
                          ],
                          onSelected: (value) {
                            _handleBreakAction(breakInfo, value);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBreakDialog(context),
        tooltip: 'Criar Nova Quebra',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateBreakDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    int requiredDays = 1;
    int? validityDays;
    bool hasExpiry = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Criar Nova Quebra'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Dias necessários',
                    hintText: 'Quantos dias para ganhar esta quebra',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '1',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    final days = int.tryParse(value);
                    if (days == null || days < 1) {
                      return 'Mínimo de 1 dia';
                    }
                    return null;
                  },
                  onSaved: (value) => requiredDays = int.parse(value!),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Possui data de validade?'),
                  subtitle: const Text('A quebra expirará após alguns dias'),
                  value: hasExpiry,
                  onChanged: (value) => setState(() => hasExpiry = value ?? false),
                ),
                if (hasExpiry) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Dias de validade',
                      hintText: 'Quantos dias a quebra será válida',
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '30',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      final days = int.tryParse(value);
                      if (days == null || days < 1) {
                        return 'Mínimo de 1 dia';
                      }
                      return null;
                    },
                    onSaved: (value) => validityDays = int.parse(value!),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.of(context).pop();
                  await _createNewBreak(requiredDays, validityDays);
                }
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewBreak(int requiredDays, int? validityDays) async {
    try {
      final userId = ref.read(digitalDetoxCurrentUserIdProvider);
      
      final newBreak = DigitalDetoxFastingBreakInfo(
        userId: userId,
        createdAt: DateTime.now(),
        expiresAt: validityDays != null 
            ? DateTime.now().add(Duration(days: validityDays))
            : null,
        requiredDays: requiredDays,
        status: 'available',
      );

      await _repository.save(newBreak);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quebra criada com sucesso!')),
        );
      }
      
      await _loadAvailableBreaks(); // Recarregar lista
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar quebra: $e')),
        );
      }
    }
  }

  void _handleBreakAction(DigitalDetoxFastingBreakInfo breakInfo, String action) {
    switch (action) {
      case 'use':
        _useBreak(breakInfo);
        break;
      case 'cancel':
        _cancelBreak(breakInfo);
        break;
    }
  }

  void _useBreak(DigitalDetoxFastingBreakInfo breakInfo) async {
    try {
      final usedBreak = breakInfo.markAsUsed();
      await _repository.update(usedBreak);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quebra usada com sucesso!')),
        );
      }
      
      await _loadAvailableBreaks(); // Recarregar lista
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao usar quebra: $e')),
        );
      }
    }
  }

  void _cancelBreak(DigitalDetoxFastingBreakInfo breakInfo) async {
    try {
      final cancelledBreak = breakInfo.markAsExpired();
      await _repository.update(cancelledBreak);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quebra cancelada!')),
        );
      }
      
      await _loadAvailableBreaks(); // Recarregar lista
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar quebra: $e')),
        );
      }
    }
  }
}
