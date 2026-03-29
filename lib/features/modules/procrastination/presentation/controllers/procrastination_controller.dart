import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_model.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Controller Riverpod para Procrastination
/// Substitui o padrão ChangeNotifier por StateNotifier
class ProcrastinationController extends StateNotifier<ProcrastinationState> {
  final ProcrastinationService _service;
  
  ProcrastinationController(this._service) : super(const ProcrastinationState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final lists = _service.lists;
      final tasksByList = <String, List<ProcrastinationTask>>{};
      
      // Carregar tarefas para cada lista
      for (final list in lists) {
        tasksByList[list.id] = _service.getTasksForList(list.id);
      }
      
      state = state.copyWith(
        lists: lists,
        tasksByList: tasksByList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addList(String name) async {
    try {
      await _service.createList(name);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addTask(String listId, String title) async {
    try {
      final task = ProcrastinationTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        listId: listId,
      );
      await _service.addTaskToList(listId, task);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleTask(String listId, String taskId) async {
    try {
      await _service.toggleTaskInList(listId, taskId);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTask(String listId, String taskId) async {
    try {
      await _service.removeTaskFromList(listId, taskId);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      await _service.deleteList(listId);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Estado do ProcrastinationController
class ProcrastinationState {
  final List<TaskList> lists;
  final Map<String, List<ProcrastinationTask>> tasksByList;
  final bool isLoading;
  final String? error;

  const ProcrastinationState({
    this.lists = const [],
    this.tasksByList = const {},
    this.isLoading = false,
    this.error,
  });

  ProcrastinationState copyWith({
    List<TaskList>? lists,
    Map<String, List<ProcrastinationTask>>? tasksByList,
    bool? isLoading,
    String? error,
  }) {
    return ProcrastinationState(
      lists: lists ?? this.lists,
      tasksByList: tasksByList ?? this.tasksByList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider para o ProcrastinationController
final procrastinationControllerProvider = StateNotifierProvider<ProcrastinationController, ProcrastinationState>((ref) {
  final service = ref.watch(procrastinationServiceProvider);
  return ProcrastinationController(service);
});
