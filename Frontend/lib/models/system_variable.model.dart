class SystemVariableModel {
  int? id;
  String varid;
  String varname;
  String? descr;
  String varvalue;

  SystemVariableModel({
    this.id,
    required this.varid,
    required this.varname,
    this.descr,
    required this.varvalue,
  });

  factory SystemVariableModel.fromJson(Map<String, dynamic> input) {
    return SystemVariableModel(
      id: input['id'],
      varid: input['varid'],
      varname: input['varname'],
      descr: input['descr'],
      varvalue: input['varvalue'],
    );
  }

  static List<SystemVariableModel> systemvariableDataFromJson(List<dynamic> input) {
    List<SystemVariableModel> list = [];

    for(var x in input) {
      list.add(SystemVariableModel.fromJson(x));
    }

    return list;
  }
}

class VariableValueModel {
  int? id;
  String varvalue;

  VariableValueModel({
    this.id,
    required this.varvalue,
  });

  factory VariableValueModel.fromJson(Map<String, dynamic> input) {
    return VariableValueModel(
      id: input['id'],
      varvalue: input['varvalue'],
    );
  }

  static List<VariableValueModel> variablevalueDataFromJson(List<dynamic> input) {
    List<VariableValueModel> list = [];

    for(var x in input) {
      list.add(VariableValueModel.fromJson(x));
    }

    return list;
  }
}