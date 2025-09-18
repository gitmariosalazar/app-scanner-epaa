// lib/core/error/failure.dart
abstract class Failure {}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}
