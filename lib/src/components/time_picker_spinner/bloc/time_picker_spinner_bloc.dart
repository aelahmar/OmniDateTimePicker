import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_datetime_picker/src/components/time_picker_spinner/bloc/utils.dart';

part 'time_picker_spinner_event.dart';
part 'time_picker_spinner_state.dart';

class TimePickerSpinnerBloc
    extends Bloc<TimePickerSpinnerEvent, TimePickerSpinnerState> {
  final String amText;
  final String pmText;
  final bool isShowSeconds;
  final bool is24HourMode;
  final int minutesInterval;
  final int secondsInterval;
  final bool isForce2Digits;
  final DateTime firstDateTime;
  final DateTime lastDateTime;
  final DateTime initialDateTime;

  TimePickerSpinnerBloc({
    required this.amText,
    required this.pmText,
    required this.isShowSeconds,
    required this.is24HourMode,
    required this.minutesInterval,
    required this.secondsInterval,
    required this.isForce2Digits,
    required this.firstDateTime,
    required this.lastDateTime,
    required this.initialDateTime,
  }) : super(TimePickerSpinnerInitial()) {
    on<Initialize>(_initialize);

    if (state is TimePickerSpinnerInitial) {
      add(Initialize());
    }
  }

  Future<void> _initialize(TimePickerSpinnerEvent event,
      Emitter<TimePickerSpinnerState> emit) async {
    final hours = _generateHours();
    final minutes = _generateMinutes();
    final seconds = _generateSeconds();
    final abbreviations = _generateAbbreviations();

    final now = initialDateTime;
    final initialHourIndex = _getInitialHourIndex(hours: hours, now: now);
    final initialMinuteIndex =
        _getInitialMinuteIndex(minutes: minutes, now: now);
    final initialSecondIndex =
        _getInitialSecondIndex(seconds: seconds, now: now);
    final initialAbbreviationIndex =
        _getInitialAbbreviationIndex(abbreviations: abbreviations, now: now);

    final abbreviationController = FixedExtentScrollController(
      initialItem: initialAbbreviationIndex,
    );

    emit(TimePickerSpinnerLoaded(
      allHours: hours,
      allMinutes: minutes,
      allSeconds: seconds,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      abbreviations: abbreviations,
      initialHourIndex: initialHourIndex,
      initialMinuteIndex: initialMinuteIndex,
      initialSecondIndex: initialSecondIndex,
      initialAbbreviationIndex: initialAbbreviationIndex,
      abbreviationController: abbreviationController,
    ));
  }

  int _getInitialHourIndex({
    required List<String> hours,
    required DateTime now,
  }) {
    if (!is24HourMode) {
      int hourOfPeriod = TimeOfDay.fromDateTime(now).hourOfPeriod;

      // Ensure 12 AM is displayed as '12' and not '0'
      String hourString = hourOfPeriod == 0 ? '12' : hourOfPeriod.toString();
      if (isForce2Digits && hourString != '12') {
        hourString = hourString.padLeft(2, '0');
      }

      return hours.indexWhere((e) => e == hourString);
    }

    String hourString = now.hour.toString();
    if (isForce2Digits) {
      hourString = hourString.padLeft(2, '0');
    }
    return hours.indexWhere((e) => e == hourString);
  }

  int _getInitialMinuteIndex({
    required List<String> minutes,
    required DateTime now,
  }) {
    final index = findClosestIndex(minutes, now.minute);
    return index;
  }

  int _getInitialSecondIndex({
    required List<String> seconds,
    required DateTime now,
  }) {
    final index = findClosestIndex(seconds, now.second);

    return index;
  }

  int _getInitialAbbreviationIndex({
    required List<String> abbreviations,
    required DateTime now,
  }) {
    if (now.hour >= 12) {
      return 1;
    } else {
      return 0;
    }
  }

  List<String> _generateHours() {
    final List<String> hours = List.generate(
      is24HourMode ? 24 : 12,
      (index) {
        if (!is24HourMode && index == 0) {
          // In 12-hour mode, hour 0 should be displayed as 12
          return isForce2Digits ? '12' : '12';
        }
        // Format with 2 digits if required (e.g., 00, 01, 02 for 24-hour mode)
        if (isForce2Digits) {
          return index.toString().padLeft(2, '0');
        }
        return '$index';
      },
    );

    return hours;
  }

  List<String> _generateMinutes() {
    final List<String> minutes = List.generate(
      (60 / minutesInterval).floor(),
      (index) {
        final value = index * minutesInterval;
        // Format with 2 digits if required (e.g., 00, 01, 02, ..., 59)
        if (isForce2Digits) {
          return value.toString().padLeft(2, '0');
        }
        return '$value';
      },
    );
    return minutes;
  }

  List<String> _generateSeconds() {
    final List<String> seconds = List.generate(
      (60 / secondsInterval).floor(),
      (index) {
        final value = index * secondsInterval;
        // Format with 2 digits if required (e.g., 00, 01, 02, ..., 59)
        if (isForce2Digits) {
          return value.toString().padLeft(2, '0');
        }
        return '$value';
      },
    );
    return seconds;
  }

  List<String> _generateAbbreviations() {
    return [
      amText,
      pmText,
    ];
  }
}
