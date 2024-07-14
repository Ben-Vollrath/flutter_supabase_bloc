import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('user', () {
    const id = 'mock-id';
    const email = 'mock-email';

    test('supports value comparisons', () {
      expect(
        User(email:email, id: id),
        equals(User(email: email, id: id))
      );
    });

    test('isEmpty returns true for empty user', () {
      expect(User.empty.isEmpty, true);
    });

    test('isEmpty returns false for not empty user', () {
      expect(User(email: email, id: id).isEmpty, false);
    });

    test('isNotEmpty returns false for empty user', () {
      expect(User.empty.isNotEmpty, false);
    });

    test('isNotEmpty returns true for not empty user', () {
      expect(User(email: email, id: id).isNotEmpty, true);
    });

    
  });
}