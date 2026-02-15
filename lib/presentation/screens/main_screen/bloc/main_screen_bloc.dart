import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

abstract class MainScreenState extends Equatable {
  const MainScreenState();

  @override
  List<Object> get props => [];
}

class MainScreenInitial extends MainScreenState {}

class MainScreenLoaded extends MainScreenState {
  final int selectedIndex;

  const MainScreenLoaded({this.selectedIndex = 0});

  @override
  List<Object> get props => [selectedIndex];

  MainScreenLoaded copyWith({int? selectedIndex}) {
    return MainScreenLoaded(selectedIndex: selectedIndex ?? this.selectedIndex);
  }
}

abstract class MainScreenEvent extends Equatable {
  const MainScreenEvent();

  @override
  List<Object> get props => [];
}

class ChangeTab extends MainScreenEvent {
  final int index;

  const ChangeTab(this.index);

  @override
  List<Object> get props => [index];
}

class MainScreenBloc extends Bloc<MainScreenEvent, MainScreenState> {
  MainScreenBloc() : super(const MainScreenLoaded()) {
    on<ChangeTab>(_onChangeTab);
  }

  void _onChangeTab(ChangeTab event, Emitter<MainScreenState> emit) {
    if (state is MainScreenLoaded) {
      emit((state as MainScreenLoaded).copyWith(selectedIndex: event.index));
    }
  }
}
