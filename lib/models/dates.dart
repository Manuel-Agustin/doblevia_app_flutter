class CalendarDate {
  int weekDay;
  int dayNumber;
  DateTime dateTime;
  bool isPast;
  bool isHoliday;
  bool isBooked;

  CalendarDate({required this.weekDay, required this.dayNumber, required this.dateTime, required this.isPast, required this.isHoliday, required this.isBooked});
}