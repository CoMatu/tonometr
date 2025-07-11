import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tonometr/blood_pressure/domain/blood_pressure_repository.dart';
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/core/services/event_bus.dart';
import 'package:tonometr/database/db.dart';
import 'package:tonometr/calendar/ui/widgets/calendar_day_cell.dart';
import 'package:tonometr/calendar/ui/dialogs/day_measurements_dialog.dart';

@RoutePage()
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Measurement>> _events;
  late BloodPressureRepository _repository;
  StreamSubscription<DataChangedEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
    _repository = context.dependencies.bloodPressureRepository;
    _loadMeasurements();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToEvents() {
    _eventSubscription = EventBus().on<DataChangedEvent>().listen((event) {
      if (event.dataType == 'measurements' && mounted) {
        _loadMeasurements();
      }
    });
  }

  Future<void> _loadMeasurements() async {
    final measurements = await _repository.getAllMeasurements();
    final eventsMap = <DateTime, List<Measurement>>{};

    for (final measurement in measurements) {
      final date = DateTime(
        measurement.createdAt.year,
        measurement.createdAt.month,
        measurement.createdAt.day,
      );

      if (eventsMap[date] == null) {
        eventsMap[date] = [];
      }
      eventsMap[date]!.add(measurement);
    }

    setState(() {
      _events = eventsMap;
    });
  }

  List<Measurement> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Календарь')),
      body: TableCalendar<Measurement>(
        locale: 'ru_RU',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          final events = _getEventsForDay(selectedDay);
          if (events.isNotEmpty) {
            showDialog(
              context: context,
              builder:
                  (context) => DayMeasurementsDialog(
                    selectedDay: selectedDay,
                    measurements: events,
                  ),
            );
          }
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        rowHeight: 80,
        daysOfWeekHeight: 40,
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Colors.red),
          markerSize: 0,
        ),

        availableCalendarFormats: const {CalendarFormat.month: 'Месяц'},
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final events = _getEventsForDay(day);
            return CalendarDayCell(day: day, measurements: events);
          },
          selectedBuilder: (context, day, focusedDay) {
            final events = _getEventsForDay(day);
            return CalendarDayCell(
              day: day,
              measurements: events,
              isSelected: true,
            );
          },
          todayBuilder: (context, day, focusedDay) {
            final events = _getEventsForDay(day);
            return CalendarDayCell(
              day: day,
              measurements: events,
              isToday: true,
            );
          },
          dowBuilder: (context, day) {
            final text = DateFormat.E('ru_RU').format(day);
            return Center(
              child: Text(
                text.toUpperCase(),
                style: TextStyle(
                  color:
                      day.weekday == DateTime.sunday ||
                              day.weekday == DateTime.saturday
                          ? Colors.red
                          : isDarkMode
                          ? Colors.white
                          : Colors.black,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
