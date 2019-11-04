import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/error/failure.dart';

abstract class UseCase<Type, Params> {
  // Parameters have to be put into a container object so that they can be
  // included in this abstract base class method definition.
  Future<Either<Failure, Type>> call(Params params);
}

// This will be used by the code calling the use case whenever the use case
// doesn't accept any parameters.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
