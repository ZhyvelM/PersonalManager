import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:manager/utils.dart' as utils;
import 'TasksModel.dart';

class TasksDBWorker {
  TasksDBWorker._();
  static final TasksDBWorker db = TasksDBWorker._();

  Database _db;

  Future get database async {
    if(_db == null)
      {
        _db = await init();
      }
    print("## Tasks TasksDBWorker.get-database(): _db = $_db");

    return _db;
  }

  Future<Database> init() async {

    print("Tasks TasksDBWorker.init()");

    String path = join(utils.docsDir.path, "tasks.db");
    print("## tasks TasksDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version : 1, onOpen: (db){},
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
          "CREATE TABLE IF NOT EXISTS tasks ("
              "id INTEGER PRIMARY KEY,"
              "description TEXT,"
              "dueDate TEXT,"
              "completed TEXT"
              ")"
        );
      }
    );
    return db;
  }

  Task taskFromMap(Map inMap){

    print("## Tasks TasksDBWorker.taskFromMap(): inMap = $inMap");

    Task task = Task();
    task.id = inMap["id"];
    task.description = inMap["description"];
    task.dueDate = inMap["dueDate"];
    task.completed = inMap["completed"];

    print("## Tasks TasksDBWorker.taskFromMap(): task = $task");

    return task;
  }

  Map<String, dynamic> taskToMap(Task inTask){
    print("## Tasks TasksDBWorker.taskToMap(): inTask = $inTask");

    Map<String, dynamic> map = Map<String,dynamic>();
    map["id"] = inTask.id;
    map["description"] = inTask.description;
    map["dueDate"] = inTask.dueDate;
    map["completed"] = inTask.completed;

    print("## tasks TasksDBWorker.taskToMap(): map = $map");

    return map;
  }

  Future create(Task inTask) async{

    print("## Tasks TasksDBWorker.create(): inTask = $inTask");

    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM tasks");
    int id = val.first["id"];
    if(id == null) {id =1;}

    inTask.id = id;
    return db.insert("tasks", taskToMap(inTask));

  }

  Future<Task> get(int inID) async {

    print("## Tasks TasksDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("tasks", where: "id = ?", whereArgs: [inID]);
    print("## Tasks TasksDBWorker.get(): rec.first = $rec.first");
    return taskFromMap(rec.first);
  }

  Future<List> getAll() async {
    print("## Tasks TasksDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("tasks");
    var list = recs.isNotEmpty ? recs.map((e) => taskFromMap(e)).toList() : [];

    print("## Tasks TasksDBWorker.getAll(): list = $list");

    return list;
  }

  Future update(Task inTask) async{

    print("## Tasks TasksDBWorker.update(): inTask = $inTask");

    Database db = await database;
    return await db.update("tasks", taskToMap(inTask), where: "id = ?", whereArgs: [inTask.id]);
  }

  Future delete(int inID) async{

    print("## Tasks TasksDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("tasks", where: "id = ?", whereArgs: [inID]);
  }
}