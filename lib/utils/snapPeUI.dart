import 'dart:convert';
import 'dart:ui';


import 'package:bubble/bubble.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leads_manager/helper/mqttHelper.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/views/CallLogScreen.dart';
import 'package:leads_manager/views/dashboard/notneeded.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../Controller/leads_controller.dart';
import '../constants/colorsConstants.dart';
import '../helper/SharedPrefsHelper.dart';
import '../models/model_Merchants.dart';
import 'package:get/get.dart';
import '../widgets/errowidget.dart';
import 'snapPeNetworks.dart';
import 'snapPeRoutes.dart';
import '../views/customers/customersScreen.dart';
import '../views/dashboard/dashboard.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../views/leads/callLogsScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Controller/profile_controller.dart';
import '../constants/styleConstants.dart';
import 'package:package_info_plus/package_info_plus.dart';


class SnapPeUI {
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
 // static const platform = const MethodChannel('com.example.myapp/callLog');
  final FToast fToast = FToast();
  void init(BuildContext context) {
    fToast.init(context);
  }

  void sendSwitchValue(bool switchValue) {
    //platform.invokeMethod('setSwitchValue', {'switchValue': switchValue});
  }

  static const styleSomebody = BubbleStyle(
    nip: BubbleNip.leftTop,
    color: Colors.white,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(top: 8, right: 50),
    alignment: Alignment.topLeft,
  );

  static const styleMe = BubbleStyle(
    nip: BubbleNip.rightTop,
    color: Color.fromARGB(255, 225, 255, 199),
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(top: 8, left: 50),
    alignment: Alignment.topRight,
  );

  AppBar appBarBig() {
    return AppBar(
      toolbarHeight: 200,
      title: appLogoLarge(),
      elevation: 15,
      centerTitle: true,
    );
  }

  AppBar appBarSmall(Widget? actionWidget) {
    return AppBar(
      elevation: 0,
      title: appLogoSmall(),
      actions: [actionWidget!=null?actionWidget:Container()],
    );
  }

  AppBar customAppBar(String title) {
    return AppBar(
      elevation: 0,
      title: appLogoSmall(logoRequired: false, title: title),
    );
  }

  showSelectMerchantDialog(BuildContext context) async {
    //  print("this is in ShowselectedMerchant ${response.body} \n\\n\\n\n//n/n//nn/n//n/n/n//n//n\n\\n\n\\n//n/n/n//n//n\nn//n/n/n//n//n\nn\n\n\n");

    // String? clientGroup = await SharedPrefsHelper().getClientGroupName();
    MerchantsModel merchantsModel =
        merchantsModelFromJson(await SharedPrefsHelper().getLoginDetails());
    final ScrollController _scrollController = ScrollController();
    if (merchantsModel.merchants!.length == 1) {
      toastWarning(message: "There is no other Business.");
      return;
    }
    return Get.defaultDialog(
      barrierDismissible: false,
      
      onCancel: () async{
        Fluttertoast.showToast(msg: "No Application Selected",gravity: ToastGravity.CENTER,textColor: Colors.blue);
                await SnapPeNetworks().logOut();
                     await sharedPrefsHelper.clearPrefs();
                     
                        await DefaultCacheManager().emptyCache();

      // Clear app data
      final appDir = await getApplicationSupportDirectory();
      if (appDir.existsSync()) {
        appDir.deleteSync(recursive: true);
      }
      },
        content: Container(
          height: 300.0, // Change as per your requirement
          width: 300.0, // Change as per your requirement
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: merchantsModel.merchants!.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title:
                      Text(merchantsModel.merchants![index].clientGroupName!),
                  onTap: () async {
                    
                  Map<String,dynamic>   data=jsonDecode(  await SharedPrefsHelper().getLoginDetails());
                    List<dynamic> merchant=data["merchants"]  ;

              Map<String, dynamic> selectedmerchant = merchant.where((e) =>
     e["clientGroupName"] == merchantsModel.merchants![index]!.clientGroupName).toList()[0] as Map<String,dynamic>;


              List<dynamic> featureslist=  selectedmerchant["user"]["role"]["features"].map((e)=> e["name"].toString().toLowerCase()).toList();

try{
              addPrivileges(selectedmerchant['user']);}
              catch(e){
var m=e;
                print(e);
              }
              try{
           selectedmerchant["user"][ "pincode"]!=null?sharedPrefsHelper.setDefaultPincode(selectedmerchant["user"][ "pincode"].toString()):null;
              }catch(e){
                print("efrom 32pincode $e");
              }
              print(".///feature list is$featureslist");
             // featureslist.remove("mobile");
              if(featureslist.contains("mobile")){
                    EasyLoading.show();
                    // sharedPrefsHelper.setUserSelectedChatBot(clientGroup,null);
                    // sharedPrefsHelper.removeSelectedApplication();

                    selectedMerchant(context, merchantsModel.merchants![index]);}
                    else{
                     await SnapPeNetworks().logOut();
                     await sharedPrefsHelper.clearPrefs();
                     
                        await DefaultCacheManager().emptyCache();

      // Clear app data
      final appDir = await getApplicationSupportDirectory();
      if (appDir.existsSync()) {
        appDir.deleteSync(recursive: true);
      }
                      showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                
                  content: Text('Sorry, the mobile app feature is not included in your current plan privileges. Please contact us to inquire about adding it to your plan.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
                    }




try{
  LeadController leadController=Get.find<LeadController>();
 leadController.leadModel.value = LeadModel();
                  leadController.currentPage = 0;
                  print("key ${leadController.selectedFeatureKey.value}");
                  
              
                  leadController.getFilteredLeads();
                  leadController.refreshController();
}
catch(e){
  print("geeting this while refshing the lead controller lgging in $e");
}

                  },
                );
              },
            ),
          ),
        ),
        title: "Please Select Merchant");
  }
void addPrivileges(Map<String, dynamic> user) { 
  if (user["role"] == null || user["role"]["features"] == null) { 
    print("Role or features not found in user data."); return; } 
    for (var feature in user["role"]["features"]) { 
      print(feature['name']); if (feature['name'] == "LeadManagement") {
         print(feature); if (feature['privilages'] == null) {
           print("Privileges not found for LeadManagement."); return; }
            for (var privi in feature['privilages']) { print(privi); 
            if (privi['name'] == "delete") { 
              
              print('delete found'); SharedPrefsHelper().setcanDeleteLeadPrivillage(privi['checked']??true); } } }}} 
  void selectedMerchant(BuildContext context, Merchant merchant) async {
    //  print("this is in selectedMerchant ${response.body} \n\\n\\n\n//n/n//nn/n//n/n/n//n//n\n\\n\n\\n//n/n/n//n//n\nn//n/n/n//n//n\nn\n\n\n");
    final snapPeUI = SnapPeUI();
    snapPeUI.init(context);
    if (await SnapPeNetworks().selectedMerchant(context, merchant)) {
      snapPeUI.toastSuccess(message: "Selected ${merchant.clientGroupName}");
      await SharedPrefsHelper().removeCatalogue();
      await SharedPrefsHelper().removeOrders();
      await SharedPrefsHelper().removeLeads();
      await SharedPrefsHelper().removeCustomers();

      Get.offAllNamed(SnapPeRoutes.homeRoute);
    }
  }

  appLogoSmall({bool logoRequired = true, String title = "Lead Manager"}) {
    return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          logoRequired == false
              ? SizedBox.shrink()
              : Positioned(
                  left: -19,
                  child: Container(
                    height: 90,
                    width: 90,
                    // color: Colors.black,
                    child: Transform.scale(
                      scale: 0.5,
                      child: Stack(
                        children: [
                          Opacity(
                              child: Image.asset("assets/icon/logo.png",
                                  color: Colors.white),
                              opacity: 0.1),
                          ClipRect(
                              child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 5.0, sigmaY: 5.0),
                                  child: Image.asset("assets/icon/logo.png",
                                      fit: BoxFit.cover))),
                        ],
                      ),
                    ),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.only(left: 50, top: 5),
            child: appBarText(title, 19),
          ),
        ]);
  }

  appLogoLarge() {
    return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Container(
              child: Stack(
                children: [
                  Opacity(
                      child: Image.asset("assets/icon/logo.png",
                          color: Colors.white),
                      opacity: 0.1),
                  ClipRect(
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Image.asset("assets/icon/logo.png",
                              fit: BoxFit.cover))),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -38,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                appBarText("Lead Manager", 23),
                SizedBox(
                  height: 4,
                ),
                // appBarSubText("~ Chutki Mein ~", kMediumFontSize),
              ],
            ),
          ),
        ]);
  }

  appLogoDrawer() {
    ProfileController _controller = ProfileController();

    return Stack(alignment: Alignment.centerLeft, children: [
      Positioned(
        // left: -10,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            children: [
              Opacity(
                  child:
                      Image.asset("assets/icon/logo.png", color: Colors.white),
                  opacity: 0.1),
              ClipRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Image.asset("assets/icon/logo.png",
                          fit: BoxFit.cover))),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 60),
        child: appBarText(
            _controller.merchantProfile.value.merchantName, kBigFontSize),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 75, top: 60),
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            if (snapshot.hasData) {
              return ListTile(
                title: Text(
                   'V ${snapshot.data!.version}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontStyle: FontStyle.italic),
                ),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    ]);
  }

  // actions: [
  //   PopupMenuButton(
  //     itemBuilder: (context) {
  //       return [
  //         PopupMenuItem(child: Text("Profile")),
  //         PopupMenuItem(child: Text("Logout"))
  //       ];
  //     },
  //   ),
  // ],

  AppBar nAppBar(String mtitle) {
    return AppBar(
      title: appBarText(mtitle, kBigFontSize),
      centerTitle: true,
    );
  }

  AppBar nAppBar2(
    bool isNewLead,
    String mtitle,
    int? leadId,
    LeadController leadController,
    BuildContext context,
  ) {
    return AppBar(

      title: appBarText(mtitle, kBigFontSize),
      centerTitle: true,
      actions: [
        if (!isNewLead)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CallLogsScreen(
                              leadId: leadId,
                              leadController: leadController,
                              onBack: () {})));
                },
                icon: Image.asset(
                  'assets/icon/telephone2.png',
                )),
          )
      ],
    );
  }

  AppBar nAppBar3(String mtitle, Function() onpressed) {
    return AppBar(
      title: appBarText(mtitle, kBigFontSize),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: onpressed,
        ),
      ],
    );
  }

  ShaderMask appBarText(String? mtitle, double fsize) {
    return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Color.fromARGB(255, 199, 255, 201),
                Color.fromARGB(255, 255, 247, 178),
                Color.fromARGB(255, 255, 230, 228),
                Color.fromARGB(255, 181, 222, 255)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
        child: Text(
          mtitle ?? "",
          style: TextStyle(
            color: Colors.white,
            fontSize: fsize,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.josefinSans().fontFamily,
          ),
        ));
  }

  Text appBarSubText(String mtitle, double fsize) {
    return Text(
      mtitle,
      style: TextStyle(
          fontSize: fsize,
          fontWeight: FontWeight.normal,
          color: kPrimaryTextColor),
    );
  }

  headingSubheadingText(String heading, String subHeading) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            heading,
            style: TextStyle(
                fontSize: kBigFontSize,
                fontWeight: FontWeight.bold,
                color: kSecondayTextcolor),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            subHeading,
            style: TextStyle(
                fontSize: kMediumFontSize,
                fontWeight: FontWeight.w300,
                color: kSecondayTextcolor),
          ),
        ]);
  }

  customButtomNavigation() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.category),
        label: "Catalogue",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.outbox_rounded),
        label: "Orders",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.leaderboard),
        label: "Leads",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat),
        label: "Chat",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people),
        label: "Customer",
      ),
     // @marketing
      //    BottomNavigationBarItem(
      //   icon: Icon(Icons.add),
      //   label: "Marketing",
      // ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_box),
        label: "Profile",
      ),
    ];
  }

  // Stack _buildBody() {
  //   return Stack(
  //     children: [
  //       Container(
  //         width: double.infinity,
  //         height: 200,
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.topCenter,
  //             end: Alignment.bottomCenter,
  //             colors: [Color(0xFFFFA000), Color(0xFFFFB300), Color(0xFFFFA000)],
  //           ),
  //           borderRadius: BorderRadius.only(
  //             bottomLeft: Radius.circular(30),
  //             bottomRight: Radius.circular(30),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  toastError({String message = " 🔄 Please Refresh."}) async {
    var showtost=await SharedPrefsHelper().gettostaccisbility();
    if(showtost){
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      message = "📡 Check Internet Connection.";
    }

    EasyLoading.dismiss();
(await  SharedPrefsHelper(). getLoginStatus())?
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromARGB(255, 250, 255, 178),
        textColor: Colors.red,
        fontSize: kMediumFontSize):null;
  }
  }
  toastForTask({String message = "✅ Done."}) {
    EasyLoading.dismiss();
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromARGB(255, 250, 255, 178),
        textColor: Colors.green,
        fontSize: kMediumFontSize);
  }

  toastSuccess({String message = "Done"}) {
    try {
      fToast.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Color.fromARGB(255, 250, 255, 178),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 12.0),
              Text(
                message,
                style:
                    TextStyle(color: Colors.green, fontSize: kMediumFontSize),
              ),
            ],
          ),
        ),
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 1),
      );
    } catch (e) {
      print('Failed to show toast: $e');
    }
  }

  void removeAllQueuedToasts() {
    fToast.removeQueuedCustomToasts();
  }

  toastWarning({String message = " ⚠️ "}) {
    EasyLoading.dismiss();
    
    Fluttertoast.showToast(
        msg: " ⚠️ " + message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Color.fromARGB(255, 250, 255, 178),
        textColor: kPrimaryColor,
        fontSize: kMediumFontSize);
  }

  searchBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: kPrimaryColor,
          blurRadius: 100.0,
          spreadRadius: 140,
        ),
      ],
    );
  }

  searchBoxDecorationForChat() {
    return BoxDecoration(
        border: Border.all(color: kPrimaryColor),
        borderRadius: BorderRadius.circular(10),
        color: Color.fromARGB(255, 237, 237, 237)

//  ,boxShadow: [
//         BoxShadow(
//           color: kPrimaryColor,
//           blurRadius: 100.0,
//           spreadRadius: 140,
//         ),
//       ],

        );
  }

  noDataFoundImage({String msg = "Uh-oh! This Page is empty"}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset("assets/images/noData.svg"),
          Center(
            child: SvgPicture.asset(
              'assets/images/noData.svg',
              semanticsLabel: 'No Data',
              height: 250,
            ),
          ),
          // Text(
          //   msg,
          //   style: TextStyle(
          //       fontSize: kMediumFontSize,
          //       color: kLightTextColor,
          //       fontWeight: FontWeight.w400,
          //       fontStyle: FontStyle.italic),
          // )
        ],
      ),
    );
  }

  noDataFoundImage2({String msg = "Uh-oh! This Page is empty"}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/noData.svg',
          semanticsLabel: 'No Data',
          height: 250,
        ),
        // Image.asset("assets/images/noCatalogue.png"),
        Text(
          msg,
          style: TextStyle(
              fontSize: kMediumFontSize,
              color: kLightTextColor,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic),
        )
      ],
    );
  }

  loading() {
    return LinearProgressIndicator(
      backgroundColor: Colors.white54,
    );
  }

  drawerText(String title) {
    return Text(title,
        style: TextStyle(fontSize: kMediumFontSize, color: kLightTextColor));
  }

  void dialogbox(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:
                Text('Privacy Policy', style: TextStyle(color: Colors.black)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.'),
                  Text(
                      '\nWe use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.'),
                  RichText(
                    text: TextSpan(
                      text: '\nImage Information ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 58, 58, 58),
                          fontSize: 18),
                    ),
                  ),
                  Text(
                      '\nSpecific images are captured and uploaded to the platform for actions related to payment QR code scanning, transaction images related to the app, etc. These images are stored and managed in a secure manner on the cloud server. User have full rights to ask for deletion of images captured at any time by writing to us at support@snap.pe with the following details :'),
                  Text('Email address'),
                  Text('First name and last name'),
                  Text('Phone number'),
                  Text('Address, State, Province, ZIP/Postal code, City'),
                  RichText(
                    text: TextSpan(
                      text: '\nUsage Data',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 58, 58, 58),
                          fontSize: 18),
                    ),
                  ),
                  Text(
                      "\nUsage Data is collected automatically when using the Service. Usage Data may include information such as Your Device’s Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, the time spent on those pages, unique device identifiers and other diagnostic data. When You access the Service by or through a mobile device, We may collect certain information automatically, including, but not limited to, the type of mobile device You use, Your mobile device unique ID, the IP address of Your mobile device, Your mobile operating system, the type of mobile Internet browser You use, unique device identifiers and other diagnostic data. We may also collect information that Your browser sends whenever You visit our Service or when You access the Service by or through a mobile device."),
                  RichText(
                    text: TextSpan(
                      text: '\nCall Log Data',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 58, 58, 58),
                          fontSize: 18),
                    ),
                  ),
                  Text(
                      '\nOur app provides Customer Relationship Management (CRM) services to help merchants manage their leads. As part of this service, we may access the call log data on the user’s device to show the merchant the call logs associated with a lead’s phone number. We only access call log data for phone numbers that are associated with leads in the merchant’s CRM. We do not have access to other phone numbers in the user’s call log. We use a foreground service to retrieve the call duration, call time, and call status for calls made to or from a lead’s phone number. This information is then displayed to the merchant on the lead’s call logs page. We take the privacy and security of our users’ data seriously and have implemented measures to protect this data. Users can control or limit our access to their call log data by changing their device’s permission settings.'),
                  InkWell(
                    child: new Text(
                        '\nPlease visit our Privacy Policy website https://sites.google.com/view/privacy-policy-leads-manager/home',
                        style: TextStyle(color: Colors.blue)),
                    onTap: () => launch(
                        'https://sites.google.com/view/privacy-policy-leads-manager/home'),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  privacyPolicy(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: "By creating an account, you are agreeing to our",
          style: TextStyle(color: Color.fromARGB(255, 88, 88, 88)),
          children: [
            TextSpan(
              text: " Privacy Policy ",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  dialogbox(context);
                },
            ),
          ],
        ),
      ),
    );
  }

//   customDrawer(BuildContext context, saveLeadFromCalls) {
//     SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
//     SnapPeNetworks snapPeNetworks = SnapPeNetworks();
//     List<Map<String, dynamic>> properties = [];
//     bool _switchValue = false;
//     if (saveLeadFromCalls == "Yes") {
//       _switchValue = true;
//       sendSwitchValue(true);
//     }
//     return Drawer(
//         child: ListView(
//       children: [
       
//         DrawerHeader(
//             child: appLogoDrawer(),
//             decoration: BoxDecoration(color: kPrimaryColor.withOpacity(1))),
//         ListTile(
//           leading: Icon(Icons.donut_large),
//           title: Text("Dashboard"),
//           onTap: () {
//             Get.back();
//           Get.to(() => DashBoardScreen());
//            // Get.to(() => Dashboard());
//           },
//         ),
//         StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return ListTile(
//               leading: Icon(Icons.donut_large),
//               title: Row(
//                 children: [
//                   Text("Save Lead from Calls"),
//                   Spacer(),
//                   Switch(
//                     value: _switchValue,
//                     onChanged: (bool value) {
//                       print("$saveLeadFromCalls from switch");
//                       setState(() {
//                         _switchValue = value;

//                         properties = [
//                           {
//                             "status": "OK",
//                             "messages": [],
//                             "propertyName": "create_lead_on_call",
//                             "propertyType": "client_user_attributes",
//                             "name": "Create Leads From Call",
//                             "id": 9804159,
//                             "propertyValue":
//                                 _switchValue == true ? "Yes" : "No",
//                             "propertyAllowedValues": "yes,no",
//                             "propertyDefaultValues": "no",
//                             "isEditable": true,
//                             "remarks": "Notification Sound ",
//                             "category": "Lead",
//                             "isVisibleToClient": true,
//                             "interfaceType": "drop_down",
//                             "pricelistCode": null
//                           }
//                         ];
//                       });
//                       sendSwitchValue(value);
//                       snapPeNetworks.changeProperty(properties);
//                     },
//                   ),
//                 ],
//               ),
//               onTap: () {},
//             );
//           },
//         ),
//         // ListTile(
//         //   leading: Icon(Icons.donut_large),
//         //   title: Row(
//         //     children: [
//         //       Text("Save Lead from Calls"),
//         //       Spacer(),
//         //       Switch(
//         //         value: false,
//         //         onChanged: (bool value) {},
//         //       ),
//         //     ],
//         //   ),
//         //   onTap: () {},
//         // ),
//         ListTile(
//           leading: Icon(Icons.call),
//           title: Text("Call Logs"),
//           onTap: ()async{
// Get.to(CallLogScreen());
//           },
//         ),
//         ListTile(
//           leading: Icon(Icons.donut_large),
//           title: Text("Switch Business"),
//           onTap: () {
//             Get.back();
//             showSelectMerchantDialog(context);
//           },
//         ),
//         ListTile(
//           leading: Icon(Icons.donut_large),
//           title: Text("Privacy Policy"),
//           onTap: () {
//             Navigator.of(context).pop();
//             dialogbox(context);
//           },
//         ),
//         ListTile(
//           leading: Icon(Icons.donut_large),
//           title: Text("Logout"),
//           onTap: () {
//             // FirebaseCrashlytics.instance.crash();
//             sharedPrefsHelper.removeResponse();

//             SnapPeNetworks().logOut();
//           },
//         ),   ListTile(
//           leading: Icon(Icons.donut_large),
//           title: Text("Logout"),
//           onTap: () {
//             // FirebaseCrashlytics.instance.crash();
//             sharedPrefsHelper.removeResponse();

//             SnapPeNetworks().logOut();
//           },
//         ),

  

//       ],
//     ));
//   }

  headingText(String title) {
    return Text(title,
        style: TextStyle(
          fontSize: kMediumFontSize,
          color: kBlackColor,
          overflow: TextOverflow.ellipsis,
        ));
  }

  subHeadingText(String title) {
    return Text(title,
        style: TextStyle(
          fontSize: kSmallFontSize,
          color: kLightTextColor,
          overflow: TextOverflow.ellipsis,
        ));
  }
List<PersistentBottomNavBarItem> customButtomNavigation2(clientGroupFeatures, clientGroupName) {
  List<PersistentBottomNavBarItem> items = [];
  

 
  if (clientGroupFeatures[clientGroupName]?.contains('LeadManagement') ?? false) {
    items.add(PersistentBottomNavBarItem(
      inactiveIcon:Icon(Icons.leaderboard_outlined) ,
      icon:   Icon(
    Icons.leaderboard,
    fill: 1,
    size: 30.0,
    color: Colors.blue,
  
  ),
      title: 'Leads',
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.grey,
      
    ));
  }

  if (clientGroupFeatures[clientGroupName]?.contains('CustomerConversations') ?? false) {
    items.add(PersistentBottomNavBarItem(
      icon:   Icon(
    Icons.chat_bubble,
    fill: 1,
    size: 30.0,
    color: Colors.blue,
   
  ),
      inactiveIcon: Icon(Icons.chat_bubble_outline,),
      title: 'Chat',
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.grey,
    ));
  }

  if (clientGroupFeatures[clientGroupName]?.contains('Customers') ?? false) {
    items.add(PersistentBottomNavBarItem(
       icon:   Icon(
    Icons.people,
    fill: 1,
    size: 30.0,
    color: Colors.blue,
  
  ),
     inactiveIcon: Icon(Icons.people_outline),
      title: 'Customers',
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.grey,
    ));
  }

  if (clientGroupFeatures[clientGroupName]?.contains('Orders') ?? false) {
    items.add(PersistentBottomNavBarItem(
       icon:   Icon(
    Icons.outbox,
    fill: 1,
    size: 30.0,
    color: Colors.blue,
   
  ),
     inactiveIcon: Icon(Icons.outbox_outlined),
      title: 'Orders',
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.grey,
    ));
  }

  if (clientGroupFeatures[clientGroupName]?.contains('SKUs') ?? false) {
    items.add(PersistentBottomNavBarItem(
       icon:   Icon(
    Icons.category,
    fill: 1,
    size: 30.0,
    color: Colors.blue,
   
  ),
      inactiveIcon: Icon(Icons.category_outlined),
      title: 'Catalogue',
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.grey,
    ));
  }
 if (clientGroupFeatures[clientGroupName]?.contains('Dashboard') ?? false) {
    items.add(PersistentBottomNavBarItem(
      inactiveIcon:Icon(Icons.show_chart) ,
      icon:   Icon(
    Icons.show_chart,
    fill: 1,
    size: 30.0,
    color: Colors.blue,
  
  ),
      title: 'Dashboard',
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.grey,
      
    ));
  }


  return items;
}


   // @marketing
//       items.add(
//       BottomNavigationBarItem(
//         icon: Transform.rotate(
//   angle: 25 * -3.141592653589793 / 180, // Convert degrees to radians
//   child: Icon(Icons.send),
// ),
//         label: "Marketing",
//       ),
    
//    );
    // items.add(
    //   BottomNavigationBarItem(
    //     icon: Icon(Icons.local_offer_outlined), // choose an appropriate icon
    //     label: "Promotions",
    //   ),
    // );
  //    if (clientGroupFeatures[clientGroupName]?.contains('Profile') ?? false) {
  //   items.add(CurvedNavigationBarItem(
  //     child:  Icon(Icons.person_2_outlined),
  //     label: 'Profile',
  //   ));
  // }


  

//   customButtomNavigation2(clientGroupFeatures, clientGroupName) {
//     List<BottomNavigationBarItem> items = [];
//     print(
//         "from customButtomNavigation2 features are ${clientGroupFeatures["TallyDevelopment"]}");
//     if (clientGroupFeatures[clientGroupName]
//             ?.contains('CustomerRolesManagement') ??
//         false) {
          
//       items.add(BottomNavigationBarItem(
//           icon: Icon(Icons.leaderboard_outlined), label: 'Leads'));
//     }

//     if (clientGroupFeatures[clientGroupName]?.contains('Communications') ??
//         false) {
//       items.add(
//         BottomNavigationBarItem(
//           icon: Icon(Icons.chat_bubble_outline),
//           label: "Chat",
//         ),
//       );
//     }

//     if (clientGroupFeatures[clientGroupName]?.contains('Customers') ?? false) {
//       items.add(
//         BottomNavigationBarItem(
//           icon: Icon(Icons.people_outline),
//           label: "Customers",
//         ),
//       );
//     }
//     if (clientGroupFeatures[clientGroupName]?.contains('SKUs') ?? false) {
//       items.add(
//         BottomNavigationBarItem(
//           icon: Icon(Icons.category_outlined),
//           label: "Catalogue",
//         ),
//       );
//     }
//     if (clientGroupFeatures[clientGroupName]?.contains('Orders') ?? false) {
//       items.add(
//         BottomNavigationBarItem(
//           icon: Icon(Icons.outbox),
//           label: "Orders",
//         ),
//       );
//     }
//    // @marketing
// //       items.add(
// //       BottomNavigationBarItem(
// //         icon: Transform.rotate(
// //   angle: 25 * -3.141592653589793 / 180, // Convert degrees to radians
// //   child: Icon(Icons.send),
// // ),
// //         label: "Marketing",
// //       ),
    
// //    );
//     // items.add(
//     //   BottomNavigationBarItem(
//     //     icon: Icon(Icons.local_offer_outlined), // choose an appropriate icon
//     //     label: "Promotions",
//     //   ),
//     // );
//     // if (clientGroupFeatures[clientGroupName].contains('Profile')) {
//     items.add(
//       BottomNavigationBarItem(
//         icon: Icon(Icons.person_2_outlined),
//         label: "Profile",
//       ),
//     );
//     // }

//     print("$items thee are items");
//     return items;
//   }
}
