import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';

abstract class UmrahGuideState extends Equatable {
  const UmrahGuideState();

  @override
  List<Object?> get props => [];
}

class UmrahGuideInitial extends UmrahGuideState {}

class UmrahGuideLoading extends UmrahGuideState {}

class UmrahGuideLoaded extends UmrahGuideState {
  final List<UmrahStep> steps;

  const UmrahGuideLoaded(this.steps);

  @override
  List<Object?> get props => [steps];
}

class UmrahGuideError extends UmrahGuideState {
  final String message;

  const UmrahGuideError(this.message);

  @override
  List<Object?> get props => [message];
}

class UmrahStep {
  final int id;
  final String title;
  final String description;
  final String? arabicText;
  final bool isCompleted;

  const UmrahStep({
    required this.id,
    required this.title,
    required this.description,
    this.arabicText,
    this.isCompleted = false,
  });

  UmrahStep copyWith({bool? isCompleted}) {
    return UmrahStep(
      id: id,
      title: title,
      description: description,
      arabicText: arabicText,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

abstract class UmrahGuideEvent extends Equatable {
  const UmrahGuideEvent();

  @override
  List<Object?> get props => [];
}

class LoadUmrahGuide extends UmrahGuideEvent {}

class CompleteStep extends UmrahGuideEvent {
  final int stepId;
  const CompleteStep(this.stepId);

  @override
  List<Object?> get props => [stepId];
}

class UncompleteStep extends UmrahGuideEvent {
  final int stepId;
  const UncompleteStep(this.stepId);

  @override
  List<Object?> get props => [stepId];
}

class ResetUmrahGuide extends UmrahGuideEvent {}

class UmrahGuideBloc extends Bloc<UmrahGuideEvent, UmrahGuideState> {
  final AppDatabase _database;

  static const List<Map<String, String>> _defaultSteps = [
    {
      'title': 'Ihram',
      'description': 'Enter the state of Ihram and make your intention.',
      'arabic': 'لبيك اللهم عمرة',
    },
    {
      'title': 'Tawaf',
      'description': 'Perform seven circuits around the Kaaba.',
      'arabic': 'سُبْحَانَ اللهِ وَالْحَمْدُ للهِ',
    },
    {
      'title': 'Sa\'i',
      'description': 'Walk seven times between the hills of Safa and Marwa.',
      'arabic': 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ',
    },
    {
      'title': 'Halq / Taqsir',
      'description': 'Shave or trim your hair to exit the state of Ihram.',
      'arabic': '',
    },
  ];

  UmrahGuideBloc(this._database) : super(UmrahGuideInitial()) {
    on<LoadUmrahGuide>(_onLoadUmrahGuide);
    on<CompleteStep>(_onCompleteStep);
    on<UncompleteStep>(_onUncompleteStep);
    on<ResetUmrahGuide>(_onResetUmrahGuide);
  }

  Future<void> _onLoadUmrahGuide(
    LoadUmrahGuide event,
    Emitter<UmrahGuideState> emit,
  ) async {
    emit(UmrahGuideLoading());
    try {
      final progressList = await _database
          .select(_database.umrahProgress)
          .get();

      if (progressList.isEmpty) {
        for (final step in _defaultSteps) {
          await _database
              .into(_database.umrahProgress)
              .insert(
                UmrahProgressCompanion.insert(
                  step: step['title']!,
                  completed: const Value(false),
                ),
              );
        }
        final initializedProgress = await _database
            .select(_database.umrahProgress)
            .get();
        emit(UmrahGuideLoaded(_mapToSteps(initializedProgress)));
      } else {
        emit(UmrahGuideLoaded(_mapToSteps(progressList)));
      }
    } catch (e) {
      emit(UmrahGuideError(e.toString()));
    }
  }

  List<UmrahStep> _mapToSteps(List<UmrahProgressData> progress) {
    return progress.asMap().entries.map((entry) {
      final idx = entry.key;
      final p = entry.value;
      final defaultInfo = idx < _defaultSteps.length
          ? _defaultSteps[idx]
          : null;

      return UmrahStep(
        id: p.id,
        title: p.step,
        description: defaultInfo?['description'] ?? '',
        arabicText: defaultInfo?['arabic'],
        isCompleted: p.completed,
      );
    }).toList();
  }

  Future<void> _onCompleteStep(
    CompleteStep event,
    Emitter<UmrahGuideState> emit,
  ) async {
    try {
      await (_database.update(_database.umrahProgress)
            ..where((t) => t.id.equals(event.stepId)))
          .write(const UmrahProgressCompanion(completed: Value(true)));
      add(LoadUmrahGuide());
    } catch (e) {
      emit(UmrahGuideError(e.toString()));
    }
  }

  Future<void> _onUncompleteStep(
    UncompleteStep event,
    Emitter<UmrahGuideState> emit,
  ) async {
    try {
      await (_database.update(_database.umrahProgress)
            ..where((t) => t.id.equals(event.stepId)))
          .write(const UmrahProgressCompanion(completed: Value(false)));
      add(LoadUmrahGuide());
    } catch (e) {
      emit(UmrahGuideError(e.toString()));
    }
  }

  Future<void> _onResetUmrahGuide(
    ResetUmrahGuide event,
    Emitter<UmrahGuideState> emit,
  ) async {
    try {
      await (_database.update(
        _database.umrahProgress,
      )).write(const UmrahProgressCompanion(completed: Value(false)));
      add(LoadUmrahGuide());
    } catch (e) {
      emit(UmrahGuideError(e.toString()));
    }
  }
}
