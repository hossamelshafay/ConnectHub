/// Represents a failure in the application.
class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => 'Failure: $message';
}
