import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Tela principal do aplicativo migrada para Riverpod
/// Demonstrando o uso dos providers e state management moderno
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar dados iniciais quando a tela for criada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    // Implementar carregamento inicial de dados
    // final gamificationService = ref.read(gamificationServiceProvider);
    // final localStorage = ref.read(localStorageServiceProvider);
    
    // Exemplo de uso dos services
    try {
      // Carregar estado da gamificação
      // gamificationService.loadUserProgress();
      
      // Carregar configurações locais
      // localStorage.getString('user_preferences');
      
      LoggerService.instance.i('Dados iniciais carregados com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar dados iniciais', error: e);
    }
  }

  void _refreshData() {
    // Implementar recarga de dados
    _loadInitialData();
    
    // Mostrar feedback para o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados recarregados!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Services disponíveis para uso quando necessário
    // final gamificationService = ref.watch(gamificationServiceProvider);
    // final authService = ref.watch(authServiceProvider);
    // final localStorage = ref.watch(localStorageServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disciplinum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Implementar navegação para configurações
              _navigateToSettings();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de boas-vindas
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            
            // Cards de resumo
            _buildSummaryCards(),
            const SizedBox(height: 24),
            
            // Seção de módulos ativos
            _buildActiveModules(),
            const SizedBox(height: 24),
            
            // Seção de progresso
            _buildProgressSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar funcionalidade principal
          _showQuickActions();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo ao Disciplinum!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Sua jornada de autodisciplina começa aqui.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.local_fire_department, size: 32, color: Colors.orange),
                  const SizedBox(height: 8),
                  Text(
                    '0',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Dias seguidos',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, size: 32, color: Colors.amber),
                  const SizedBox(height: 8),
                  Text(
                    '0',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    'Conquistas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveModules() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Módulos Ativos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.smoke_free, color: Colors.green),
              title: Text('Parar de Fumar'),
              subtitle: Text('0 dias sem fumar'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.savings, color: Colors.blue),
              title: Text('Economia Dinheiro'),
              subtitle: Text('R\$ 0,00 economizados'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso Geral',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              '0% completo',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Configurações',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              subtitle: const Text('Gerenciar suas informações'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil em desenvolvimento')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificações'),
              subtitle: const Text('Configurar alertas e lembretes'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notificações em desenvolvimento')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Aparência'),
              subtitle: const Text('Tema e cores'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aparência em desenvolvimento')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacidade'),
              subtitle: const Text('Dados e segurança'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacidade em desenvolvimento')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Novo Hábito'),
              onTap: () {
                Navigator.pop(context);
                _showAddHabitDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('Ver Estatísticas'),
              onTap: () {
                Navigator.pop(context);
                _showStatistics();
              },
            ),
            ListTile(
              leading: const Icon(Icons.celebration),
              title: const Text('Conquistas'),
              onTap: () {
                Navigator.pop(context);
                _showAchievements();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Hábito'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escolha um hábito para começar sua jornada:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.smoke_free, color: Colors.green),
              title: const Text('Parar de Fumar'),
              subtitle: const Text('Deixe o cigarro para trás'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Módulo Parar de Fumar ativado!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.savings, color: Colors.blue),
              title: const Text('Economizar Dinheiro'),
              subtitle: const Text('Controle seus gastos'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Módulo Economizar Dinheiro ativado!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.purple),
              title: const Text('Ler Mais'),
              subtitle: const Text('Desenvolva o hábito da leitura'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Módulo Ler Mais ativado!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estatísticas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Dias Consecutivos'),
              trailing: Text('0'),
            ),
            const ListTile(
              leading: Icon(Icons.local_fire_department),
              title: Text('Maior Sequência'),
              trailing: Text('0'),
            ),
            const ListTile(
              leading: Icon(Icons.emoji_events),
              title: Text('Conquistas'),
              trailing: Text('0'),
            ),
            const ListTile(
              leading: Icon(Icons.trending_up),
              title: Text('Taxa de Sucesso'),
              trailing: Text('0%'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showAchievements() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conquistas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.military_tech, color: Colors.brown),
              title: Text('Bronze'),
              subtitle: Text('Alcance o nível 10'),
              trailing: Icon(Icons.lock, color: Colors.grey),
            ),
            const ListTile(
              leading: Icon(Icons.military_tech, color: Colors.grey),
              title: Text('Prata'),
              subtitle: Text('Alcance o nível 25'),
              trailing: Icon(Icons.lock, color: Colors.grey),
            ),
            const ListTile(
              leading: Icon(Icons.military_tech, color: Colors.amber),
              title: Text('Ouro'),
              subtitle: Text('Alcance o nível 50'),
              trailing: Icon(Icons.lock, color: Colors.grey),
            ),
            const ListTile(
              leading: Icon(Icons.military_tech, color: Colors.blue),
              title: Text('Diamante'),
              subtitle: Text('Alcance o nível 100'),
              trailing: Icon(Icons.lock, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
