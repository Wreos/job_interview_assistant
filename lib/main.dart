import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _interviewsCollection =
  FirebaseFirestore.instance.collection('interviews');

  Stream<QuerySnapshot> getInterviews() {
    return _interviewsCollection.snapshots();
  }

  Future<void> addInterview(
      String name, String date, String location, String status) async {
    await _interviewsCollection.add({
      'name': name,
      'date': date,
      'location': location,
      'status': status,
    });
  }

  Future<void> deleteInterview(String id) async {
    await _interviewsCollection.doc(id).delete();
  }
}

class InterviewListWidget extends StatefulWidget {
  final FirebaseService firebaseService;

  const InterviewListWidget({required this.firebaseService});

  @override
  _InterviewListWidgetState createState() => _InterviewListWidgetState();
}

class _InterviewListWidgetState extends State<InterviewListWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _stausController = TextEditingController();
  List<DocumentSnapshot> _interviews = [];
  bool _formCompleted = false;

  void _updateFormCompleted() {
    setState(() {
      _formCompleted = _nameController.text.isNotEmpty &&
          _dateController.text.isNotEmpty &&
          _locationController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Job Interview List'),
        ),
        body: Column(
          children: <Widget>[
            Form(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          onChanged: (text) {
                            _updateFormCompleted();
                          },
                        ),
                        SizedBox(width: 20),
                        TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(labelText: 'Date'),
                          onChanged: (text) {
                            _updateFormCompleted();
                          },
                        ),
                        SizedBox(width: 20),
                        TextFormField(
                          controller: _locationController,
                          decoration:
                          const InputDecoration(labelText: 'Location'),
                          onChanged: (text) {
                            _updateFormCompleted();
                          },
                        ),
                        TextFormField(
                          controller: _stausController,
                          decoration:
                          const InputDecoration(labelText: 'Status'),
                          onChanged: (text) {
                            _updateFormCompleted();
                          },
                        )
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(
                          top: 20, bottom: 20, left: 20, right: 20),
                      width: 350,
                      child: Opacity(
                        opacity: _formCompleted ? 1 : 0.5,
                        child: OutlinedButton(
                          onPressed: _formCompleted
                              ? () {
                            widget.firebaseService.addInterview(
                                _nameController.text,
                                _dateController.text,
                                _locationController.text,
                                _stausController.text);
                            _nameController.clear();
                            _dateController.clear();
                            _locationController.clear();
                          }
                              : null,
                          child: Text('Add'),
                        ),
                      )),
                ],
              ),
            ),
            const Divider(
              thickness: 0.50,
              color: Colors.black,
            ),
            const Text(
              "Upcoming interviews",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: widget.firebaseService.getInterviews(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  _interviews = snapshot.data?.docs ?? [];
                  return ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                    itemCount: _interviews.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_interviews[index].get('name')),
                        subtitle: Text(_interviews[index].get('date')),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            widget.firebaseService
                                .deleteInterview(_interviews[index].id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(InterviewListWidget(firebaseService: FirebaseService()));
}
