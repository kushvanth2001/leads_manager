class UserDetails {
  final userID;
  final userName;
  final clientGroupName;
  final clientName;
  final phoneNo;
  final role;

  static final cUserID = "userid";
  static final cUserName = "username";
  static final cClientGroupName = "ClientGroupName";
  static final cClientName = "ClientName";
  static final cPhoneNo = "PhoneNo";
  static final cRole = "Role";

  UserDetails(
      {this.userID,
      this.userName,
      this.clientGroupName,
      this.clientName,
      this.phoneNo,
      this.role});

  factory UserDetails.fromMap(Map<String, dynamic> json) => new UserDetails(
      userID: json[cUserID],
      userName: json[cUserID],
      clientGroupName: json[cUserID],
      clientName: json[cUserID],
      phoneNo: json[cUserID],
      role: json[cUserID]);
  Map<String, dynamic> toMap() {
    return {
      cUserID: userID,
      cUserName: userName,
      cClientGroupName: clientGroupName,
      cClientName: clientName,
      cPhoneNo: phoneNo,
      cRole: role
    };
  }
}
