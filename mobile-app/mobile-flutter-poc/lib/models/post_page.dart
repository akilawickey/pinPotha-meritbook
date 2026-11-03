class PostPage {
  int page = 1;
  int pageSize = 12;
  int pageCount(int count) => count == 0 ? 1 : (count / pageSize).ceil();
  void clamp(int count) {
    page = page.clamp(1, pageCount(count));
  }

  void resize(int size) {
    pageSize = size;
    page = 1;
  }

  List<T> items<T>(List<T> values) {
    clamp(values.length);
    return values.skip((page - 1) * pageSize).take(pageSize).toList();
  }
}
