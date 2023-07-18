import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyReports extends StatefulWidget {
  const WeeklyReports({Key? key}) : super(key: key);

  @override
  _WeeklyReportsState createState() => _WeeklyReportsState();
}

class _WeeklyReportsState extends State<WeeklyReports> {
  late List<UserData> userList;
  late List<UserData> filteredList;
  late TextEditingController searchController;
  late List<String> patientNames;
  late List<String> patientNumbers;
  String? selectedValue;
  int pageIndex = 0; // Track the current page index

  @override
  void initState() {
    super.initState();
    userList = [];
    filteredList = [];
    searchController = TextEditingController();
    selectedValue = null;
    patientNames = [];
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
        id: doc.id,
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

  void onUserSelected(String userId) {
    setState(() {
      pageIndex = 1; // Switch to the weekly reports page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View all weekly reports sent by patients'),
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
              child: PageView(
                controller: PageController(initialPage: pageIndex),
                onPageChanged: (index) {
                  setState(() {
                    pageIndex = index;
                  });
                },
                children: [
                  buildPatientListPage(),
                  buildWeeklyReportsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPatientListPage() {
    return SingleChildScrollView(
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
                buildUserCell(filteredList[i]),
                buildTableCell(filteredList[i].patientNumber),
                buildTableCell(filteredList[i].address),
                buildTableCell(filteredList[i].bloodType),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildUserCell(UserData userData) {
    return TableCell(
      child: GestureDetector(
        onTap: () => onUserSelected(userData.id),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            userData.name,
            style: TextStyle(
              color: userData.highlighted ? Colors.blue : Colors.black,
              fontWeight:
                  userData.highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
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

  Widget buildWeeklyReportsPage() {
    return const Text('Weekly Reports Page');
  }
}

class UserData {
  final String id;
  final String patientNumber;
  final String name;
  final String address;
  final String bloodType;
  final bool highlighted;

  UserData({
    required this.id,
    required this.patientNumber,
    required this.name,
    required this.address,
    required this.bloodType,
    required this.highlighted,
  });

  UserData copyWith({
    String? id,
    String? patientNumber,
    String? name,
    String? address,
    String? bloodType,
    bool? highlighted,
  }) {
    return UserData(
      id: id ?? this.id,
      patientNumber: patientNumber ?? this.patientNumber,
      name: name ?? this.name,
      address: address ?? this.address,
      bloodType: bloodType ?? this.bloodType,
      highlighted: highlighted ?? this.highlighted,
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weekly Reports App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeeklyReports(),
    );
  }
}
