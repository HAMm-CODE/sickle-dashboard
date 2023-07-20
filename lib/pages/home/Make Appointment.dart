import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddAppointment extends StatefulWidget {
  const AddAppointment({Key? key}) : super(key: key);

  @override
  _AddAppointmentState createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  late List<UserData> userList;
  late List<String> patientNames;
  String? selectedPatient;
  final TextEditingController _treatmentsController = TextEditingController();
  DateTime? selectedTime;
  DateTime? selectedDate;
  final TextEditingController _appointmentDateController =
      TextEditingController();
  final TextEditingController _reminderTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userList = [];
    patientNames = [];
    selectedPatient = null;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      print('Fetching Firestore collection...');
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      print('Firestore collection fetched successfully!');

      final List<UserData> userDataList = snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserData(
          patientNumber: data['patientNumber'] ?? '',
          name: data['name'] ?? '',
        );
      }).toList();

      final List<String> names =
          userDataList.map((userData) => userData.name).toList();

      setState(() {
        userList = userDataList;
        patientNames = names;
        selectedPatient = names.isNotEmpty ? names[0] : null;
      });
    } catch (error) {
      print('Error fetching user data: $error');
      // Handle the error here, e.g., show an error message to the user
    }
  }

  void selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = DateTime(picked.year, picked.month, picked.day);
      });

      // Update the appointment date text field value
      _appointmentDateController.text =
          '${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}';
    }
  }

  void selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });

      // Update the reminder time text field value
      _reminderTimeController.text =
          TimeOfDay.fromDateTime(selectedTime!).format(context);
    }
  }

  void saveAppointment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedPatient == null) {
      return;
    }

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: selectedPatient)
        .get();

    if (snapshot.docs.isEmpty) {
      print('User not found');
      return;
    }

    final userDocument = snapshot.docs.first.reference;
    final appointmentDocument = userDocument.collection('appointments').doc();

    final appointmentData = {
      'patientName': selectedPatient,
      'treatments': _treatmentsController.text,
      'appointmentDate': selectedDate,
      'appointmentTime': selectedTime,
    };

    try {
      await appointmentDocument.set(appointmentData);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Appointment saved successfully'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context); // Go back to the previous screen
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error saving appointment: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to save appointment'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Appointment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Patient',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  contentPadding: EdgeInsets.all(10),
                  hintText: "Select a patient",
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 139, 136, 136),
                  ),
                ),
                value: selectedPatient,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select a patient'),
                  ),
                  ...patientNames.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPatient = value;
                  });
                },
              ),
              if (selectedPatient != null) ...[
                const SizedBox(height: 20),
                const Text(
                  'Appointment Date',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: selectDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.calendar_today),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        contentPadding: EdgeInsets.all(10),
                        hintText: "Select Date",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 139, 136, 136),
                        ),
                      ),
                      controller: _appointmentDateController,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Treatments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  maxLines: 5,
                  controller: _treatmentsController,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    contentPadding: EdgeInsets.all(10),
                    hintText: "Type here",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 139, 136, 136),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Appointment Time',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: selectTime,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.access_time),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        contentPadding: EdgeInsets.all(10),
                        hintText: "Select Time",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 139, 136, 136),
                        ),
                      ),
                      controller: _reminderTimeController,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 50,
                    width:
                        350, // Set the width to occupy the entire available space
                    child: ElevatedButton(
  onPressed: saveAppointment,
  style: ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    ),
    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
  ),
  child: const Text(
    'Submit',
    style: TextStyle(
      fontSize: 25,
    ),
  ),
),

                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class UserData {
  final String patientNumber;
  final String name;

  UserData({
    required this.patientNumber,
    required this.name,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AddAppointment(),
    );
  }
}
