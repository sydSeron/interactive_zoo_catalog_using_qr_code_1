class Animal {
  //Attributes
  String? name;
  String? sciname;
  String? zookeepername;
  String? feedingtime;
  String? diet;
  String? behavior;
  int? quantity;
  int? population;
  String? conservestatus;
  String? naturalhabitat;

  //Metadata
  String? imageurl;
  String? qrcode;
  DateTime? dateadded;

  Animal({this.name, this.sciname, this.zookeepername,this.feedingtime, this.diet,this.behavior, this.quantity, this.population, this.conservestatus, this.naturalhabitat, this.imageurl, this.qrcode, this.dateadded});
}

class User {
  String? username;
  String? hashedPassword;

  User({this.username, this.hashedPassword});
}

class Log {
  String? type;
  String? account;
  String? action;
  String? name;
  String? dateandtime;

  Log({this.type, this.account, this.action, this.name, this.dateandtime});
}