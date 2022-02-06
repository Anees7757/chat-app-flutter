class UserModel {
  late String name, email, id;
  // late String? profileImage;

  UserModel(
      {required this.name,
      required this.email,
      required this.id,
      // this.profileImage
      });

  UserModel.fromMap(Map<String, dynamic> userData) {
    name = userData["name"];
    email = userData["email"];
    id = userData["id"];
   // profileImage = userData["profileImage"];
  }

  void updateWith(Map<String, dynamic> userData) {
    name = userData["name"] ?? name;
   // profileImage = userData["profileImage"] ?? profileImage;
  }
 }
