import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "ContactsDBWorker.dart";
import "ContactsList.dart";
import "ContactsEntry.dart";
import "ContactsModel.dart" show ContactsModel, contactsModel;

class Contacts extends StatelessWidget{

  Contacts(){

    print("## Appointments.constructor");
    contactsModel.loadData("appointments", ContactsDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
          builder: (BuildContext inContext, Widget inChild, ContactsModel inModel){
            return IndexedStack(
              index: inModel.stackIndex,
              children: [
                ContactsList(),
                ContactsEntry(),
              ],
            );
          },
        )
    );
  }

}