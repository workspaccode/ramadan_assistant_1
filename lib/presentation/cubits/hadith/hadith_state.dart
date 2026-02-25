import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/data/models/hadith_model.dart';

abstract class HadithState extends Equatable {
  const HadithState();

  @override
  List<Object> get props => [];
}

class HadithInitial extends HadithState {}

class HadithLoading extends HadithState {}

class HadithLoaded extends HadithState {
  final List<Hadith> hadiths;

  const HadithLoaded(this.hadiths);

  @override
  List<Object> get props => [hadiths];
}

class HadithError extends HadithState {
  final String message;

  const HadithError(this.message);

  @override
  List<Object> get props => [message];
}
