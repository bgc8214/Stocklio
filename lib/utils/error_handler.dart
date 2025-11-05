/// 사용자 친화적인 에러 메시지 변환 유틸리티
class ErrorHandler {
  /// 기술적 에러를 사용자 친화적 메시지로 변환
  static String getUserFriendlyMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // 네트워크 관련 에러
    if (errorStr.contains('socket') ||
        errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return '인터넷 연결을 확인해주세요';
    }

    // 타임아웃 에러
    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return '요청 시간이 초과되었습니다. 다시 시도해주세요';
    }

    // 데이터베이스 에러
    if (errorStr.contains('database') || errorStr.contains('sql')) {
      return '데이터 저장 중 문제가 발생했습니다';
    }

    // 파일 시스템 에러
    if (errorStr.contains('file') ||
        errorStr.contains('permission') ||
        errorStr.contains('access denied')) {
      return '파일 접근 권한이 없습니다';
    }

    // API 에러
    if (errorStr.contains('http') ||
        errorStr.contains('401') ||
        errorStr.contains('403')) {
      return '서비스 접근 권한이 없습니다';
    }

    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return '요청한 데이터를 찾을 수 없습니다';
    }

    if (errorStr.contains('500') ||
        errorStr.contains('502') ||
        errorStr.contains('503')) {
      return '서버에 일시적인 문제가 발생했습니다';
    }

    // 형식 에러
    if (errorStr.contains('format') || errorStr.contains('parse')) {
      return '데이터 형식이 올바르지 않습니다';
    }

    // 기본 메시지
    return '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
  }

  /// 에러를 로그로 출력 (디버그 모드에서만)
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    // ignore: avoid_print
    print('❌ [$context] Error: $error');
    if (stackTrace != null) {
      // ignore: avoid_print
      print('Stack trace: $stackTrace');
    }
  }
}
