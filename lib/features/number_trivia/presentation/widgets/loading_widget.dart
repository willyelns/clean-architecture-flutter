import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
