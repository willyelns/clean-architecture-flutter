import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/widgets/widgets.dart';
import 'package:number_trivia/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: buildBody(context),
      ),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      builder: (_) => serviceLocator<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              //Top Half
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  Widget widget;
                  if (state is Empty) {
                    widget = MessageDisplay(message: 'Start searching!');
                  } else if (state is Loading) {
                    widget = LoadingWidget();
                  } else if (state is Error) {
                    widget = MessageDisplay(message: state.message);
                  } else if (state is Loaded) {
                    widget = TriviaDisplay(
                      numberTrivia: state.trivia,
                    );
                  }
                  return widget;
                },
              ),
              SizedBox(height: 20),
              // Bottom Half
              TriviaControls(),
            ],
          ),
        ),
      ),
    );
  }
}
