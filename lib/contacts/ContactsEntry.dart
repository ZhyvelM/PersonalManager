import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ContactsDBWorker.dart';
import 'package:manager/utils.dart' as utils;
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'ContactsModel.dart' show ContactsModel, contactsModel;

class ContactsEntry extends StatelessWidget {

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry() {
    print("## ContactsEntry.constructor");

    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("## ContactsEntry.build()");

    if (contactsModel.entityBeingEdited != null) {
      _nameEditingController.text = contactsModel.entityBeingEdited.title;
      _phoneEditingController.text = contactsModel.entityBeingEdited.content;
      _emailEditingController.text = contactsModel.entityBeingEdited.email;
    }

    return ScopedModel(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
          builder: (BuildContext inContext, Widget inChild,
              ContactsModel inModel) {
            File avatarFile = File(join(utils.docsDir.path, "avatar"));
            if (avatarFile.existsSync() == false) {
              if (inModel.entityBeingEdited != null &&
                  inModel.entityBeingEdited.id != null) {
                avatarFile = File(join(utils.docsDir.path,
                    inModel.entityBeingEdited.id.toString()));
              }
            }
            return Scaffold(
              bottomNavigationBar: Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          File avatarFile = File(join(utils.docsDir.path,
                              "avatar"));
                          if (avatarFile.existsSync()) {
                            avatarFile.deleteSync();
                          }
                          FocusScope.of(inContext).requestFocus(FocusNode());
                          inModel.setStackIndex(0);
                        },
                        child: Text("Cansel")
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        _save(inContext, contactsModel);
                      },
                      child: Text("Save"),
                    )
                  ],
                ),
              ),
              body: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      title: avatarFile.existsSync() ?
                      Image.file(avatarFile) :
                      Text("No avatar image for this contact"),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () => _selectAvatar(inContext),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: TextFormField(
                        decoration: InputDecoration(hintText: "Name"),
                        controller: _nameEditingController,
                        validator: (String inValue) {
                          if (inValue.length == 0) {
                            return "Please enter name";
                          }
                          return null;
                        },
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(hintText: "Phone"),
                        controller: _phoneEditingController,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(hintText: "Email"),
                        controller: _phoneEditingController,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.today),
                      title: Text("Date"),
                      subtitle: Text(
                          contactsModel.chosenDate == null ? "" : contactsModel
                              .chosenDate),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () async {
                          String chosenDate = await utils.selectDate(
                              inContext, contactsModel,
                              contactsModel.entityBeingEdited.apptDate
                          );
                          if (chosenDate != null) {
                            contactsModel.entityBeingEdited.apptDate =
                                chosenDate;
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        )
    );
  }


  void _save(BuildContext inContext, ContactsModel inModel) async {
    print("## ContactsEntry._save()");

    if (!_formKey.currentState.validate()) {
      return;
    }

    var id;

    if (inModel.entityBeingEdited.id == null) {
      print("## ContactsEntry._save(): Creating: ${inModel.entityBeingEdited}");
      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);
    } else {
      print("## ContactsEntry._save(): Updating: ${inModel.entityBeingEdited}");
      id = contactsModel.entityBeingEdited.id;
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
    }
    File avatarFile = File(join(utils.docsDir.path, "avatar"));
    if (avatarFile.existsSync()) {
      print("## ContactsEntry._save(): Renaming avatar file to id = $id");
      avatarFile.renameSync(join(utils.docsDir.path, id.toString()));
    }

    contactsModel.loadData("contacts", ContactsDBWorker.db);
    inModel.setStackIndex(0);

    ScaffoldMessenger.of(inContext).showSnackBar(
        SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            content: Text("Contact saved")
        )
    );
  }

  Future _selectAvatar(BuildContext inContext) {
    print("ContactsEntry._selectAvatar()");

    return showDialog(
        context: inContext,
        builder: (BuildContext inDialogContext) {
          final picker = ImagePicker();
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                      child: Text("Take a picture"),
                      onTap: () async {
                        var cameraImage = await picker.getImage(
                            source: ImageSource.camera);
                        if (cameraImage != null) {
                          File img = File(cameraImage.path);
                          img.copy(join(utils.docsDir.path, "avatar"));
                          contactsModel.triggerRebuild();
                        }
                        // Hide this dialog.
                        Navigator.of(inDialogContext).pop();
                      }
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  GestureDetector(
                    child: Text("Select From Gallery"),
                    onTap: () async {
                      var galleryImage = await picker.getImage(
                          source: ImageSource.gallery);
                      if (galleryImage != null) {
                        File img = File(galleryImage.path);
                        img.copy(join(utils.docsDir.path, "avatar"));
                        contactsModel.triggerRebuild();
                      }
                      Navigator.of(inDialogContext).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

}