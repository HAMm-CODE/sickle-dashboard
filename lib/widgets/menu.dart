import 'package:flutter/material.dart';
import 'package:flutter_dashboard/login_page.dart';
import 'package:flutter_dashboard/model/menu_modal.dart';
import 'package:flutter_dashboard/pages/home/Make%20Appointment.dart';
import 'package:flutter_dashboard/pages/home/chart.dart';
import 'package:flutter_dashboard/pages/home/patients.dart';
import 'package:flutter_dashboard/pages/home/make_prescription.dart';
import 'package:flutter_dashboard/pages/home/weekly_report.dart';
import 'package:flutter_svg/svg.dart';

class Menu extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(int) navigateToPage; // Add this line

  const Menu({
    Key? key,
    required this.scaffoldKey,
    required this.navigateToPage, required void Function() signOut,
  }) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<MenuModel> menu = [
    MenuModel(icon: 'assets/svg/home.svg', title: "Overview"),
    MenuModel(icon: 'assets/svg/home.svg', title: "Patients"),
    MenuModel(icon: 'assets/svg/prescription.svg', title: "Make Prescription"),
    MenuModel(icon: 'assets/svg/history.svg', title: "Schedule Appointment"),
    MenuModel(icon: 'assets/svg/chat.svg', title: "ChatRoom"),
    MenuModel(icon: 'assets/svg/report.svg', title: "Weekly Reports"),
    MenuModel(icon: 'assets/svg/setting.svg', title: "Settings"),
    MenuModel(icon: 'assets/svg/signout.svg', title: "Signout"),
  ];

  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        color: const Color(0xFF171821),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              for (var i = 0; i < menu.length; i++)
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(6.0),
                    ),
                    color: selected == i
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selected = i;
                      });
                      widget.scaffoldKey.currentState!.openEndDrawer();
                      // Handle navigation logic here
                      void navigateToScreen(int index) {
                        // Perform navigation based on the selected menu item
                        switch (index) {
                          case 0:
                            // Navigate to DashboardPage
                            Navigator.pushReplacementNamed(
                                context, 'lib/widgets/menu.dart');
                            break;
                          case 1:
                            // Navigate to PatientsPage
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PatientsPage(),
                                ));
                            break;
                          case 2:
                            // Navigate to RecommendationPage
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MakePrescription(),
                                ));
                            break;
                          case 3:
                            // Navigate to ChartPage
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddAppointment(),
                                ));
                            break;
                          case 4:
                            // Navigate to ReportsPage
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatRoomPage(),
                                ));
                            break;
                          case 5:
                            // Navigate to SettingsPage
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WeeklyReports(),
                                ));
                            break;
                          // case 6:
                          //   // Navigate to SignOutPage
                          //   Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => LoginPage(),
                          //       ));
                          //   break;
                            case 7:
                            // Navigate to SignOutPage
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ));
                            break;
                        }
                      }

                      widget
                          .navigateToPage(i); // Call the navigateToPage method
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          child: SvgPicture.asset(
                            menu[i].icon,
                            color: selected == i ? Colors.black : Colors.grey,
                          ),
                        ),
                        Text(
                          menu[i].title,
                          style: TextStyle(
                            fontSize: 16,
                            color: selected == i ? Colors.black : Colors.grey,
                            fontWeight: selected == i
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
