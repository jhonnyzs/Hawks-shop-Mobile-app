// Unit tests for the Hawks Shop staff app.
import 'package:flutter_test/flutter_test.dart';
import 'package:hawks_shop_mobile/theme.dart';

void main() {
  test('status colours map correctly', () {
    expect(Hawks.status('paid'), Hawks.green);
    expect(Hawks.status('cancelled'), Hawks.red);
    expect(Hawks.status('in progress'), Hawks.gold);
    expect(Hawks.status('new'), Hawks.blue);
  });
}
