class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'خطأ في الوصول للبيانات المحفوظة']);
}
