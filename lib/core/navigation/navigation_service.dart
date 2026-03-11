import 'package:flutter/material.dart';

/// Serviço central de navegação
/// Elimina dependência circular e facilita navegação global
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  static BuildContext? get context => navigator?.context;
  
  /// Navega para uma rota
  static Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return navigator?.pushNamed(routeName, arguments: arguments) ?? Future.value();
  }
  
  /// Navega e substitui rota atual
  static Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return navigator?.pushReplacementNamed(routeName, arguments: arguments) ?? Future.value();
  }
  
  /// Navega e limpa stack
  static Future<dynamic> pushNamedAndRemoveUntil(String routeName, RoutePredicate predicate, {Object? arguments}) {
    return navigator?.pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments) ?? Future.value();
  }
  
  /// Volta para tela anterior
  static void pop<T>([T? result]) {
    navigator?.pop<T>(result);
  }
  
  /// Volta para tela anterior se possível
  static Future<bool> maybePop<T>([T? result]) async {
    return await navigator?.maybePop(result) ?? false;
  }
  
  /// Volta até rota específica
  static void popUntil(RoutePredicate predicate) {
    navigator?.popUntil(predicate);
  }
  
  /// Mostra dialog
  static Future<T?> showCustomDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    String? barrierLabel,
    Color? barrierColor,
    String? semanticsLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    return showDialog<T>(
      context: context!,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
    );
  }
  
  /// Mostra bottom sheet
  static Future<T?> showCustomModalBottomSheet<T>({
    required WidgetBuilder builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
  }) {
    return showModalBottomSheet<T>(
      context: context!,
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      routeSettings: routeSettings,
      transitionAnimationController: transitionAnimationController,
    );
  }
  
  /// Mostra SnackBar
  static void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: fontSize,
        ),
      ),
      duration: duration,
      action: action,
      backgroundColor: backgroundColor,
    );
    
    ScaffoldMessenger.of(context!).showSnackBar(snackBar);
  }
  
  /// Mostra SnackBar com erro
  static void showErrorSnackBar(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
    );
  }
  
  /// Mostra SnackBar com sucesso
  static void showSuccessSnackBar(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    );
  }
  
  /// Verifica se pode voltar
  static bool canPop() {
    return navigator?.canPop() ?? false;
  }
  
  /// Obtém rota atual
  static String? getCurrentRouteName() {
    final currentContext = context;
    if (currentContext == null) return null;
    return ModalRoute.of(currentContext)?.settings.name;
  }
  
  /// Verifica se está em rota específica
  static bool isCurrentRoute(String routeName) {
    final currentRouteName = getCurrentRouteName();
    return currentRouteName == routeName;
  }
  
  /// Navega para módulo específico
  static Future<dynamic> navigateToModule(int nicheId, {Object? arguments}) {
    return pushNamed('/module/$nicheId', arguments: arguments);
  }
  
  /// Navega para tela de configurações
  static Future<dynamic> navigateToSettings({String? tab}) {
    return pushNamed('/settings', arguments: tab);
  }
  
  /// Navega para perfil
  static Future<dynamic> navigateToProfile() {
    return pushNamed('/profile');
  }
  
  /// Navega para home
  static Future<dynamic> navigateToHome({bool clearStack = false}) {
    if (clearStack) {
      return pushNamedAndRemoveUntil('/home', (route) => false);
    }
    return pushNamed('/home');
  }
  
  /// Reinicia app (volta para onboarding/login)
  static Future<dynamic> restartApp() {
    return pushNamedAndRemoveUntil('/onboarding', (route) => false);
  }
  
  /// Navega para tela de conquistas
  static Future<dynamic> navigateToAchievements() {
    return pushNamed('/achievements');
  }
  
  /// Navega para analytics dashboard
  static Future<dynamic> navigateToAnalytics() {
    return pushNamed('/analytics');
  }
  
  /// Helper para mostrar diálogo de confirmação
  static Future<bool> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
  }) async {
    final result = await showCustomDialog<bool>(
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: confirmColor ?? Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  /// Helper para mostrar diálogo de loading
  static void showLoadingDialog({String message = 'Carregando...'}) {
    showCustomDialog(
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
  
  /// Esconde diálogo de loading
  static void hideLoadingDialog() {
    if (canPop()) {
      pop();
    }
  }
}
