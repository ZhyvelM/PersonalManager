import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'appointments/Appointments.dart';
import 'contacts/Contacts.dart';
import 'notes/Notes.dart';
import 'tasks/Tasks.dart';
import 'utils.dart' as utils;

void main() {
  startMeUp() async{
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(FlutterManager());
  }
  startMeUp();
}

class FlutterManager extends StatelessWidget{
  @override
  Widget build(BuildContext inContext) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Manager"),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.date_range),
                  text: "Appointments",
                ),
                Tab(
                  icon: Icon(Icons.contacts),
                  text: "Contacts",
                ),
                Tab(
                  icon: Icon(Icons.notes),
                  text: "Notes",
                ),
                Tab(
                  icon: Icon(Icons.assignment_turned_in_outlined),
                  text: "Tasks",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Appointments(),Contacts(),Notes(),Tasks(),
            ],
          ),
        ),
      ),
    );
  }

}
