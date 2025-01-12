#!/bin/bash
if [ ! -d "test" ]; then
  echo "No 'test' directory found. Creating one..."
  mkdir test
  cat > test/placeholder_test.dart << EOF
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder test', () {
    expect(true, isTrue);
  });
}
EOF
fi
