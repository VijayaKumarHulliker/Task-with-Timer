import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';


class Task {
  final String title;
  final int secondsLeft;

  Task({required this.title, required this.secondsLeft});

  Task copyWith({int? secondsLeft}) {
    return Task(
      title: title,
      secondsLeft: secondsLeft ?? this.secondsLeft,
    );
  }
}


abstract class TodoEvent {}

class AddTaskEvent extends TodoEvent {
  final String taskTitle;
  AddTaskEvent(this.taskTitle);
}

class TimerTickEvent extends TodoEvent {}


abstract class TodoState {
  final List<Task> tasks;
  TodoState(this.tasks);
}

class TodoInitialState extends TodoState {
  TodoInitialState() : super([]);
}

class TodoUpdatedState extends TodoState {
  TodoUpdatedState(List<Task> tasks) : super(tasks);
}


class TodoBloc extends Bloc<TodoEvent, TodoState> {
  Timer? _timer;

  TodoBloc() : super(TodoInitialState()) {
    on<AddTaskEvent>(_onAddTask);
    on<TimerTickEvent>(_onTimerTick);

   
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TimerTickEvent());
    });
  }

  void _onAddTask(AddTaskEvent event, Emitter<TodoState> emit) {
    final updatedTasks = List<Task>.from(state.tasks);
    updatedTasks.add(Task(title: event.taskTitle, secondsLeft: 60));
    emit(TodoUpdatedState(updatedTasks));
  }

  void _onTimerTick(TimerTickEvent event, Emitter<TodoState> emit) {
    final updatedTasks = state.tasks
        .map((task) => task.secondsLeft > 1
            ? task.copyWith(secondsLeft: task.secondsLeft - 1)
            : null) // Remove expired tasks
        .whereType<Task>()
        .toList();

    emit(TodoUpdatedState(updatedTasks));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
