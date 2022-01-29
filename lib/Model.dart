class Model {
  int status;
  List<Result> result;

  Model({this.status, this.result});

  Model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result.add(new Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.result != null) {
      data['result'] = this.result.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  int docNo;
  String data;
  String source;
  String dateTime;

  Result({this.docNo, this.data, this.source, this.dateTime});

  Result.fromJson(Map<String, dynamic> json) {
    docNo = json['DocNo'];
    data = json['Data'];
    source = json['Source'];
    dateTime = json['DateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DocNo'] = this.docNo;
    data['Data'] = this.data;
    data['Source'] = this.source;
    data['DateTime'] = this.dateTime;
    return data;
  }
}