import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class BottomBarEvent extends Equatable {
  const BottomBarEvent();

  const factory BottomBarEvent.update(int index) = _UpdateBottomBarEvent;

  @override
  List<Object> get props => [];
}

class _UpdateBottomBarEvent extends BottomBarEvent {
  const _UpdateBottomBarEvent(this.index);

  final int index;
}

sealed class BottomBarState extends Equatable {
  const BottomBarState({this.index = 0});

  final int index;

  bool get isProcessing => this is ProcessingBottomBarState;
  bool get isLoaded => this is LoadedBottomBarState;
  bool get isFailure => this is FailureBottomBarState;

  @override
  List<Object> get props => [index];
}

class InitialBottomBarState extends BottomBarState {
  const InitialBottomBarState();
}

class ProcessingBottomBarState extends BottomBarState {
  const ProcessingBottomBarState({required super.index});
}

class LoadedBottomBarState extends BottomBarState {
  const LoadedBottomBarState({required super.index});
}

class FailureBottomBarState extends BottomBarState {
  const FailureBottomBarState({required super.index});
}

class BottomBarBloc extends Bloc<BottomBarEvent, BottomBarState> {
  BottomBarBloc() : super(const InitialBottomBarState()) {
    on<BottomBarEvent>(
      (event, emitter) async => switch (event) {
        _UpdateBottomBarEvent() => _update(event, emitter),
      },
    );
  }

  Future<void> _update(
    _UpdateBottomBarEvent event,
    Emitter<BottomBarState> emitter,
  ) async {
    emitter(LoadedBottomBarState(index: event.index));
  }
}
