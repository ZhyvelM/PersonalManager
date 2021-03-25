import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:manager/utils.dart' as utils;
import 'ContactsDBWorker.dart';
import 'ContactsModel.dart' show Contact, ContactsModel, contactsModel;

class ContactsList extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    print("## ContactsList.build()");

    return ScopedModel<ContactsModel>(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
          builder: (BuildContext inContext, Widget inChild,
              ContactsModel inModel) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white,),
                onPressed: () async {
                  File avatarFile = File(join(utils.docsDir.path, "avatar"));
                  if (avatarFile.existsSync()) {
                    avatarFile.deleteSync();
                  }
                  contactsModel.entityBeingEdited = Contact();
                  contactsModel.setChosenDate(null);
                  contactsModel.setStackIndex(1);
                },
              ),
              body: ListView.builder(
                  itemCount: contactsModel.entityList.length,
                  itemBuilder: (BuildContext inBuildContext, int inIndex) {
                    Contact contact = contactsModel.entityList[inIndex];
                    File avatarFile = File(
                        join(utils.docsDir.path, contact.id.toString()));
                    bool avatarFileExists = avatarFile.existsSync();
                    return Column(
                        children: [
                          Slidable(
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: .25,
                              secondaryActions: [
                                IconSlideAction(
                                  caption: "Delete",
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () =>
                                      _deleteContact(inContext, contact),
                                )
                              ],
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigoAccent,
                                  foregroundColor: Colors.white,
                                  backgroundImage: avatarFileExists ? FileImage(
                                      avatarFile) : null,
                                  child: avatarFileExists ? null : Text(
                                      contact.name.substring(0, 1)
                                          .toUpperCase()),
                                ),
                                title: Text("${contact.name}"),
                                onTap: () async {
                                  File avatarFile = File(
                                      join(utils.docsDir.path, "avatar"));
                                  if (avatarFile.existsSync()) {
                                    avatarFile.deleteSync();
                                  }
                                  contactsModel.entityBeingEdited =
                                  await ContactsDBWorker.db.get(contact.id);
                                  if (contactsModel.entityBeingEdited
                                      .birthsday == null) {
                                    contactsModel.setChosenDate(null);
                                  } else {
                                    List dateParts = contactsModel
                                        .entityBeingEdited.birthday.split(",");
                                    DateTime birthday = DateTime(
                                        int.parse(dateParts[0]),
                                        int.parse(dateParts[1]),
                                        int.parse(dateParts[2])
                                    );
                                    contactsModel.setChosenDate(
                                        DateFormat.yMMMMd("en_US").format(
                                            birthday.toLocal()));
                                  }
                                  contactsModel.setStackIndex(1);
                                },
                              )
                          ),
                          Divider()
                        ]
                    );
                  }
              ),
            );
          },
        )
    );
  }

  Future _deleteContact(BuildContext inContext, Contact inContact) async {

    print("## ContactsList._deleteContact(): inContact = $inContact");

    return showDialog(
        context: inContext,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text("Delete Contact"),
            content: Text("Are you sure you wan tot delete ${inContact.name}"),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(inAlertContext).pop();
                  },
                  child: Text("Cansel")
              ),
              TextButton(
                  onPressed: () async {
                    File avatarFile = File(join(utils.docsDir.path, inContact.id.toString()));
                    if (avatarFile.existsSync()) {
                      avatarFile.deleteSync();
                    }
                    await ContactsDBWorker.db.delete(inContact.id);
                    Navigator.of(inAlertContext).pop();
                    ScaffoldMessenger.of(inContext).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Contact deleted")
                      )
                    );
                    contactsModel.loadData("contacts", ContactsDBWorker.db);
                  },
                  child: Text("Delete")
              )
            ],
          );
        }
    );
  }
  
}