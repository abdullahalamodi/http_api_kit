class _Undefined {
  const _Undefined();
}

const sentinel = _Undefined();

bool isUndefined(Object? value) => value is _Undefined;
