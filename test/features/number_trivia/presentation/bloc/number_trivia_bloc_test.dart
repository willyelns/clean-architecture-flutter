import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failure.dart';
import 'package:number_trivia/core/presentation/util/input_converter.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

class MockNumberTriviaBloc
    extends MockBloc<NumberTriviaEvent, NumberTriviaState>
    implements NumberTriviaBloc {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initialState should be Empty', () {
    // assert
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    // The event takes in a String
    final tNumberString = '1';
    // this is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);
    // NumberTrivia instance is needed too, of course
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));

    void setUpMockInputConverterError() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));

    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
      // arrange
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Right(tNumberParsed));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      // assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid - normal test',
        () async {
      // arrange
      setUpMockInputConverterError();
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      // assert
      final expected = [
        // The initial state is always emitted first
        Empty(),
        Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];
      emitsExactly(bloc, expected);
    });

    blocTest(
      'should emit [Error] when the input is invalid - bloc test',
      build: () => bloc,
      act: (bloc) async {
        setUpMockInputConverterError();
        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
      expect: [
        // The initial state is always emitted first
        Empty(),
        Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ],
    );

    test('should get data from the concrete use case', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));
      // assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });
    test(
        'should emit [Loading, Loaded] when data is gotten successfully - Normal Test',
        () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      // assert later
      final expected = [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      emitsExactly(bloc, expected);
    });
    blocTest(
        'should emit [Loading, Loaded] when data is gotten successfully - Bloc Test',
        build: () => bloc,
        act: (bloc) async {
          // arrange
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => Right(tNumberTrivia));
          // act
          bloc.add(GetTriviaForConcreteNumber(tNumberString));
        },
        expect: [
          Empty(),
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ]);

    blocTest(
      'should emit [Loading, Error] when getting data fails',
      build: () => bloc,
      act: (bloc) async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
      expect: [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ],
    );

    blocTest(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      build: () => bloc,
      act: (bloc) async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
      expect: [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ],
    );

    blocTest(
      'should emit [Loading, Error] with Unexpected Error message if the Failure is not mapped',
      build: () => bloc,
      act: (bloc) async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(null));
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
      expect: [
        Empty(),
        Loading(),
        Error(message: 'Unexpected Error'),
      ],
    );
  });

  group('GetTriviaForRandomNumber', () {
    // NumberTrivia instance is needed too, of course
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test('should get data from the random use case', () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(any));
      // assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });
    blocTest('should emit [Loading, Loaded] when data is gotten successfully',
        build: () => bloc,
        act: (bloc) async {
          // arrange
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => Right(tNumberTrivia));
          // act
          bloc.add(GetTriviaForRandomNumber());
        },
        expect: [
          Empty(),
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ]);

    blocTest(
      'should emit [Loading, Error] when getting data fails',
      build: () => bloc,
      act: (bloc) async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        bloc.add(GetTriviaForRandomNumber());
      },
      expect: [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ],
    );

    blocTest(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      build: () => bloc,
      act: (bloc) async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
      expect: [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ],
    );

    blocTest(
      'should emit [Loading, Error] with Unexpected Error message if the Failure is not mapped',
      build: () => bloc,
      act: (bloc) async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(null));
        bloc.add(GetTriviaForRandomNumber());
      },
      expect: [
        Empty(),
        Loading(),
        Error(message: 'Unexpected Error'),
      ],
    );
  });
}
