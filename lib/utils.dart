import "dart:io";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "BaseModel.dart";

Directory docsDir;

Future selectDate(BuildContext inContext, BaseModel inModel, String inDateString) async
{
  print('## globals.selectDate()');

  DateTime initialDate = new DateTime.now();

  if(inDateString != null){
    List dateValues = inDateString.split(",");
    initialDate = DateTime(
        int.parse(dateValues[0]),
        int.parse(dateValues[1]),
        int.parse(dateValues[2]));
  }

  DateTime picked = await showDatePicker(
      context: inContext,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2200));

  if(picked != null){
    inModel.setChosenDate(DateFormat.yMMMMd("en_US").format(picked.toLocal()));
    return "${picked.year},${picked.month},${picked.day}";
  }
}