import 'package:flutter/material.dart';
import 'package:flutter_dashboard/responsive.dart';
import 'package:flutter_dashboard/const.dart';
import 'package:flutter_dashboard/widgets/profile/add_profile.dart';
import 'package:flutter_dashboard/widgets/profile/widgets/scheduled.dart';
import 'package:table_calendar/table_calendar.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        // borderRadius: BorderRadius.only(
        //   bottomLeft: Radius.circular(Responsive.isMobile(context) ? 10 : 30.0),
        //   topLeft: Radius.circular(Responsive.isMobile(context) ? 10 : 30.0),
        // ),
        color: cardBackgroundColor,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage("assets/images/avatar.png"),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Dr Ssekitoleko Elisa",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle navigation to UploadImage page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImageUploadPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    width: 1.0,
                  ),
                ),
                child: TableCalendar(
                  calendarFormat: _calendarFormat,
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2021),
                  lastDay: DateTime.utc(2030),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  headerStyle: const HeaderStyle(
                    titleTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 248, 246, 246),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 255, 253, 253),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Padding(
              //   padding:
              //       EdgeInsets.all(Responsive.isMobile(context) ? 15 : 20.0),
              //   child: const WeightHeightBloodCard(),
              // ),
              SizedBox(
                height: Responsive.isMobile(context) ? 20 : 40,
              ),
              Scheduled(),
            ],
          ),
        ),
      ),
    );
  }
}
