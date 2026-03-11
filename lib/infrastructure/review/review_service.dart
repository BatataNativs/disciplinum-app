import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const String _kPrefsDaysKey = 'review_days_count';
  static const String _kPrefsLastDayKey = 'review_last_day_check';
  static const String _kPrefsReviewDoneKey = 'review_prompt_shown';

  /// Chama a lógica de verificação. Deve ser iniciado no main ou na Home.
  static Future<void> checkRequestReview() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      final prefs = await SharedPreferences.getInstance();

      // Se já mostrou, não incomoda mais (ou implemente lógica para pedir novamente meses depois)
      final bool alreadyShown = prefs.getBool(_kPrefsReviewDoneKey) ?? false;
      if (alreadyShown) return;

      int daysCount = prefs.getInt(_kPrefsDaysKey) ?? 0;
      final String? lastDayString = prefs.getString(_kPrefsLastDayKey);

      final now = DateTime.now();
      final todayString = "${now.year}-${now.month}-${now.day}";

      // Se é um novo dia, incrementa contador
      if (lastDayString != todayString) {
        daysCount++;
        await prefs.setInt(_kPrefsDaysKey, daysCount);
        await prefs.setString(_kPrefsLastDayKey, todayString);
      }

      // Se atingiu 5 dias distintos de uso
      if (daysCount >= 5) {
        // Solicita review
        // requestReview() é o popup nativo do sistema (Apple/Google)
        // openStoreListing() abre a loja
        await inAppReview.requestReview();

        // Marca como feito
        await prefs.setBool(_kPrefsReviewDoneKey, true);
      }
    }
  }
}
