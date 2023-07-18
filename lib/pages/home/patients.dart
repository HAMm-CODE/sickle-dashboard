import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({Key? key}) : super(key: key);

  @override
  _PatientsPageState createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  late List<UserData> userList;
  late List<UserData> filteredList;
  late TextEditingController searchController;
  late List<String> patientNames;
  late List<String> patientNumbers;
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    userList = [];
    filteredList = [];
    searchController = TextEditingController();
    selectedValue = null; // Clear the selected value
    patientNames = []; // Initialize the patientNames list
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration.zero, () {
      fetchUserData();
    });
  }

  Future<void> fetchUserData() async {
    print('Fetching Firestore collection...');
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    print('Firestore collection fetched successfully!');

    final List<UserData> userDataList = snapshot.docs.map((doc) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return UserData(
        patientNumber: data['patientNumber'] ?? '',
        name: data['name'] ?? '',
        address: data['address'] ?? '',
        bloodType: data['bloodType'] ?? '',
        highlighted: false,
      );
    }).toList();

    setState(() {
      userList = userDataList;
      filteredList = List.from(userList);
      patientNames = userList.map((userData) => userData.name).toList();
      patientNumbers =
          userList.map((userData) => userData.patientNumber).toList();
    });
  }

  void filterPatients(String searchText) {
    setState(() {
      if (searchText.isNotEmpty) {
        List<UserData> matchingList = [];
        List<UserData> nonMatchingList = [];

        for (final userData in userList) {
          if (userData.name.contains(searchText) ||
              userData.patientNumber.contains(searchText)) {
            matchingList.add(userData.copyWith(highlighted: true));
          } else {
            nonMatchingList.add(userData.copyWith(highlighted: false));
          }
        }

        filteredList = [...matchingList, ...nonMatchingList];
      } else {
        filteredList = List.from(userList);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                style: TextStyle(
                  color: Colors.black,
                ),
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by Name or Patient Number',
                  hintStyle: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w400),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                onChanged: filterPatients,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                      children: [
                        buildTableHeaderCell('Name'),
                        buildTableHeaderCell('Patient Number'),
                        buildTableHeaderCell('Address'),
                        buildTableHeaderCell('Blood Type'),
                      ],
                    ),
                    for (int i = 0; i < filteredList.length; i++)
                      TableRow(
                        decoration: i % 2 == 0
                            ? BoxDecoration(
                                color: Colors.grey[200],
                              )
                            : null,
                        children: [
                          buildTableCell(filteredList[i].name),
                          buildTableCell(filteredList[i].patientNumber),
                          buildTableCell(filteredList[i].address),
                          buildTableCell(filteredList[i].bloodType),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTableHeaderCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildTableCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class UserData {
  final String patientNumber;
  final String name;
  final String address;
  final String bloodType;
  final bool highlighted;

  UserData({
    required this.patientNumber,
    required this.name,
    required this.address,
    required this.bloodType,
    required this.highlighted,
  });

  UserData copyWith({
    String? patientNumber,
    String? name,
    String? address,
    String? bloodType,
    bool? highlighted,
  }) {
    return UserData(
      patientNumber: patientNumber ?? this.patientNumber,
      name: name ?? this.name,
      address: address ?? this.address,
      bloodType: bloodType ?? this.bloodType,
      highlighted: highlighted ?? this.highlighted,
    );
  }
}
