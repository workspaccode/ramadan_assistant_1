import 'package:equatable/equatable.dart';

class TasbihState extends Equatable {
  final String currentDhikr;
  final int count;
  final int target;

  const TasbihState({
    this.currentDhikr = 'SubhanAllah',
    this.count = 0,
    this.target = 33,
  });

  TasbihState copyWith({String? currentDhikr, int? count, int? target}) {
    return TasbihState(
      currentDhikr: currentDhikr ?? this.currentDhikr,
      count: count ?? this.count,
      target: target ?? this.target,
    );
  }

  @override
  List<Object> get props => [currentDhikr, count, target];
}
