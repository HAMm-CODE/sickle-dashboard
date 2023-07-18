import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  String? name;
  List<String>? selectedTimes;
  List<String>? selectedPills;
  List<String>? selectedAmPms;

  Medicine(
      {this.name, this.selectedTimes, this.selectedPills, this.selectedAmPms});
}

class MakePrescription extends StatefulWidget {
  const MakePrescription({Key? key}) : super(key: key);

  @override
  _MakePrescriptionState createState() => _MakePrescriptionState();
}

class _MakePrescriptionState extends State<MakePrescription> {
  DateTime? selectedDate;
  String? selectedOption1;
  String? selectedOption2;
  final List<String> _medicine = [
    'Tablet',
    'Capsule',
    'Injection',
    'Syrup',
    'Powder',
    'Cream',
    'Inhaler',
    'Dropper',
    'Others',
  ];

  String? _selectedMedicine;
  String _selectedMeasurement = 'mg';
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _strengthController = TextEditingController();
  final TextEditingController _firstDoseTimeController =
      TextEditingController();
  bool _isEveryday = false;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _selectedDateController = TextEditingController();
  TimeOfDay? _selectedTime;
  final TextEditingController _timeController = TextEditingController();
  final List<String> _ampmOptions = ['am', 'pm'];
  String? _selectedAmPm = "am";
  String? _selectedFrequency;
  final List<String> _frequencyOptions = [
    'One Time Daily',
    'Two Times Daily',
    'Three Times Daily',
    'Four Times Daily',
  ];
  String? _selectedPill;
  final List<String> _pillOptions = ['1', '2', '3', '4'];

  get selectedAmPms => null;

  Future<void> _submitForm() async {
    final user = FirebaseAuth.instance.currentUser;
    final String medicine = _medicineController.text;
    final String strength = _strengthController.text;
    final String measurement = _selectedMeasurement;
    final String isEveryday = _isEveryday ? 'Yes' : 'No';
    final String instructions = _instructionsController.text;
    final String duration = _durationController.text;
    final String selectedDate = _selectedDateController.text;
    final String selectedTime =
        _selectedTime != null ? _selectedTime!.format(context) : '';

    List<String> selectedTimes =
        _selectedTimes.map((time) => time.format(context)).toList();

    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('medicines')
        .doc();

    await documentReference.set({
      'medicine': medicine,
      'type': _selectedMedicine,
      'strength': strength,
      'measurement': measurement,
      'amPm': _selectedAmPm,
      'isEveryday': isEveryday,
      'startDate': _startDate,
      'endDate': _endDate,
      'instructions': instructions,
      'duration': duration,
      'Medicine start date if not daily': selectedDate,
      'selectedTimes': selectedTimes,
      'selectedPills': _selectedPills,
      'selectedAMPMs': _selectedAmPms,
      'frequency': _selectedFrequency,
      'pill': _selectedPill,
      'number of times if not daily': selectedOption1,
      'number of days if not daily': selectedOption2,
    });
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Medicine added successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _medicineController.clear();
                _strengthController.clear();
                _firstDoseTimeController.clear();
                _instructionsController.clear();
                _durationController.clear();
                _selectedDateController.clear();
                setState(() {
                  _selectedMedicine = null;
                  _selectedMeasurement = 'mg';
                  _selectedAmPm = null;
                  _selectedTime = null;
                  _isEveryday = false;
                  _startDate = null;
                  _endDate = null;
                  _selectedTime = null;
                  _timeController.text = '';
                  _selectedFrequency = null;
                  _selectedPill = null;
                  selectedOption1 = null;
                  selectedOption2 = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _selectedDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedStartDate != null) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: pickedStartDate,
        firstDate: pickedStartDate,
        lastDate: DateTime(2100),
      );
      if (pickedEndDate != null) {
        setState(() {
          _startDate = pickedStartDate;
          _endDate = pickedEndDate;
          _durationController.text =
              '${_startDate!.toString()} - ${_endDate!.toString()}';
        });
      }
    }
  }

  void _selectTime(
      BuildContext context, TextEditingController? timeController) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && timeController != null) {
      const String selectedPill =
          "1"; // Retrieve the selected pill (e.g., from a dropdown)
      const String selectedAMPM =
          "am"; // Retrieve the selected AM/PM value (e.g., from a dropdown)

      setState(() {
        timeController.text = pickedTime.format(context);
        _selectedTimes.add(pickedTime);
        _selectedPills.add(selectedPill);
        _selectedAmPms.add(selectedAMPM);
      });
    }
  }

  final List<String> _selectedPills =
      []; // Declare the list to hold selected pills
  final List<TimeOfDay> _selectedTimes =
      []; // Declare the list to hold selected times
  final List<String> _selectedAmPms =
      []; // Declare the list to hold selected AM/PM values
  final List<TextEditingController> _timeControllers =
      []; // Declare the list to hold time controllers

  List<Widget> _buildFrequencyRows() {
    List<Widget> rows = [];
    if (_selectedFrequency != null) {
      int frequencyCount = _frequencyOptions.indexOf(_selectedFrequency!) + 1;
      while (_timeControllers.length < frequencyCount) {
        _timeControllers.add(TextEditingController());
      }
      for (int i = 1; i < frequencyCount; i++) {
        String? selectedPill =
            _selectedPills.length >= i ? _selectedPills[i - 1] : null;
        TimeOfDay? selectedTime =
            _selectedTimes.length >= i ? _selectedTimes[i - 1] : null;
        String? selectedAmPm =
            _selectedAmPms.length >= i ? _selectedAmPms[i - 1] : null;

        rows.add(Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Pills'),
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: DropdownButton<String>(
                              value: selectedPill,
                              onChanged: (newValue) {
                                setState(() {
                                  if (_selectedPills.length >= i) {
                                    _selectedPills[i - 1] = newValue!;
                                  } else {
                                    _selectedPills.add(newValue!);
                                  }
                                  selectedPill = newValue;
                                });
                              },
                              items: _pillOptions.map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Time'),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _timeControllers[i - 1],
                                  decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5.0),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "Time",
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 139, 136, 136),
                                    ),
                                  ),
                                  onTap: () => _selectTime(
                                      context, _timeControllers[i - 1]),
                                  readOnly: true,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedAmPm,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      if (_selectedAmPms.length >= i) {
                                        _selectedAmPms[i - 1] = newValue!;
                                      } else {
                                        _selectedAmPms.add(newValue!);
                                      }
                                      selectedAmPm = newValue;
                                    });
                                  },
                                  items: _ampmOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Make Prescription',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('What medicine would you like to add?'),
                      const SizedBox(height: 10.0),
                      TextField(
                        controller: _medicineController,
                        decoration: const InputDecoration(
                          // suffixIcon: Icon(Icons.calendar_today),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          contentPadding: EdgeInsets.all(10),
                          hintText: "Enter medicine name",
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 139, 136, 136),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Medicine Type'),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          itemCount: _medicine.length,
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final isSelected =
                                _selectedMedicine == _medicine[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMedicine = _medicine[index];
                                });
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.blue : Colors.grey,
                                ),
                                child: Center(
                                  child: Text(
                                    _medicine[index],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('What strength is the medicine?'),
                      const SizedBox(height: 5.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _strengthController,
                              decoration: const InputDecoration(
                                // suffixIcon: Icon(Icons.calendar_today),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(10),
                                hintText: "1",
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 139, 136, 136),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedMeasurement,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedMeasurement = newValue!;
                                });
                              },
                              items: <String>['mg', 'g', 'ml', 'unit']
                                  .map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Do you need to take this medicine everyday?'),
                      const SizedBox(height: 5.0),
                      SwitchListTile(
                        title: Text(_isEveryday ? 'Yes' : 'No'),
                        value: _isEveryday,
                        onChanged: (value) {
                          setState(() {
                            _isEveryday = value;
                          });
                        },
                      ),
                      if (_isEveryday) ...[
                        const SizedBox(height: 10.0),
                        const Text('How many times daily'),
                        DropdownButton<String>(
                          value: _selectedFrequency,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedFrequency = newValue!;
                            });
                          },
                          items:
                              _frequencyOptions.map<DropdownMenuItem<String>>(
                            (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            },
                          ).toList(),
                        ),
                        const SizedBox(height: 10.0),
                        const Row(
                          children: [
                            Text(
                              'Select time and pill for taking dosage',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10.0),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Select Pills'),
                                  Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: DropdownButton<String>(
                                      value: _selectedPill,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedPill = newValue!;
                                        });
                                      },
                                      items: _pillOptions
                                          .map<DropdownMenuItem<String>>(
                                        (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // const Text('When do you need to take the first dose?'),
                                  const Text('Select Time'),
                                  const SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _timeController,
                                          decoration: const InputDecoration(
                                            // suffixIcon: Icon(Icons.calendar_today),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.0),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide:
                                                  BorderSide(color: Colors.red),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5.0),
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.all(10),
                                            hintText: "Time",
                                            hintStyle: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 139, 136, 136),
                                            ),
                                          ),
                                          onTap: () => _selectTime(
                                              context, _timeController),
                                          readOnly: true,
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: DropdownButton<String>(
                                          value: _selectedAmPm,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _selectedAmPm = newValue;
                                            });
                                          },
                                          items:
                                              _ampmOptions.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Create frequency rows based on selected frequency
                        ..._buildFrequencyRows(),
                      ],
                    ],
                  ),
                ),
              ),
              if (!_isEveryday) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Medicine Start date'),
                        const SizedBox(height: 5.0),
                        GestureDetector(
                          onTap: selectDate,
                          child: AbsorbPointer(
                            child: TextFormField(
                                controller: _selectedDateController,
                                decoration: const InputDecoration(
                                  // suffixIcon: Icon(Icons.calendar_today),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                  hintText: "start date",
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 139, 136, 136),
                                  ),
                                ),
                                // controller: TextEditingController(
                                //   text: selectedDate != null
                                //       ? '${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'
                                //       : '',
                                // ),
                                readOnly: true,
                                onTap: () => selectDate()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'The medicine needs to be taken',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: selectedOption1,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedOption1 = newValue;
                                      });
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Once',
                                        child: Text('Once'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Two times',
                                        child: Text('Two times'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Three times',
                                        child: Text('Three times'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Four times',
                                        child: Text('Four times'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Others',
                                        child: Text('Others'),
                                      ),
                                    ],
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: " times",
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 139, 136, 136),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: selectedOption2,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedOption2 = newValue;
                                      });
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Every alt day',
                                        child: Text('Every alt day'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Every Week',
                                        child: Text('Every Week'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Every Fortnight',
                                        child: Text('Every Fortnight'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Every Month',
                                        child: Text('Every Month'),
                                      ),
                                    ],
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5.0),
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      hintText: " days",
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 139, 136, 136),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('What is the duration for this medication?'),
                      const SizedBox(height: 5.0),
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          // suffixIcon: Icon(Icons.calendar_today),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          contentPadding: EdgeInsets.all(10),
                          hintText: "Duration",
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 139, 136, 136),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => _selectDateRange(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Instructions for taking the medicine'),
                      const SizedBox(height: 5.0),
                      TextField(
                        controller: _instructionsController,
                        decoration: const InputDecoration(
                          // suffixIcon: Icon(Icons.calendar_today),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          contentPadding: EdgeInsets.all(10),
                          hintText: "Instructions",
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 139, 136, 136),
                          ),
                        ),
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 50,
                  width:
                      350, // Set the width to occupy the entire available space
                  child: ElevatedButton(
                    onPressed: () {
                      _submitForm();
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.grey),
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
          ),
        ),
      ),
    );
  }
}
