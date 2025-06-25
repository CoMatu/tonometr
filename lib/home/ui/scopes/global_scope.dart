import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tonometr/home/domain/bottom_bar_bloc.dart/bottom_bar_bloc.dart';

class GlobalScope extends StatelessWidget {
  const GlobalScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => BottomBarBloc())],
      child: child,
    );
  }
}
