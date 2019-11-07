import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_state.dart';
import 'package:number_trivia/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: BlocProvider(
        builder: (_) => serviceLocator<NumberTriviaBloc>(),
        child: Container(),
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
                  }
                  return widget;
                },
              ),
              SizedBox(height: 20),
              // Bottom Half
              Column(
                children: <Widget>[
                  // TextField
                  Placeholder(fallbackHeight: 40),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        // Search concrete button
                        child: Placeholder(fallbackHeight: 30),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        // Random Button
                        child: Placeholder(fallbackHeight: 30),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MessageDisplay extends StatelessWidget {
  final String message;

  const MessageDisplay({Key key, this.message})
      : assert(message != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      // Third of the size of the screen
      height: MediaQuery.of(context).size.height / 3,
      // Message Text Widgets / CircularLoadingIndicator
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            message,
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
