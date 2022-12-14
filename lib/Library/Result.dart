class Result<V, E> {
  final V? value;
  final E? error;

  bool get hasValue => value != null;

  bool get hasError => error != null;

  Result.value(this.value) : error = null;

  Result.error(this.error) : value = null;
}

