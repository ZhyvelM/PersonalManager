import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:manager/utils.dart' as utils;
import 'AppointmentsModel.dart';

class AppointmentsDBWorker {

  AppointmentsDBWorker._();
  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  Database _db;

  Future get database async {
    if(_db == null)
      {
        _db = await init();
      }
    print("## Appointments AppointmentsDBWorker.get-database(): _db = $_db");

    return _db;
  }

  Future<Database> init() async {

    print("Appointments AppointmentsDBWorker.init()");

    String path = join(utils.docsDir.path, "appointments.db");
    print("## appointments AppointmentsDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version : 1, onOpen: (db){},
      onCreate: (Database inDB, int inVersion) async {
        await inDB.execute(
            "CREATE TABLE IF NOT EXISTS appointments ("
                "id INTEGER PRIMARY KEY,"
                "title TEXT,"
                "description TEXT,"
                "apptDate TEXT,"
                "apptTime TEXT"
                ")"
        );
      }
    );
    return db;
  }

  Appointment appointmentFromMap(Map inMap){

    print("## Appointments AppointmentsDBWorker.appointmentFromMap(): inMap = $inMap");

    Appointment appointment = Appointment();
    appointment.id = inMap["id"];
    appointment.title = inMap["title"];
    appointment.description = inMap["description"];
    appointment.apptDate = inMap["apptDate"];
    appointment.apptTime = inMap["apptTime"];
    print("## appointments AppointmentsDBWorker.appointmentFromMap(): appointment = $appointment");
    return appointment;
  }

  Map<String, dynamic> appointmentToMap(Appointment inAppointment){
    print("## Appointments AppointmentsDBWorker.appointmentToMap(): inAppointment = $inAppointment");

    Map<String, dynamic> map = Map<String,dynamic>();
    map["id"] = inAppointment.id;
    map["title"] = inAppointment.title;
    map["description"] = inAppointment.description;
    map["apptDate"] = inAppointment.apptDate;
    map["apptTime"] = inAppointment.apptTime;

    print("## appointments AppointmentsDBWorker.appointmentToMap(): map = $map");

    return map;
  }

  Future create(Appointment inAppointment) async{

    print("## Appointments AppointmentsDBWorker.create(): inAppointment = $inAppointment");

    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM appointments");
    int id = val.first["id"];
    if(id == null) {id =1;}

    inAppointment.id = id;
    return db.insert("appointments", appointmentToMap(inAppointment));

  }

  Future<Appointment> get(int inID) async {

    print("## Appointments AppointmentsDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("appointments", where: "id = ?", whereArgs: [inID]);
    print("## Appointments AppointmentsDBWorker.get(): rec.first = $rec.first");
    return appointmentFromMap(rec.first);
  }

  Future<List> getAll() async {
    print("## Appointments AppointmentsDBWorker.getAll()");

    Database db = await database;
    var recs = await db.query("appointments");
    var list = recs.isNotEmpty ? recs.map((e) => appointmentFromMap(e)).toList() : [ ];

    print("## Appointments AppointmentsDBWorker.getAll(): list = $list");

    return list;
  }

  Future update(Appointment inAppointment) async{

    print("## Appointments AppointmentsDBWorker.update(): inAppointment = $inAppointment");

    Database db = await database;
    return await db.update("appointments", appointmentToMap(inAppointment), where: "id = ?", whereArgs: [inAppointment.id]);
  }

  Future delete(int inID) async{

    print("## Appointments AppointmentsDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("appointments", where: "id = ?", whereArgs: [inID]);
  }
}