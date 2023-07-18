import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late List<UserData> userList;
  late List<String> patientNames;
  late List<String> patientNumbers;
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    selectedValue = null;
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
      final List<String> numbers =
          userDataList.map((userData) => userData.patientNumber).toList();

      setState(() {
        userList = userDataList;
        patientNames = names;
        patientNumbers = numbers;
      });
    } catch (error) {
      print('Error fetching user data: $error');
      // Handle the error here, e.g., show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    if (patientNames.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select a patient',
            border: OutlineInputBorder(),
          ),
          value: selectedValue,
          items: [
            DropdownMenuItem<String>(
              value: '',
              child: const Text('Select a patient'),
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
              selectedValue = value;
            });
          },
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
