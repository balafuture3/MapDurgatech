/// status : 1
/// message : "success"
/// data : [{"id":"1","temp":"35","location":"10.6656,77.0014","direction":"E","createdAt":"2023-11-04 00:11:24"}]

class ModelNew {
  ModelNew({
      num status, 
      String message, 
      List<Data> data,}){
    _status = status;
    _message = message;
    _data = data;
}

  ModelNew.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data.add(Data.fromJson(v));
      });
    }
  }
  num _status;
  String _message;
  List<Data> _data;
ModelNew copyWith({  num status,
  String message,
  List<Data> data,
}) => ModelNew(  status: status ?? _status,
  message: message ?? _message,
  data: data ?? _data,
);
  num get status => _status;
  String get message => _message;
  List<Data> get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : "1"
/// temp : "35"
/// location : "10.6656,77.0014"
/// direction : "E"
/// createdAt : "2023-11-04 00:11:24"

class Data {
  Data({
      var id,
      String temp, 
      String location, 
      String direction, 
      String createdAt,}){
    _id = id;
    _temp = temp;
    _location = location;
    _direction = direction;
    _createdAt = createdAt;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _temp = json['temp'];
    _location = json['location'];
    _direction = json['direction'];
    _createdAt = json['createdAt'];
  }
  var _id;
  String _temp;
  String _location;
  String _direction;
  String _createdAt;
Data copyWith({  var id,
  String temp,
  String location,
  String direction,
  String createdAt,
}) => Data(  id: id ?? _id,
  temp: temp ?? _temp,
  location: location ?? _location,
  direction: direction ?? _direction,
  createdAt: createdAt ?? _createdAt,
);
  String get id => _id;
  String get temp => _temp;
  String get location => _location;
  String get direction => _direction;
  String get createdAt => _createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['temp'] = _temp;
    map['location'] = _location;
    map['direction'] = _direction;
    map['createdAt'] = _createdAt;
    return map;
  }

}