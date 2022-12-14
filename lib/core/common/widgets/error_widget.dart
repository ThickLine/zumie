import 'package:flutter/material.dart';
import 'package:zumie/core/common/app_colors.dart';

class ErrorMessageWidget extends StatelessWidget {
  const ErrorMessageWidget(this.errorMessage, {super.key});
  final String errorMessage;
  @override
  Widget build(BuildContext context) {
    return Text(
      errorMessage,
      style:
          Theme.of(context).textTheme.headline6!.copyWith(color: kcErrorColor),
    );
  }
}
