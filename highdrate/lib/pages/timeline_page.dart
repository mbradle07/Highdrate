
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'event.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Event>> events = {};
  TextEditingController _eventController = TextEditingController();
  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        title: const Text('Timeline Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                scrollable: true,
                title: Text("Note"),
                content: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: _eventController
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      events.addAll({
                        _selectedDay!: [Event(_eventController.text)]
                      });
                      Navigator.of(context).pop();
                      _selectedEvents.value = _getEventsForDay(_selectedDay!);
                    }, 
                    child: Text("Add"),
                  )
                ],
              );
            }
          );
        },
        child: Icon(Icons.add),
      ),
      body: tableCalendar(),
    );
  }

  Widget tableCalendar() {
    return Column(
      children: [
        TableCalendar(
          availableGestures: AvailableGestures.all,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          headerStyle: HeaderStyle(titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                  formatButtonTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                  ),
          daysOfWeekStyle: DaysOfWeekStyle(weekdayStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                          weekendStyle: TextStyle(color: Theme.of(context).colorScheme.primary)),
          calendarStyle: CalendarStyle(outsideDaysVisible: false, 
                                      rangeHighlightColor: Theme.of(context).colorScheme.primary,
                                      markerDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer,
                                                                      shape: BoxShape.circle),
                                      defaultTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                      weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                      todayTextStyle: TextStyle(color: Theme.of(context).colorScheme.primaryContainer),
                                      selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                      rangeStartTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                      rangeEndTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                      weekNumberTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                      withinRangeTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                      outsideTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                                      todayDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,
                                                                    shape: BoxShape.circle),
                                      selectedDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer,
                                                                        shape: BoxShape.circle),
                                      rangeStartDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, 
                                      shape: BoxShape.circle),
          ),
          focusedDay: _focusedDay, 
          firstDay: DateTime.utc(2023), 
          lastDay: DateTime.utc(2100),
          onDaySelected: _onDaySelected,
          eventLoader: _getEventsForDay,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        Expanded(child: ValueListenableBuilder<List<Event>>(
          valueListenable: _selectedEvents, 
          builder: (context, value, _) {
            return ListView.builder(itemCount: value.length, itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                  
                ),
                child: ListTile(
                  onTap: () => print(""),
                  title: Text("${_eventController.text}"),
                  textColor: Theme.of(context).colorScheme.primary,
                ),
              );
            });
          },
        ))
      ],
    );
  }
}

