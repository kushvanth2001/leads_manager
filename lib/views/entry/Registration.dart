import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:leads_manager/constants/colorsConstants.dart';
import 'package:leads_manager/models/model_Registration.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';
import 'package:leads_manager/utils/snapPeRoutes.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import '../../constants/styleConstants.dart';

class Registration extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    RegistrationModel registration = new RegistrationModel();
    SnapPeUI snapPeUI = SnapPeUI();
    bool isValidEmail(String email) {
      String pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (email.isEmpty)
        return false;
      else if (!regex.hasMatch(email))
        return false;
      else
        return true;
    }

    void _btnRegistration() async {
      if (!_formKey.currentState!.validate()) {
        SnapPeUI().toastSuccess(message: "Error");
        return;
      }

      _formKey.currentState?.save();
      registration.mode = "B2C";
      print(registration.firstName);

      bool result = await SnapPeNetworks().registration(registration);

      if (result) {
        SnapPeUI().toastSuccess(
            message: "Wait for Approved. You will informed by email.");
        Navigator.pushNamedAndRemoveUntil(
            context, SnapPeRoutes.loginWithPwdRoute, (route) => false);
      } else {
        SnapPeUI().toastError();
      }
    }

    return Scaffold(
      appBar: SnapPeUI().appBarBig(),
      body: Container(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 50.0),
          child: Column(
            children: [
              Text(
                "Please enter your Details",
                style: TextStyle(
                    fontSize: kBigFontSize, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    //Row(children:[]),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      maxLength: 50,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "First Name is required.";
                        }
                        return null;
                      },
                      onSaved: (newValue) => registration.firstName = newValue,
                      decoration: InputDecoration(
                          hintText: "Enter First Name",
                          labelText: "First Name",
                          border: OutlineInputBorder()),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      maxLength: 50,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Last Name is required.";
                        }
                        return null;
                      },
                      onSaved: (newValue) => registration.lastName = newValue,
                      decoration: InputDecoration(
                          hintText: "Enter Last Name",
                          labelText: "Last Name",
                          border: OutlineInputBorder()),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 50,
                      validator: (value) {
                        if (value!.isEmpty || !isValidEmail(value)) {
                          return "Please Enter Vaild Email.";
                        }
                        return null;
                      },
                      onSaved: (newValue) => registration.email = newValue,
                      decoration: InputDecoration(
                          hintText: "Enter Email",
                          labelText: "Email",
                          border: OutlineInputBorder()),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      maxLength: 100,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Organization Name is required.";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        registration.clientName = newValue;
                        registration.displayName = newValue;
                      },
                      decoration: InputDecoration(
                          hintText: "Enter Organization Name",
                          labelText: "Organization Name",
                          border: OutlineInputBorder()),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (value) {
                        if (value!.isEmpty || value.length != 10) {
                          return "Please Enter Vaild Mobile.";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        if (newValue != null) {
                          registration.mobileNumber = "+91" + newValue;
                          registration.countryCode = "+91";
                        }
                      },
                      decoration: InputDecoration(
                          hintText: "Enter Mobile Number",
                          labelText: "Mobile Number",
                          border: OutlineInputBorder()),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        if (value!.isEmpty || value.length != 6) {
                          return "Please Enter Vaild Pincode.";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        if (newValue != null) {
                          registration.pincode = int.parse(newValue);
                        }
                      },
                      decoration: InputDecoration(
                          hintText: "Enter Pincode",
                          labelText: "Pincode",
                          border: OutlineInputBorder()),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      maxLength: 100,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "City is required.";
                        }
                        return null;
                      },
                      onSaved: (newValue) => registration.city = newValue,
                      decoration: InputDecoration(
                          hintText: "Enter City",
                          labelText: "City",
                          border: OutlineInputBorder()),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      maxLength: 100,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Address is required.";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        registration.addressLine1 = newValue;
                        registration.addressType = "Home";
                      },
                      decoration: InputDecoration(
                          hintText: "Enter Address",
                          labelText: "Address",
                          border: OutlineInputBorder()),
                    ),
                    TextFormField(
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password is required.";
                        }
                        return null;
                      },
                      onSaved: (newValue) => registration.password = newValue,
                      decoration: InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          border: OutlineInputBorder()),
                    ),
                    // ListTile(
                    //   title: const Text('Direct to Customer'),
                    //   leading: Radio(
                    //     value: "Direct to Customer",
                    //     groupValue: registration.mode,
                    //     onChanged: (value) {
                    //       registration.mode = "B2C";
                    //     },
                    //   ),
                    // ),
                    // ListTile(
                    //   title: const Text('Through Sales Channel'),
                    //   leading: Radio(
                    //     value: "Through Sales Channel",
                    //     groupValue: registration.mode,
                    //     onChanged: (value) {
                    //       registration.mode = "B2B";
                    //     },
                    //   ),
                    // ),
                    // ListTile(
                    //   title: const Text('Both'),
                    //   leading: Radio(
                    //     value: "Both",
                    //     groupValue: registration.mode,
                    //     onChanged: (value) {
                    //       registration.mode = "Both";
                    //     },
                    //   ),
                    // ),
                    // TextFormField(
                    //   obscureText: true,
                    //   keyboardType: TextInputType.visiblePassword,
                    //   validator: (value) {
                    //     if (value!.isEmpty) {
                    //       return "Confirm Password is required.";
                    //     }
                    //   },
                    //   onSaved: (newValue) => registration.password = newValue,
                    //   decoration: InputDecoration(
                    //       hintText: "Enter Confirm Password",
                    //       labelText: "Confirm Password",
                    //      border: OutlineInputBorder()),
                    // ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: buttonCOlor,
                    fixedSize: MaterialStateProperty.all(Size(250, 40))),
                onPressed: () {
                  _btnRegistration();
                },
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    color: buttonTextColor,
                    fontSize: kMediumFontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
              snapPeUI.privacyPolicy(context)
            ],
          ),
        ),
      ),
    );
  }
}
