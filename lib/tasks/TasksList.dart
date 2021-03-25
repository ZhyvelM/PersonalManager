import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'TasksDBWorker.dart';
import 'TasksModel.dart' show Task, TasksModel, tasksModel;

class TasksList extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    print("## TasksList.build()");

    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
          builder: (BuildContext inContext, Widget inChild,
              TasksModel inModel) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white,),
                onPressed: () async {
                  tasksModel.entityBeingEdited = Task();
                  tasksModel.setChosenDate(null);
                  tasksModel.setStackIndex(1);
                },
              ),
              body: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                itemCount: tasksModel.entityList.length,
                itemBuilder: (BuildContext inBuildContext, int inIndex) {
                  Task task = tasksModel.entityList[inIndex];
                  String sDueDate;
                  if (task.dueDate != null) {
                    List dateParts = task.dueDate.split(",");
                    DateTime dueDate = DateTime(
                        int.parse(dateParts[0]), int.parse(dateParts[1]),
                        int.parse(dateParts[2]));
                    sDueDate =
                        DateFormat.yMMMMd("en_US").format(dueDate.toLocal());
                  }
                  return Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: .25,
                      child: ListTile(
                        leading: Checkbox(
                          value: task.completed == "true" ? true : false,
                          onChanged: (inValue) async {
                            task.completed = inValue.toString();
                            await TasksDBWorker.db.update(task);
                            tasksModel.loadData("tasks", TasksDBWorker.db);
                          },
                        ),
                        title: Text(
                          "${task.description}",
                          style: task.completed == "true" ?
                          TextStyle(color: Theme
                              .of(inContext)
                              .disabledColor, decoration: TextDecoration
                              .lineThrough) :
                          TextStyle(color: Theme
                              .of(inContext)
                              .textTheme
                              .headline6
                              .color),
                        ),
                        subtitle: task.dueDate == null ?
                        null :
                        Text(
                            sDueDate,
                            style: task.completed == "true" ?
                            TextStyle(color: Theme
                                .of(inContext)
                                .disabledColor,
                                decoration: TextDecoration.lineThrough)
                                :
                            TextStyle(color: Theme
                                .of(inContext)
                                .textTheme
                                .headline6
                                .color)
                        ),
                        onTap: () async {
                          if (task.completed == "true") {
                            return;
                          }
                          tasksModel.entityBeingEdited = await TasksDBWorker
                              .db
                              .get(task.id);
                          if (tasksModel.entityBeingEdited.dueDate == null) {
                            tasksModel.setChosenDate(null);
                          } else {
                            tasksModel.setChosenDate(sDueDate);
                          }
                          tasksModel.setStackIndex(1);
                        },
                      ),
                      secondaryActions: [
                        IconSlideAction(
                          caption: "Delete",
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => _deleteTask(inContext, task),
                        )
                      ]
                  );
                }
              ),
            );
          },
        )
    );
  }

  Future _deleteTask(BuildContext inContext, Task inTask) async {

    print("## TasksList._deleteTask(): inTask = $inTask");

    return showDialog(
        context: inContext,
        builder: (BuildContext inAlertContext) {
          return AlertDialog(
            title: Text("Delete Task"),
            content: Text("Are you sure you wan tot delete ${inTask.description}"),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(inAlertContext).pop();
                  },
                  child: Text("Cansel")
              ),
              TextButton(
                  onPressed: () async {
                    await TasksDBWorker.db.delete(inTask.id);
                    Navigator.of(inAlertContext).pop();
                    ScaffoldMessenger.of(inContext).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Task deleted")
                      )
                    );
                    tasksModel.loadData("tasks", TasksDBWorker.db);
                  },
                  child: Text("Delete")
              )
            ],
          );
        }
    );
  }
  
}