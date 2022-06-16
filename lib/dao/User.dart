class User {
  String email, firstName, lastName, name;

  User(this.email, this.firstName, this.lastName, this.name);

  User.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    name = '$firstName $lastName';
  }
}
