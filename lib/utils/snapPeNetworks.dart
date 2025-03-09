import 'dart:convert';
import 'dart:io';
import 'package:leads_manager/Controller/leads_controller.dart';
import 'package:leads_manager/models/model_taskpage.dart';
import 'package:leads_manager/views/leads/leadsWidget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domainvariables.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:leads_manager/views/order/ordersDetails.dart';
import 'package:path_provider/path_provider.dart';
import 'package:leads_manager/Controller/chatDetails_controller.dart';
import 'package:leads_manager/Controller/login_controller.dart';
import 'package:leads_manager/helper/networkHelper.dart';
import 'package:leads_manager/helper/socketHelper.dart';

import 'package:leads_manager/models/model_Merchants.dart';
import 'package:leads_manager/models/model_Registration.dart';
import 'package:leads_manager/models/model_catalogue.dart';
import 'package:leads_manager/models/model_leadDetails.dart';
import 'package:leads_manager/models/model_consumer.dart';
import 'package:leads_manager/models/model_order_summary.dart';
import 'package:leads_manager/models/model_item.dart';
import 'package:leads_manager/models/model_orders.dart';
import 'package:leads_manager/utils/snapPeRoutes.dart';
import 'package:leads_manager/utils/snapPeUI.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/constants/networkConstants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import '../models/model_CreateNote.dart';
import '../models/model_FollowUp.dart';
import '../models/model_PriceList.dart';
import '../models/model_Task.dart';
import '../models/model_callstatus.dart';
import '../models/model_lead.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SnapPeNetworks {
  SharedPrefsHelper sharedPrefsHelper = SharedPrefsHelper();
  // final storage = new FlutterSecureStorage();
  LoginController loginController = LoginController();
  //final socketHelper = SocketHelper.getInstance;
  Future requestOTP(String mobile, String appSignature) async {
    Uri url = NetworkConstants.getOTPUrl(mobile);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);

    // http.Response response = await http.post(url,
    //     body: requestBody, headers: {"Content-Type": "application/json"});

    if (response == null) {
      // SnapPeUI().toastError();
      return false;
    }
    print(response.statusCode);
    if (response.statusCode == 200) {
      return true;
    } else {
      Fluttertoast.showToast(msg: "❌ User Doesn't Exist.");
      return false;
    }
  }

  verifyOTP(BuildContext context, String mobileOrEmail, String otp) async {
    Uri url = NetworkConstants.getVerifyOtpURL;
    String reqBody =
        NetworkConstants.requestBodyVerifyOTP(mobileOrEmail, otp, "");

    http.Response? response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response != null && response.statusCode == 200) {
      _saveUserInfo(response, context);
    } else {
      String msg = response != null && response.statusCode == 401
          ? "Incorrect OTP."
          : "🔄 Please Restart ";
      Fluttertoast.showToast(msg: msg);
    }
  }

  Future<dynamic> getSingleLeadJson(
    String id,
  ) async {
    var clientGroupName = SharedPrefsHelper().getClientGroupNameTest() ?? "";
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/leads/$id'),
      requestBody: "",
    );

    if (response != null && response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      print(response.body);
      return response.body;
    } else {
      throw Exception('Failed to get the Lead');
    }
  }

  Future<dynamic> getSingleLead(String id, {bool isalldetails = false}) async {
    var clientGroupName = SharedPrefsHelper().getClientGroupNameTest() ?? "";
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/leads/$id'),
      requestBody: "",
    );

    if (response != null && response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      return isalldetails
          ? LeadDetailsModel.fromJson(jsonDecode(response.body))
          : Lead.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get the Lead');
    }
  }

  Future<void> deleteTask(int id) async {
    var url =
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/SnapPeLeads/task/$id';

    var response = await NetworkHelper().request(
      RequestType.delete,
      Uri.parse(url),
    );

    if (response?.statusCode == 200) {
      print('Task deleted successfully');
    } else {
      print('Failed to delete task');
    }
  }

  Future<void> deleteOpputinity(String id) async {
    var url =
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/SnapPeLeads/opportunity/$id';

    var response = await NetworkHelper().request(
      RequestType.delete,
      Uri.parse(url),
    );

    if (response?.statusCode == 200) {
      print('opputunity deleted successfuly');
    } else {
      print('Failed to delete opportunity');
    }
  }
   Future<void> deleteCustomer(String id) async {
    var url =
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/SnapPeLeads/customers/$id';

    var response = await NetworkHelper().request(
      RequestType.delete,
      Uri.parse(url),
    );

    if (response?.statusCode == 200) {
      print('customers deleted successfuly');
    } else {
      print('Failed to delete customers');
    }
  }
  Future registration(RegistrationModel model) async {
    Uri url = NetworkConstants.registration;
    String reqBody = registrationToJson(model);

    http.Response? response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response == null) {
      return;
    }

    if (response.statusCode == 200) {
      return true;
    } else {
      Fluttertoast.showToast(msg: "Please Refresh");
      return false;
    }
  }

  _saveUserInfo(http.Response response, BuildContext context,
      {email, password}) async {
    //save User Info
    final snapPeUI = SnapPeUI();
    snapPeUI.init(context);
    SharedPrefsHelper().setLoginStatus();
    sharedPrefsHelper.setResponse(response);
    print("response is set now");
    var token = response.headers[NetworkConstants.TOKEN]!;

    SharedPrefsHelper().setToken(token);

    SharedPrefsHelper().setLoginDetails(response.body);

    MerchantsModel merchantsModel = merchantsModelFromJson(response.body);
    List<Merchant>? merchantList = merchantsModel.merchants;
    // SnapPeUI().dialogSelectMerchant();
    if (merchantsModel.merchants!.length == 1) {
      if (await selectedMerchant(context, merchantList![0])) {
        // if(response["merchants"][])
        print(".///response$response");
        Get.offAllNamed(SnapPeRoutes.homeRoute, arguments: response);
      }
    } else {
      snapPeUI.showSelectMerchantDialog(context);
    }
  }

  subcribeTopic(String merchantUserID) async {
    FirebaseMessaging.instance.subscribeToTopic(merchantUserID);
    String? token = await FirebaseMessaging.instance.getToken();
    print("send to server, FCM token  - $token");
    print("subcribeTopic - $merchantUserID");
    if (token != null) {
      await SnapPeNetworks().updateFcmInServer(token);
      //SnapPeUI().toastWarning(message: "updateFcmInServer $result");
    }
  }

  unSubcribeTopic(String merchantUserID) async {
    FirebaseMessaging.instance.unsubscribeFromTopic(merchantUserID);
    String? token = await FirebaseMessaging.instance.getToken();
    print("delete form server, FCM token  - $token");
    print("unSubcribeTopic - $merchantUserID");
    if (token != null) {
      await SnapPeNetworks().deleteFcmInServer(token);
      //SnapPeUI().toastWarning(message: "deleteFcmInServer $result");
    }
  }

  Future<bool> selectedMerchant(BuildContext context, Merchant merchant) async {
    try {

      //  SharedPrefsHelper().setClientGroupName(merchant.clientGroupName);
      // String? clientgrpnametest =
      //     await SharedPrefsHelper().getClientGroupName();
      // SharedPrefsHelper().setClientGroupNameTest(clientgrpnametest);
     String? clientName=merchant.clientName;
      SharedPrefsHelper().setClientGroupName(merchant.clientGroupName);
      String? clientgrpnametest =
          await SharedPrefsHelper().getClientGroupName();
      SharedPrefsHelper().setClientGroupNameTest(clientgrpnametest);
String? username="${merchant.user?.firstName??''} ${merchant.user?.lastName??''}";
      SharedPrefsHelper()
          .setClientPhoneNo(merchant.user?.mobileNumber.toString());
      String? clientPhoneNoTest = await sharedPrefsHelper.getClientPhoneNo();
      SharedPrefsHelper().setClientPhoneNoTest(clientPhoneNoTest);
      SharedPrefsHelper().setClientName(clientName);
      SharedPrefsHelper().setUserName(username);
      
      String? clientNameTest = await sharedPrefsHelper.getClientName();
      SharedPrefsHelper().setClientNameTest(clientNameTest);

      // String sjkdn= sharedPrefsHelper.getClientGroupNameTest();
      //  print("clientGroupName is set  $clientgrpnametest and testclientname is $sjkdn\n\n\\n\\n\\n\n\/n/n//n/n/n//n/n/n//n//n/n/\n\\n\\n\\n\n/n/n/n/n//n/n//n/n");

      // SharedPrefsHelper().setClientPhoneNo(clientName);
      SharedPrefsHelper().setMerchantName(
          "${merchant.user?.firstName} ${merchant.user?.lastName}");

      SharedPrefsHelper().setMerchantUserId("${merchant.userId}");
      SharedPrefsHelper().setCurrentUserId("${merchant.user?.id}");
      await refreshMerchantProfile();
      await refreshAppName();
      await leadSaveProperties();
      await pinnedTemplates();
      print(
          " $clientName,${merchant.user?.firstName},${merchant.userId} in selectedMerchant \n\n\n\\\\n\nn\n\\n\n\nn\n\\n\\n\n\\n\n\\n\n\n\\n\n\n\\n");

      if (true) {
        print('There is an active socket connection.');
        //socketHelper.disconnectPermanantly();
        ChatDetailsController _chatDetailsController =
            ChatDetailsController(context);
        //  await _chatDetailsController.createSocketCon();
      } else {}

      unSubcribeTopic("${merchant.userId}");
      subcribeTopic("${merchant.userId}");
      return true;
    } catch (ex) {
      SnapPeUI().toastError();
      return false;
    }
    // var merchant;
    // try {
    //   var merchantsList = responseData["merchants"];
    //   merchant = merchantsList[0];
    // } catch (ex) {
    //   merchant = responseData;
    // }

    // var clientName = merchant[NetworkConstants.CLIENT_NAME];
    // var phoneNo = merchant[NetworkConstants.PHONE_NO];
    // var role = merchant[NetworkConstants.ROLE];
    // var liveAgentUserId =
    //     merchant[NetworkConstants.LIVE_AGENT_USER_ID].toString();

    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // preferences.setString(NetworkConstants.CLIENT_NAME, clientName);
    // preferences.setString(NetworkConstants.PHONE_NO, phoneNo);
    // preferences.setString(NetworkConstants.ROLE, role);
    // preferences.setString(NetworkConstants.LIVE_AGENT_USER_ID, liveAgentUserId);
  }

  Future<bool> selectedAppName(String appName) async {
    try {
      SharedPrefsHelper().setSelectedChatBot(appName);
      return true;
    } catch (ex) {
      SnapPeUI().toastError();
      return false;
    }
  }

  refreshMerchantProfile() async {
    String? merchantProfileData = await getProfile();
    if (merchantProfileData != null) {
      SharedPrefsHelper().setMerchantProfile(merchantProfileData);
    }
  }

  refreshAppName() async {
    String? appNameData = await getAllAppName();
    if (appNameData != null) {
      SharedPrefsHelper().setAppNames(appNameData);
    }
  }

  leadSaveProperties() async {
    List<dynamic>? properties = await Properties();
    if (properties != null) {
      Map<String, dynamic>? property = properties.lastWhere(
          (property) => property['propertyName'] == "create_lead_on_call",
          orElse: () => null);
      print("$property");
      String? leadPropertyValue = property?['propertyValue'];
      if (leadPropertyValue != null) {
        SharedPrefsHelper().setProperties(leadPropertyValue);
      }

      Map<String, dynamic>? property2 = properties.lastWhere(
          (property) =>
              property['propertyName'] == "numbers_to_be_ignored_after_call",
          orElse: () => null);

      String? leadPropertyValue2 = property2?['propertyValue'];
      print("leadPropertyValue2$leadPropertyValue2");
      print(property2);
      if (leadPropertyValue2 != null) {
        SharedPrefsHelper().setIgnoreNumProperties(leadPropertyValue2);
      }

        Map<String, dynamic>? property3 = properties.lastWhere(
          (property) =>
              property['propertyName'] == "convert_all_calls_to_leads",
          orElse: () => null);

      String? leadPropertyValue3 = property3?['propertyValue'];
      print("leadPropertyValue3$leadPropertyValue3");
      print(property2);
      if (leadPropertyValue2 != null) {
        SharedPrefsHelper().setconvertAllcallsAsLeads ((leadPropertyValue3!=null&&leadPropertyValue3=='yes')?true:false );
      }



    }
  }

  pinnedTemplates() async {
    List<dynamic>? properties = await Properties();
    if (properties != null) {
      Map<String, dynamic>? property = properties.lastWhere(
          (property) => property['propertyName'] == "pinned_templates",
          orElse: () => null);
      print("$property");
      String? pinnedTemplates = property?['propertyValue'];
      if (pinnedTemplates != null) {
        print("$pinnedTemplates");
        SharedPrefsHelper().setPinnedTemplates(pinnedTemplates);
      }
    }
  }

  logOut() async {
    try {
      String merchantUserID = await SharedPrefsHelper().getMerchantUserId();
      unSubcribeTopic(merchantUserID);
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();
      pref.remove('calllogstring');

      // socketHelper.disconnectPermanantly();
      Get.offAllNamed(SnapPeRoutes.loginRoute);
    } catch (ex) {
      print(ex);
    }
  }

  // void storeLastLoggedInUser(String email) async {
  //   // Store the email address of the last logged-in user in shared preferences
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString("lastLoggedInUser", email);
  // }

  // void storeCredentials(String email, String password) async {
  //   // Encrypt and store the email and password using flutter_secure_storage
  //   await storage.write(key: "email_$email", value: email);
  //   await storage.write(key: "password_$email", value: password);
  // }

  // Future<String?> loginWithStoredCredentials() async {
  //   // Retrieve the email address of the last logged-in user from shared preferences
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? email = prefs.getString("lastLoggedInUser");

  //   if (email != null) {
  //     // Retrieve the encrypted email and password from flutter_secure_storage
  //     String? storedEmail = await storage.read(key: "email_$email");
  //     String? password = await storage.read(key: "password_$email");

  //     if (storedEmail != null && password != null) {
  //       // Use the decrypted email and password to send a new login request
  //       // logOut();
  //       String? token = await loginForToken(email, password, loginController);
  //       return token;
  //     }
  //   }
  //   return null;
  // }

  login(BuildContext context, String email, String password,
      LoginController controller) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
//         pref.remove('calllogstring');
// pref.remove('resultlocal');

    Uri url = NetworkConstants.loginURL;
    final snapPeUI = SnapPeUI();
    snapPeUI.init(context);
    var reqBody = NetworkConstants.requestBodyLogin(email, password);
    try {
      http.Response? response = await NetworkHelper()
          .request(RequestType.post, url, requestBody: reqBody);

      if (response != null && response.statusCode == 200) {
        // storeLastLoggedInUser(email);
        // storeCredentials(email, password);

        await _saveUserInfo(response, context,
            email: email, password: password);
      } else {
        String msg = response != null && response.statusCode == 401
            ? "Incorrect Password."
            : "Please Restart";
        Fluttertoast.showToast(msg: msg);
      }
      controller.isLoading.value = false;
    } catch (ex) {
      controller.isLoading.value = false;
      Fluttertoast.showToast(msg: "Please Refresh");
    }
  }

  // Future<String?> loginForToken(
  //     String email, String password, LoginController controller) async {
  //   Uri url = NetworkConstants.loginURL;
  //   var reqBody = NetworkConstants.requestBodyLogin(email, password);
  //   try {
  //     http.Response? response = await NetworkHelper()
  //         .request(RequestType.post, url, requestBody: reqBody);
  //     var token = response?.headers[NetworkConstants.TOKEN]!;
  //     controller.isLoading.value = false;
  //     return token;
  //   } catch (ex) {
  //     controller.isLoading.value = false;
  //     SnapPeUI().toastError(message: "SomeThing went Wrong.");
  //   }
  // }

  Future<List<PricelistMaster>> getPriceList(int customerId) async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    Uri uri = NetworkConstants.getPriceListUrl(customerId, clientGroupName);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, uri);
    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      PriceListModel priceListModel = priceListModelFromJson(response.body);
      if (priceListModel.pricelistMasters != null) {
        return priceListModel.pricelistMasters!;
      }
    }
    return [];
  }

  static Future<List<PricelistMaster>> getAllMasterPricelist() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";

    Uri uri = Uri.parse(
        "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/pricelist-masters");

    http.Response? response =
        await NetworkHelper().request(RequestType.get, uri);

    if (response != null && response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List<PricelistMaster> pricelist = [];
      for (int i = 0; i < jsonResponse["pricelistMasters"].length; i++) {
        pricelist
            .add(PricelistMaster.fromJson(jsonResponse["pricelistMasters"][i]));
      }
      return pricelist;
    } else {
      // If the request was not successful, you might want to handle errors here
      throw Exception('Failed to load master pricelists');
    }
  }

  static Future<List<String>> getItemNameCustomer() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    Uri uri = Uri.parse(
        "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/web/skus?mode=desktop&page=0&size=20");

    http.Response? response =
        await NetworkHelper().request(RequestType.get, uri);
    if (response != null && response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      // Make sure "skuList" is a list
      if (jsonResponse['skuList'] is List) {
        List<String> itemNames = [];

        for (int i = 0; i < jsonResponse['skuList'].length; i++) {
          itemNames.add(jsonResponse['skuList'][i]["displayName"]);
        }

        return itemNames;
      }
    }

    // Return an empty list if there's an issue with the response
    return [];
  }

  Future<String> getItemList(int page, int size,
      {String serachKeyword = ""}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return "";
    }
    Uri url = NetworkConstants.getItems(clientGroupName, page, size,
        serachKeyword: serachKeyword);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<String> getOrderList(int page, int size,
      {int? timeFrom,
      int? timeTo,
      String? searchKeyword,
      String? customerNumber}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return "";
    }
    Uri url = NetworkConstants.getAllOrderList(clientGroupName, page, size,
        searchKeyword: searchKeyword,
        timeFrom: timeFrom,
        timeTo: timeTo,
        customerNumber: customerNumber);
    print("$url");
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<String?> getTransactionList(int page, int size,
      {String? customerNumber}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url = NetworkConstants.getTransactionUrl(clientGroupName, page, size,
        customerNumber: customerNumber);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return null;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String> getOrderDetail(
      int orderId, bool isPendingOrder, bool isquotation) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return "";
    }

    Uri url = isPendingOrder == true
        ? NetworkConstants.getPendingOrderDetails(clientGroupName, orderId)
        : isquotation == true
            ? Uri.parse(
                "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/snappe-orders/$orderId")
            : NetworkConstants.getOrderDetails(clientGroupName, orderId);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<bool> saveItem(Sku item, bool isNewItem) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }
    Uri url = NetworkConstants.updateItem(clientGroupName, item.id.toString());
    print('$url');
    var reqBody = jsonEncode(item);
    print('$reqBody');
    http.Response? response;
    if (isNewItem) {
      response = await NetworkHelper()
          .request(RequestType.post, url, requestBody: reqBody);
    } else {
      response = await NetworkHelper()
          .request(RequestType.put, url, requestBody: reqBody);
    }

    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess(message: "your items edited successfully.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<Lead?> saveLead(
      int? leadId, LeadDetailsModel lead, bool isNewLead) async {
    print('in savelead method');

    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    print('$clientGroupName');
    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url = NetworkConstants.updateLead(clientGroupName, leadId.toString());
    print('$url');
    print("--leadbody");
   
   Map<String, dynamic> jsonMap={};
    //  print('${reqBody["priorityId"]} from my print');
try{
 jsonMap = lead.toJson();
}catch(e){
  print(e);
}
    http.Response? response;
    if (isNewLead) {
      response = await NetworkHelper()
          .request(RequestType.post, url, requestBody:jsonEncode(jsonMap));
    } else {
      response = await NetworkHelper()
          .request(RequestType.put, url, requestBody: jsonEncode(jsonMap));
    }

    if (response == null) {
      SnapPeUI().toastError();
      return null;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      Fluttertoast.showToast(
          msg: "Saving the Lead Details is Succesful",
          textColor: Colors.green,
          gravity: ToastGravity.CENTER);
      ;
      return Lead.fromJson(jsonDecode(response.body));
    } else {
      if (response.statusCode == 400 &&
          jsonDecode(response.body)["messages"][0] == "109") {
        Fluttertoast.showToast(
            msg: "Already Exits",
            textColor: Colors.green,
            gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(
            msg: "Something went wrong please try again Later",
            textColor: Colors.green,
            gravity: ToastGravity.CENTER);
      }
      return null;
    }
  }

  Future<bool> createNewCustomer(ConsumerModel consumer) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }
    Uri url = NetworkConstants.createNewCustomer(clientGroupName);
    var reqBody = json.encode(consumer);
    http.Response? response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }
    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess(message: "Custumer Added successfully.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future? getCategory() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url = NetworkConstants.getCategory(clientGroupName);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return null;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future? getUnit() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url = NetworkConstants.getUnit(clientGroupName);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return null;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<dynamic> uploadImage(int? skuId, File imageFile) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String? token = await SharedPrefsHelper().getToken();

    Uri url = NetworkConstants.uploadImage(clientGroupName!, skuId);

    print('Request uploadImage URL: $url');

    var formData = dio.FormData.fromMap({
      'files': [
        dio.MultipartFile.fromFileSync(imageFile.path, filename: 'files'),
        dio.MultipartFile.fromFileSync(imageFile.path, filename: 'files'),
      ]
    });
    dio.Response<Map> response = await dio.Dio().post(url.toString(),
        data: formData,
        options: dio.Options(headers: {
          "cookie": "token=$token",
          "Content-Type": "multipart/form-data"
        }));

    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      print("uploadImage response :  ${response.data}");

      return response.data;
    } else {
      EasyLoading.dismiss();
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<bool> checkIsExistCustomer(String phoneNo) async {
    Uri url = NetworkConstants.getConsumer(phoneNo);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Sku>> itemsSuggestionsCallback(
      String pattern, String? priceListCode) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    Uri url = NetworkConstants.getItemsSuggestion(
        clientGroupName!, pattern, priceListCode);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return [];
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      ItemModel itemModel = itemFromJson(response.body);
      itemModel.skuList == null ? [] : print(itemModel.skuList!);
      return itemModel.skuList == null ? [] : itemModel.skuList!;
    } else {
      SnapPeUI().toastError();
      return [];
    }
  }

  Future<List<OrderSummaryModel>> customerSuggestionsCallback(
      String pattern) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    Uri url = NetworkConstants.getCustomerSuggestion(clientGroupName!, pattern);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return [];
    }
    try {
      if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
        var data = json.decode(response.body);
        var orderSummaryArray = data["orders"];
        List<OrderSummaryModel> osList = List<OrderSummaryModel>.from(
            orderSummaryArray.map((x) => OrderSummaryModel.fromJson(x)));

        return osList.length == 0 ? [] : osList;
      } else {
        SnapPeUI().toastError();
        return [];
      }
    } catch (ex) {
      print(ex);
      SnapPeUI().toastError();
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCustomerAdressForOrder(String userid) async {
    print("create new order");
    try {
      String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

      if (clientGroupName == null) {
        SnapPeUI().toastError();
        print("errror");
        return null;
      }

      Uri url = Uri.parse(
          "https://${Globals.DomainPointer}/snappe-services/rest/v1/consumers/consumer/$userid/addresses?merchantName=$clientGroupName");

      http.Response? response =
          await NetworkHelper().request(RequestType.get, url);

      if (response == null) {
        SnapPeUI().toastError();
        print("errror");
        return null;
      }

      if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
        var data = jsonDecode(response.body);
        Map<String, dynamic> returningdata = {};
       List<Map<String, dynamic>> list = (data["consumerAddresses"] as List).cast<Map<String, dynamic>>();

         list = list.where((item) => item["community"] != 'anonymous').toList();
        returningdata['address'] = list[0];
        returningdata['billingAddress'] = list[0];
print(list[0]["isBilling"].runtimeType);
        var k = list.firstWhere((item) => item["isBilling"] == true,);
        k != null ? returningdata['billingAddress'] = k : null;
print(k);
        return returningdata;
      } else {
        print("errror");
        SnapPeUI().toastError();
        return null;
      }
    } catch (e) {
      print("$e");
      SnapPeUI().toastError();
      return null;
    }
  }


Future<List<Map<String, dynamic>>> leadSugestionsCallback(String pattern) async {
  String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

  Uri url = Uri.parse(
      "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/search-lead?keyword=$pattern&page=0&size=20");

  http.Response? response = await NetworkHelper().request(RequestType.get, url);

  if (response == null) {
    SnapPeUI().toastError();
    return [];
  }

  try {
    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      var data = json.decode(response.body);
      List leads = data["leads"];

      // Cast leads to List<Map<String, dynamic>>
      List<Map<String, dynamic>> castedLeads =
          leads.map((lead) => lead as Map<String, dynamic>).toList();

      return castedLeads;
    } else {
      SnapPeUI().toastError();
      return [];
    }
  } catch (ex) {
    print(ex);
    SnapPeUI().toastError();
    return [];
  }
}



Future<List<Map<String, dynamic>>> fetchOpportunity({int currentPage = 0}) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response =  currentPage!=0?await NetworkHelper().requestwithouteasyloading (
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/opportunities?page=$currentPage&size=20&sortBy=createdOn&sortOrder=DESC'),
      requestBody: "",
    ):await NetworkHelper().request (
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/opportunities?page=$currentPage&size=20&sortBy=createdOn&sortOrder=DESC'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final List<dynamic> parsed = jsonDecode(response.body)['opportunities'];
      return parsed.map((e) => e as Map<String, dynamic>).toList();
    } else {
      print('Failed to load opportunity with status code: ${response?.statusCode}');
      throw Exception('Failed to load the Opportunity');
    }
  } catch (e) {
    print('Exception occurred: $e');
    return [];
  }
}


Future<List<Map<String, dynamic>>> fetchBacklogLeads({int currentPage = 0}) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response =  currentPage!=0?await NetworkHelper().requestwithouteasyloading (
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-backLog?page=$currentPage&size=20&dueDate=${DateTime.now().toUtc().millisecondsSinceEpoch~/1000}'),
      requestBody: "",
    ):await NetworkHelper().request (
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-backLog?page=$currentPage&size=20&dueDate=${DateTime.now().toUtc().millisecondsSinceEpoch~/1000}'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final List<dynamic> parsed = jsonDecode(response.body)['leads'];
      return parsed.map((e) => e as Map<String, dynamic>).toList();
    } else {
      print('Failed to load opportunity with status code: ${response?.statusCode}');
      throw Exception('Failed to load the backlog leads');
    }
  } catch (e) {
    print('Exception occurred: $e');
    return [];
  }
}
Future<bool> postoppurtunity(Map<String,dynamic> data) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response =  await NetworkHelper().request(
      RequestType.post,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/opportunity'),
      requestBody: jsonEncode(data),
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      return true;
    } else {
      print('Failed to post: ${response?.statusCode}');
      throw Exception('Failed to load the Opportunity post');
    }
  } catch (e) {
    print('Exception occurred: $e');
    return false;
  }
}


Future<List<Map<String, dynamic>>> customColumnForOpp0rtunitiy() async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  try {
    final response =  await NetworkHelper().requestwithouteasyloading (
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/custom-column/opportunity'),
      requestBody: "",
    );
    if (response != null && response.statusCode == 200) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final List<dynamic> parsed = jsonDecode(response.body)['customColumns'];
      return parsed.map((e) => e as Map<String, dynamic>).toList();
    } else {
      print('Failed to load opportunity  custom columnwith status code: ${response?.statusCode}');
      throw Exception('Failed to load the Opportunity customcolumn');
    }
  } catch (e) {
    print('Exception occurred: $e');
    return [];
  }
}

  Future<OrderSummaryModel?> createNewOrder(OrderSummaryModel order) async {
    print("create new order");
    try {
      String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

      if (clientGroupName == null) {
        SnapPeUI().toastError();
        print("errror");
        return null;
      }
      order.merchantName = clientGroupName;
      Uri url = NetworkConstants.createNewOrder(clientGroupName);
      var reqBody = orderSummaryModelToJson(order);
      http.Response? response = await NetworkHelper()
          .request(RequestType.post, url, requestBody: reqBody);

      if (response == null) {
        SnapPeUI().toastError();
        print("errror");
        return null;
      }

      if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
        print("print order submited");
        SnapPeUI().toastSuccess(message: "your order placed successfully.");
        OrderSummaryModel orderModel = orderSummaryModelFromJson(response.body);
        return orderModel;
      } else {
        print("errror");
        SnapPeUI().toastError();
        return null;
      }
    } catch (e) {
      print("$e");
      SnapPeUI().toastError();
      return null;
    }
  }

  getDeliveryTime(String communityName) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    Uri url =
        NetworkConstants.getDeliveryOption(clientGroupName!, communityName);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<String> getCommunity() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    Uri url = NetworkConstants.getCommunity(clientGroupName!);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<String?> getProfile() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    Uri url = NetworkConstants.getProfileUrl(clientGroupName!);

    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return null;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  isExistMobile() {}

  void sendBill(String merchantName, int userId, int orderId,
      double orderAmount, String communityName, String mobile) async {
    EasyLoading.show(indicator: CircularProgressIndicator(), status: "Sending");

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var clientGroupName =
        preferences.getString(NetworkConstants.CLIENT_GROUP_NAME);
    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    String reqBody = NetworkConstants.requestBodySendBill(
      merchantName,
      userId,
      orderId,
      orderAmount,
    );
    Uri url = NetworkConstants.sendBill(clientGroupName, communityName, mobile);

    http.Response? response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response == null) {
      SnapPeUI().toastError();
      return;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess();
    } else {
      SnapPeUI().toastError();
    }
  }

  downloadPdf(int orderId) async {
    EasyLoading.show(status: "Downloading...");

    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String? token = await SharedPrefsHelper().getToken();

    String url = NetworkConstants.downloadInvoice(clientGroupName!, orderId);

    print(url);
    dio.Response? response;
    try {
      // String dirloc = "";
      // if (Platform.isAndroid) {
      //   dirloc = "/sdcard/download/$orderId _invoice.pdf";
      // } else {
      //   dirloc = (await getApplicationDocumentsDirectory()).path;
      // }
      var tempDir = await getTemporaryDirectory();
      String dirloc = tempDir.path + "/$clientGroupName invoice $orderId.pdf";
      print('full path $dirloc');

      response = await dio.Dio().get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: dio.Options(
            headers: {"token": token},
            responseType: dio.ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.statusCode);
      if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
        File file = File(dirloc);
        var raf = file.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();
        print('Share path ${raf.path}');
        //shareplus
        await Share.shareXFiles([XFile(raf.path)],
            text:
                "Greetings,%0A%0ARegarding%20your%20order%20number%20$orderId,%20kindly%20note%0A%0A");

        EasyLoading.dismiss();
      }
    } catch (ex) {
      EasyLoading.dismiss();
      SnapPeUI().toastError();
      print(ex);
    }
  }

  void showDownloadProgress(received, total) {
    EasyLoading.show(status: "Downloading...");
    print("Received - $received , total - $total");
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  void downloadItemsImages(Sku order) async {
    int len = order.images!.length;
    List<ImageC> imagesList = order.images!;
    print("Image size - ${imagesList.length}");
    List<String> path = [];
    String? token = await SharedPrefsHelper().getToken();

    for (int i = 0; i < len; i++) {
      try {
        var tempDir = await getTemporaryDirectory();
        String dirloc = tempDir.path + "/SnapePe$i.jpg";
        print('full path $dirloc');

        dio.Response response = await dio.Dio().get(
          imagesList[i].imageUrl!,
          onReceiveProgress: showDownloadProgress,
          //Received data with List<int>
          options: dio.Options(
              headers: {"token": token},
              responseType: dio.ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status! < 500;
              }),
        );
        print(response.statusCode);
        if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
          File file = File(dirloc);
          var raf = file.openSync(mode: FileMode.write);
          // response.data is List<int> type
          raf.writeFromSync(response.data);
          await raf.close();
          path.add(raf.path);
        }
      } catch (ex) {
        EasyLoading.dismiss();
        SnapPeUI().toastError();
        print(ex);
      }
    }

    print("Path size - ${path.length}");
    //shareplus
    await Share.shareXFiles(path.map((p) => XFile(p)).toList(),
        text:
            "Product Name - ${order.displayName} \n \n Price - ₹${order.sellingPrice} per ${order.measurement} ${order.unit!.name}");

    EasyLoading.dismiss();
  }

  void downloadCatalogue() async {
    EasyLoading.show(status: "Downloading...");

    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String? token = await SharedPrefsHelper().getToken();
    String url = NetworkConstants.downloadCatalogue(clientGroupName!);

    print(url);
    dio.Response? response;
    try {
      var tempDir = await getTemporaryDirectory();
      String dirloc = tempDir.path + "/$clientGroupName Catalogue.pdf";
      print('full path $dirloc');

      dio.Response response = await dio.Dio().get(
        url,
        onReceiveProgress: showDownloadProgress,
        options: dio.Options(
            headers: {"token": token},
            responseType: dio.ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      print(response.statusCode);
      if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
        File file = File(dirloc);
        var raf = file.openSync(mode: FileMode.write);
        // response.data is List<int> type
        raf.writeFromSync(response.data);
        await raf.close();
        print('Share path ${raf.path}');
        //shareplus
        await Share.shareXFiles([XFile(raf.path)], text: '');

        EasyLoading.dismiss();
      }
    } catch (ex) {
      EasyLoading.dismiss();
      SnapPeUI().toastError();
      print(ex);
    }
  }

  Future<String> getPendingOrders(int timeFrom, int timeTo, int page, int size,
      {String? searchKeyword}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return "";
    }
    Uri url = NetworkConstants.getpendingOrder(
        clientGroupName, timeFrom, timeTo, page, size,
        searchKeyword: searchKeyword);
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  Future<String> getQuotations(int timeFrom, int timeTo, int page, int size,
      {String? searchKeyword}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return "";
    }
    Uri url = Uri.parse(
        "https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/snappe-quotations?page=0&size=200&sortBy=createdOn&sortOrder=DESC" +
            (searchKeyword != null ? "&customerName=$searchKeyword" : ""));
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);
    if (response == null) {
      SnapPeUI().toastError();
      return "";
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return "";
    }
  }

  acceptOrder(Order order) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }
    Uri url = NetworkConstants.acceptOrder(clientGroupName, order.id!);
    order.orderStatus = "ACCEPTED";
    var reqBody = jsonEncode(order);

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.put, url, requestBody: reqBody);

    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess(message: "Order Accepted.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  confirmOrder(Order order) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }
    Uri url = NetworkConstants.confirmOrder(clientGroupName, order.id!);
    var reqBody = jsonEncode(order);

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.put, url, requestBody: reqBody);

    if (response == null) {
      SnapPeUI().toastError();
      return false;
    }

    if (response.statusCode == 200 && isTokenValid(response.statusCode)) {
      SnapPeUI().toastSuccess(message: "Order Confirmed.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  updateOrder(String? orderStatus, String? paymentStatus, Order order) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return false;
    }

    Uri url = NetworkConstants.updateOrder(
        orderStatus, paymentStatus, clientGroupName);
    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.put, url, requestBody: ordersToJson([order]));

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "Updated");
      // Get.back();
    } else {
      SnapPeUI().toastError();
    }
  }

  void getQRCode(Order order) async {
    Uri url = NetworkConstants.getQRCodeUrl(
        order.applicationNo!, order.userId!, order.id!);
    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      Get.defaultDialog(
          title: "QR Code", content: Image.memory(response.bodyBytes));
    } else {
      SnapPeUI().toastError();
    }
  }

  Future<String?> getLeads(int page, int size) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getLeadsUrl(clientGroupName, page, size);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getLeadTags() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      // SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getLeadTagsUrl(clientGroupName);

    http.Response? response;
    response =
        await NetworkHelper().requestwithouteasyloading(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getAssignTags(int leadId) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getAssignTagsUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> updateAssignTags(int? leadId, TagsDto tagsModel) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.createTaskUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: tagsDtoToJson(tagsModel));

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "✅ Task Created.");
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getLeadStatus() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getLeadStatusUrl(clientGroupName);

    http.Response? response;
    response =
        await NetworkHelper().requestwithouteasyloading(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getUsers() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getUsersUrl(clientGroupName);

    http.Response? response;
    response =
        await NetworkHelper().requestwithouteasyloading(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getLeadDetails(int? leadId) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getLeadDetailsUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getLeadNotes(int? leadId) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getLeadNotesUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<bool?> editLeadNotes(
    Map<String, dynamic> data,
  ) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    data["htmlData"] = {
      "changingThisBreaksApplicationSecurity": data["remarks"]
    };
    data["documents"] = data["documents"] ;
    data["type"] = null;
    data["taskId"] = null;
    data["opportunityId"] = null;
print("doxs:${ data["documents"]}}");
    String k = "";
    String encodeddata = "";
    try {
      encodeddata = jsonEncode(data);
    } catch (e) {
      k = "$e";
    }

    if (data["id"] == null) {
      return false;
    }

    if (clientGroupName == null) {
      //  note.leadId!
      SnapPeUI().toastError();
      return false;
    }

    Uri url = NetworkConstants.editNoteUrl(clientGroupName, data["id"]);
//note.leadId!,note.id!
    http.Response? response;
    response = await NetworkHelper().request(RequestType.put, url, requestBody: encodeddata);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "Note Edited.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<bool?> deleteLeadNotes(int id, Map<String, dynamic> json) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      //  note.leadId!
      SnapPeUI().toastError();
      return false;
    }

    Uri url = NetworkConstants.deleteNoteUrl(clientGroupName, id);
//note.leadId!,note.id!
    http.Response? response;
    response = await NetworkHelper().request(
      RequestType.delete,
      url,
    );

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Note Deleted.", backgroundColor: Colors.red);
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<bool?> createLeadNotes(int? leadId, CreateNote note) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return false;
    }

    Uri url = NetworkConstants.createNoteUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: createNoteToJson(note));

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "Note Created.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<bool?> createTaskNotes(int? taskId, CreateNote note) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || taskId == null) {
      SnapPeUI().toastError();
      return false;
    }

    Uri url = NetworkConstants.createTaskNoteUrl(clientGroupName, taskId);

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: createNoteToJson(note));
    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "Note Created.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<List<Task>?> getFilteredTasks({
    required int page,
    required int size,
    String? name,
    String? description,
    String? assignedBy,
    String? assignedTo,
    String? status,
    int? modifiedFrom,
    int? modifiedTo,
    int? startTimeFrom,
    int? startTimeTo,
    int? endFrom,
    int? endTo,
    String? customerName,
    String? customerMobileNumber,
  }) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    // Construct the query parameters dynamically
    Map<String, String> queryParams = {
      'page': '$page',
      'size': '$size',
      'sortBy': 'createdOn',
      'sortOrder': 'DESC',
    };

    // Add filters only if they are not null
    if (name != null) queryParams['name'] = name;
    if (description != null) queryParams['description'] = description;
    if (assignedBy != null) queryParams['assignedBy'] = assignedBy;
    if (assignedTo != null) queryParams['assignedTo'] = assignedTo;
    if (status != null) queryParams['status'] = status;
    if (modifiedFrom != null) queryParams['modifiedFrom'] = '$modifiedFrom';
    if (modifiedTo != null) queryParams['modifiedTo'] = '$modifiedTo';
    if (startTimeFrom != null) queryParams['startTimeFrom'] = '$startTimeFrom';
    if (startTimeTo != null) queryParams['startTimeTo'] = '$startTimeTo';
    if (endFrom != null) queryParams['endFrom'] = '$endFrom';
    if (endTo != null) queryParams['endTo'] = '$endTo';
    if (customerName != null) queryParams['customerName'] = customerName;
    if (customerMobileNumber != null)
      queryParams['customerMobileNumber'] = customerMobileNumber;

    // Build the URI with query parameters
    Uri url = Uri.https(
      Globals.DomainPointer,
      '/snappe-services/rest/v1/merchants/$clientGroupName/task-filter',
      queryParams,
    );

    // Make the GET request
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      // Parse the response body
      final data = jsonDecode(response.body);

      // Check if the data contains tasks
      if (data != null && data['tasks'] != null) {
        List<dynamic> tasksJson = data['tasks'];

        // Convert the JSON to a list of Task objects
        List<Task> tasks =
            tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();

        // Return the list of tasks
        return tasks;
      } else {
        SnapPeUI().toastError(message: "No tasks found.");
        return [];
      }
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<List<Task>?> getfollowuptasksforLead(String leadid) async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/SnapPeLeads/tasks?page=0&size=500&leadId=$leadid&type=Followup'),
        requestBody: "",
      );
      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['tasks'] != null) {
          List<dynamic> tasksJson = data['tasks'];

          // Convert the JSON data into a list of Task objects
          List<Task> tasks =
              tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();

          // Return the list of tasks
          return tasks;
        }
      } else {
        print('Failed to load task types ${response?.statusCode}');
        throw Exception('Failed to load task types');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }

  Future<List<TaskType>> fetchTaskTypes() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task-types'),
        requestBody: "",
      );
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        final parsed = jsonDecode(response.body)['taskTypes'];
        return List<TaskType>.from(
            parsed.map((json) => TaskType.fromJson(json)));
      } else {
        print('Failed to load task types ${response?.statusCode}');
        throw Exception('Failed to load task types');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }

  Future<List<TaskStatus>> fetchTaskStatuses() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/task-status'),
        requestBody: "",
      );
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        final parsed = jsonDecode(response.body)['tasks'];
        return List<TaskStatus>.from(
            parsed.map((json) => TaskStatus.fromJson(json)));
      } else {
        print('Failed to load task statuses ${response?.statusCode}');
        throw Exception('Failed to load task statuses');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }

  Future<List<User>> fetchUsers() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/users?isInternal=true&isSkip=true&isPrivilageRequired=false'),
        requestBody: "",
      );
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        final parsed = jsonDecode(response.body)['users'];
        return List<User>.from(parsed.map((json) => User.fromJson(json)));
      } else {
        print('Failed to load users with status code: ${response?.statusCode}');
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }

  Future<List<PriorityId>> fetchPriorities() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    try {
      // Making the GET request using NetworkHelper
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/priorities'),
        requestBody: "",
      );

      // Check if the response is successful
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        // Parsing the response body to get the priorities
        final parsed = jsonDecode(response.body)["allPriorities"];

        // Converting the parsed data to a list of Priority objects
        return List<PriorityId>.from(
            parsed.map((json) => PriorityId.fromJson(json)));
      } else {
        print(
            'Failed to load priorities with status code: ${response?.statusCode}');
        throw Exception('Failed to load priorities');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }

  Future<List<Task>?> getTaskByLead({
    required int leadId,
    int page = 0,
    int size = 500,
  }) async {
    // Retrieve the client group name from shared preferences
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    // Check if the client group name is valid
    if (clientGroupName == null) {
      SnapPeUI().toastError(message: "Client group name not found.");
      return null;
    }

    // Construct the URL with the provided leadId, page, and size
    Uri url = Uri.parse(
      'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/tasks?page=$page&size=$size&leadId=$leadId',
    );

    // Make the GET request
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);

    // Check if the response is valid and the token is still valid
    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      // Parse the response body
      final data = jsonDecode(response.body);

      // Check if the response contains tasks
      if (data != null && data['tasks'] != null) {
        List<dynamic> tasksJson = data['tasks'];

        // Convert the JSON data into a list of Task objects
        List<Task> tasks =
            tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();

        // Return the list of tasks
        return tasks;
      } else {
        SnapPeUI().toastError(message: "No tasks found for leadId: $leadId.");
        return [];
      }
    } else {
      // Handle errors by showing a toast message
      SnapPeUI().toastError(message: "Failed to retrieve tasks.");
      return null;
    }
  }

  Future<List<Task>?> getFollowTaskByLead({
    required int leadId,
    int page = 0,
    int size = 500,
  }) async {
    // Retrieve the client group name from shared preferences
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    // Check if the client group name is valid
    if (clientGroupName == null) {
      SnapPeUI().toastError(message: "Client group name not found.");
      return null;
    }

    // Construct the URL with the provided leadId, page, and size
    Uri url = Uri.parse(
      'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/tasks?page=$page&size=$size&leadId=$leadId',
    );

    // Make the GET request
    http.Response? response =
        await NetworkHelper().request(RequestType.get, url);

    // Check if the response is valid and the token is still valid
    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      // Parse the response body
      final data = jsonDecode(response.body);

      // Check if the response contains tasks
      if (data != null && data['tasks'] != null) {
        List<dynamic> tasksJson = data['tasks'];

        // Convert the JSON data into a list of Task objects
        List<Task> tasks =
            tasksJson.map((taskJson) => Task.fromJson(taskJson)).toList();

        // Return the list of tasks
        return tasks;
      } else {
        SnapPeUI().toastError(message: "No tasks found for leadId: $leadId.");
        return [];
      }
    } else {
      // Handle errors by showing a toast message
      SnapPeUI().toastError(message: "Failed to retrieve tasks.");
      return null;
    }
  }

  Future<String?> createTask(int? leadId, Task taskModel,) async {
    //Taskmodel

    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.createTaskUrl(clientGroupName, leadId);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.post, url,
        requestBody: jsonEncode(taskModel.toJson()));

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      print("1");
      SnapPeUI().toastForTask(message: "✅ Task Created.");
      return response.body;
    } else {
      print("2");
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<bool?> addFollowUp(int? leadId, FollowUpModel followUpModel) async {
    print("infollw up model");
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null || leadId == null) {
      SnapPeUI().toastError();
      return false;
    }
    print("body" + followUpModelToJson(followUpModel).toString());
    Uri url = NetworkConstants.createFollowUpUrl(clientGroupName, leadId);
var k=followUpModelToJson(followUpModel);
    http.Response? response;
    response = await NetworkHelper().request(RequestType.post, url,
        requestBody: followUpModelToJson(followUpModel));

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      SnapPeUI().toastSuccess(message: "FollowUp Added.");
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  filterLeads(int page, int size,
      {dynamic nameOrMobile,
      List? assignedTo,
      List? tags,
      List? leadStatus,
      List? assignedBy,
      List<String>? selectedSources,
      List<String>? selectedDatess,
      String? selectedPeriod,
  
      String? lastmodifedfrom,
      String? lastmodifiedto,
      bool isfrompageincrement = false,String? sortfilter}) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }
    print("__t${tags}");
    Uri url = NetworkConstants.filterLeadsUrl(
      clientGroupName,
      page,
      size,
      nameOrMobile: nameOrMobile,
      assignedTo: assignedTo,
      assignedBy: assignedBy,
      tags: tags,
      selectedSources: selectedSources,
      selectedDates: selectedDatess,
      leadStatus: leadStatus,
      selectedPeriod: selectedPeriod,
      lastmodifedfrom: lastmodifedfrom,
      lastmodifiedto: lastmodifiedto,
      sortfilter:sortfilter
    );

    http.Response? response;
    response = isfrompageincrement
        ? await NetworkHelper().requestwithouteasyloading(RequestType.get, url)
        : await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  getCustomers() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getCustomersUrl(clientGroupName);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  getCustomerDetails(int? customerId) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null && customerId == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url =
        NetworkConstants.getCustomerDetailsUrl(clientGroupName!, customerId!);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  searchCustomer(searchValue) async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.searchCustomerUrl(clientGroupName, searchValue);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  static Future<List<CallStatus>> getcallStatus() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    try {
      final response = await NetworkHelper().requestwithouteasyloading(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead/call-status'),
        requestBody: "",
      );
      if (response != null && response.statusCode == 200) {
        // print('Response Status: ${response.statusCode}');
        // print('Response Body: ${response.body}');
        final parsed = json.decode(response.body);
        final List<dynamic> statusList = parsed['callStatus'];
        final List<CallStatus> status =
            statusList.map((json) => CallStatus.fromJson(json)).toList();
        return status;
      } else {
        print('Failed to load call status');
        //fix it later
        throw Exception('Failed to load call status');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw e;
    }
  }

  getAllAppName() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url = NetworkConstants.getAllAppNameURl(clientGroupName);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Properties() async {
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String liveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
    if (clientGroupName == null) {
      SnapPeUI().toastError();
      return null;
    }

    Uri url =
        NetworkConstants.getPropertiesURl(clientGroupName, liveAgentUserId);
    print("url is $url");
    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      // Parse the response body as a JSON object
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      // Extract the properties array from the response body
      List<dynamic> properties = responseBody['userProperties'];
      return properties;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  Future<String?> getAllChatData(
      {int page = 0, int? previousTime, int? currentTime,String keyword1=''}) async {
    EasyLoading.init();
    print("2.5-");
    Uri url;

    print(
        "getAllChatData current Time - $currentTime previous Time - $previousTime ,$keyword1");

    //String selectedChatBot = SnapBasketApplication.sharedPreferences.getString(AppConstant.SELECTED_CHATBOT, null);
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String divigoid = await SharedPrefsHelper().getChatSessionId() ?? "";
    String? userselectedApplicationName =
      await  SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);

    if (clientGroupName == null || appName == null) {
      SnapPeUI().toastError();
      return null;
    }
    if (userselectedApplicationName == null) {
      print("2.6");
      url = NetworkConstants.getAllChatDataUrl(clientGroupName, appName,
          previousTime.toString(), currentTime.toString(), divigoid,
          page: page,keyword:  keyword1);
    } else {
      url = NetworkConstants.getAllChatDataUrl(
          clientGroupName,
          userselectedApplicationName,
          previousTime.toString(),
          currentTime.toString(),
          divigoid,
          page: page,
          keyword: keyword1
          );
    }
    print("chat url $url");
    http.Response? response;
    print("2.7-");
    response = await NetworkHelper().requestwithouteasyloading(RequestType.get, url);
    print("2.8-");
    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      SnapPeUI().toastError();
      EasyLoading.dismiss();
      return null;
    }
  }

  Future<void> changeProperty(List<Map<String, dynamic>> properties) async {
    String userId = await SharedPrefsHelper().getMerchantUserId();
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    final response = await NetworkHelper().requestwithouteasyloading(
        RequestType.put,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/user/$userId/properties'),
        requestBody: jsonEncode(properties));

    if (response != null && response.statusCode == 200) {
      print("change prop${response.body}");
      return jsonDecode(response.body);
    } else {
      print(response?.statusCode);
      print(response?.body);
      throw Exception('Failed to Edit properties');
    }
  }

  Future<List<String>> fetchLeadSourcess() async {
    String clientGroupName =
        await SharedPrefsHelper().getClientGroupName() ?? "";
    try {
      final response = await NetworkHelper().request(
        RequestType.get,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/lead-source'),
        requestBody: "",
      );
      if (response != null && response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        final parsed = jsonDecode(response.body)['allLeadsSources'];
        return List<String>.from(parsed.map((json) => json['sourceName']));
      } else {
        print('Failed to load lead sources ${response?.statusCode}');
        throw Exception('Failed to load lead sources');
      }
    } catch (e) {
      print('Exception occurred: $e');
      return [];
    }
  }

  getSingleChatData(dynamic customerPhone, bool isFromLeadsScreen) async {
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int previousTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // currentTime - 2592000; //  1 Week Before //2629743; // 1 months
    //previousTime = 1619277183;//test
    print(
        "getSingleChatData current Time - $currentTime previous Time - $previousTime");
    String? defaultAppName;
    if (isFromLeadsScreen == true) {
      defaultAppName = await getAppName(customerPhone);
    }
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    String? userselectedApplicationName =
    await    SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);
    if (clientGroupName == null || appName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url;
    if (defaultAppName != null) {
      url = NetworkConstants.getSingleChatData(customerPhone, clientGroupName,
          defaultAppName, previousTime.toString(), currentTime.toString());
      print("$defaultAppName");
    } else if (userselectedApplicationName != null &&
        userselectedApplicationName != "") {
      url = NetworkConstants.getSingleChatData(
          customerPhone,
          clientGroupName,
          userselectedApplicationName!,
          previousTime.toString(),
          currentTime.toString());
      print("$userselectedApplicationName");
    } else {
      url = NetworkConstants.getSingleChatData(customerPhone, clientGroupName,
          appName, previousTime.toString(), currentTime.toString());
      print(url.toString());
    }
    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      print("print response from d1+${response.body}");
      return response.body;
    } else {
      SnapPeUI().toastError();
      return null;
    }
  }

  checkOverrideStatus(dynamic customerPhone) async {
    String? appName = await SharedPrefsHelper().getSelectedChatBot();
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();

    String? userselectedApplicationName =
      await  SharedPrefsHelper().getUserSelectedChatbot(clientGroupName);
    if (clientGroupName == null || appName == null) {
      SnapPeUI().toastError();
      return null;
    }
    Uri url;
    if (userselectedApplicationName == null) {
      url = NetworkConstants.overrideStatusUrl(
          appName, customerPhone, clientGroupName,
          isCheckOverrideStatus: true);
    } else {
      url = NetworkConstants.overrideStatusUrl(
          userselectedApplicationName, customerPhone, clientGroupName,
          isCheckOverrideStatus: true);
    }
    http.Response? response;
    response = await NetworkHelper().request(RequestType.get, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return response.body;
    } else {
      //SnapPeUI().toastError();
      return null;
    }
  }

  Future<bool> takeOverOrReleaseRequest(
      dynamic customerPhone, bool? isFromLeadsScreen,
      {bool isReleaseReq = false}) async {
    try {
      print("releasotake over request");
      String? appName = await SharedPrefsHelper().getSelectedChatBot();
      String? clientGroup = await SharedPrefsHelper().getClientGroupName();
      String? liveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
      String? liveAgentUserName = await SharedPrefsHelper().getMerchantName();
      String? defaultAppName;
      String? userselectedApplicationName =
          SharedPrefsHelper().getUserSelectedChatbot(clientGroup);
      String? liveAgentSessionId = await SharedPrefsHelper().getChatSessionId();

      if (clientGroup == null ||
          appName == null ||
          liveAgentUserId == null ||
          liveAgentUserName == null ||
          liveAgentSessionId == null) {
        print(
            "$clientGroup ,$appName,$liveAgentUserId,$liveAgentUserName,$liveAgentSessionId");
        //  SnapPeUI().toastError();
        return false;
      }
      print("1");
      String reqBody = NetworkConstants.requestBodyTakeOver(
          liveAgentUserId,
          liveAgentUserName,
          NetworkConstants.AGENT_CHANNEL_VALUE,
          liveAgentSessionId,
          clientGroup);
      Uri url;
      if (isFromLeadsScreen == true) {
        print("2");
        defaultAppName = await getAppName(customerPhone);
        if (defaultAppName != null) {
          url = NetworkConstants.overrideStatusUrl(
            defaultAppName,
            customerPhone,
            clientGroup,
          );
        } else {
          print("3");
          url = NetworkConstants.overrideStatusUrl(
            appName,
            customerPhone,
            clientGroup,
          );
        }
      } else {
        if (userselectedApplicationName != null &&
            userselectedApplicationName != "") {
          print("4");
          url = NetworkConstants.overrideStatusUrl(
            userselectedApplicationName,
            customerPhone,
            clientGroup,
          );
        } else {
          print("5");
          url = NetworkConstants.overrideStatusUrl(
            appName,
            customerPhone,
            clientGroup,
          );
        }
      }
      print("release url$url");
      print("postingrelease");
      RequestType reqType = RequestType.post;
      if (isReleaseReq) {
        reqType = RequestType.delete;
      }

      http.Response? response;
      response = await NetworkHelper()
          .request(reqType, url, requestBody: reqBody, isLiveAgentReq: true);

      if (response != null &&
          response.statusCode == 200 &&
          isTokenValid(response.statusCode)) {
        var obj = json.decode(response.body);
        String status = obj["status"];
        if (status == "user_inactive") {
          print("6");
          SnapPeUI().toastError(
              message:
                  "User session is inactive, we have sent a request to the user for starting a live agent request. \n \n You will be notified, once the user confirms.");
          return false;
        } else if (status == "success") {
          print("eoor from over riding");
          return true;
        }
        // SnapPeUI().toastError();
        print("eoor from over riding");
        return false;
      } else {
        // SnapPeUI().toastError();
        print("eoor from over riding");
        return false;
      }
    } catch (e) {
      print("eror");
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<bool> updateFcmInServer(String newFCMtoken) async {
    print("in updatefcm server");
    String? oldFMCToken = await SharedPrefsHelper().getFCMToken();
    // if (oldFMCToken == newFCMtoken) {
    //   return true;
    // }
    String? liveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
    String? clientGroupName = await SharedPrefsHelper().getClientGroupName();
    String? imeiid=await SharedPrefsHelper().getmobileImeiNumberId();
    if (clientGroupName == null || liveAgentUserId == null) {
      SnapPeUI().toastError();
      return false;
    }

    var reqBody = NetworkConstants.requestBodyFCM(
        liveAgentUserId, newFCMtoken, clientGroupName,imeiid??'');

    Uri url = NetworkConstants.getUpdateFCMUrl();

    http.Response? response;
    response = await NetworkHelper()
        .request(RequestType.post, url, requestBody: reqBody);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      try {
        print("in 200");
        print("it is ${response.body}");

        await SharedPrefsHelper().setFCMToken(newFCMtoken);
        return true;
      } catch (e) {
        print("fcm$e");
      }
      return true;
    } else {
      print("in false");
      SnapPeUI().toastError();
      return false;
    }
  }

  Future<bool> deleteFcmInServer(String token) async {
    Uri url = NetworkConstants.getDeleteFCMUrl(token);

    http.Response? response;
    response = await NetworkHelper().request(RequestType.delete, url);

    if (response != null &&
        isTokenValid(response.statusCode) &&
        response.statusCode == 200) {
      return true;
    } else {
      SnapPeUI().toastError();
      return false;
    }
  }

  bool isTokenValid(int? statusCode) {
    if (statusCode == 401) {
      logOut();
      SnapPeUI().toastError(message: "❌ Your Credentials Expired.");
      return false;
    }
    return true;
  }

Future<int> getMajorVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version; // e.g., "1.2.3"

  List<String> versionParts = version.split('.');
  return int.parse(versionParts[0]); // Major version
}
  Future<bool> postAllPermissions(Map<String, bool> permissions) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
int version=await getMajorVersion();
  // Convert the permissions map into the required format
  Map<String, dynamic> requestBody = {
    "version_code":version,
    "appPermissionsDetailsDTO": permissions.entries.map((entry) {
      return {
        "name": entry.key, // Permission name
        "isEnabled": entry.value, // true if granted, false otherwise
      };
    }).toList()
  };

  try {
    final response = await NetworkHelper().requestwithouteasyloading(
      RequestType.post,
      Uri.parse('https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/app/permissions'),
      requestBody: jsonEncode(requestBody),
    );

    if (response != null && response.statusCode == 200) {
      print('Permissions posted successfully: ${response.body}');
      return true;
    } else {
      print('Failed to post permissions: ${response?.statusCode}');
      throw Exception('Failed to post permissions');
    }
  } catch (e) {
    print('Exception occurred: $e');
    return false;
  }
}
}

Future<List<dynamic>> getTemplates(String? selectedApplicationName) async {
await  SharedPrefsHelper().init();
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  final response = await NetworkHelper().requestwithouteasyloading (
    RequestType.get,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/gupshup/$selectedApplicationName/templates?merchant=$clientGroupName'),
    requestBody: "",
  );
  if (response != null && response.statusCode == 200) {
    var data = jsonDecode(response.body);
    List<dynamic> templates = data['templates'];
    return templates;
  } else {
    throw Exception('Failed to load templates');
  }
}

// Future<Map<String, dynamic>?> defaultData() async {
//   try {
//     String clientGroupName =
//         await SharedPrefsHelper().getClientGroupName() ?? "";
//     final response = await NetworkHelper().request(
//       RequestType.get,
//       Uri.parse(
//           "https://prod-cb-ne.snap.pe/chatbot/rest/v1/merchants/$clientGroupName/business_application/commerce"),
//       requestBody: "",
//     );

//     if (response != null && response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load data');
//     }
//   } catch (e) {
//     // Handle the error here
//     print(e);
//     return null;
//   }
// }
Future<String?> getAppName(mobile) async {
  var clientGroupName = SharedPrefsHelper().getClientGroupNameTest() ?? "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/conversations/Customer/app/$mobile'),
    requestBody: "",
  );

  if (response != null && response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse['app_name'];
  } else {
    throw Exception('Failed to load app name');
  }
}

Future<void> callConvertCustomer(String id) async {
  var clientGroupName = SharedPrefsHelper().getClientGroupNameTest() ?? "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/leads/$id?isForConvert=true'),
    requestBody: "",
  );

  if (response != null && response.statusCode == 200) {
    print("cnoversion succesfull");
  } else {
    // Fluttertoast.showToast(msg: "S");
  }
}

Future<bool> updateQuotation(Map<String, dynamic> json, String id) async {
  var clientGroupName = SharedPrefsHelper().getClientGroupNameTest() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.put,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/snappe-orders/$id?&validateAvailability=false'),
      requestBody: jsonEncode(json),
    );

    if (response != null && response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Succesfully edited the Data");
      return true;
    } else {
      Fluttertoast.showToast(msg: "Edit Failed");
      return false;
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "$e");
    return false;
  }
}

Future<dynamic> checkQuotation(Map<String, dynamic> json) async {
  var clientGroupName = SharedPrefsHelper().getClientGroupNameTest() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.post,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/order/calculate-amount?mode=dashboard'),
      requestBody: jsonEncode(json),
    );

    if (response != null && response.statusCode == 200) {
      var k = jsonDecode(response.body);
      if (k["status"] == "OK") {
        //Fluttertoast.showToast(msg: "Validation Succesfull");
        prints(k);
        return k;
//return true;
      }
      return false;
      ;
    } else {
      Fluttertoast.showToast(msg: "Edit Failed");
      //return false;
    }
  } catch (e) {
    Fluttertoast.showToast(msg: "$e");
    //  return false;
  }
}

Future<bool> postCallLogNotification2(String calltype, int id) async {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  String currentLiveAgentUserId =
      await prefs.getString(NetworkConstants.MERCHANT_USER_ID) ?? "null";

  String? clientGroup =
      await prefs.getString(NetworkConstants.CLIENT_GROUP_NAME);
  try {
    Map<String, dynamic> body = {
      "lead_id": id,
      "logged_in_user_id": currentLiveAgentUserId,
      "type": calltype
    };
    final response = await NetworkHelper().requestwithouteasyloading(
      RequestType.post,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services-pt/chatbot/rest/v1/merchant/$clientGroup/call_notification'),
      requestBody: jsonEncode(body),
    );

    if (response != null && response.statusCode == 200) {
      print(response.statusCode);
      // Fluttertoast.showToast(msg: "Succesfully edited the Data");
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("Sending call notificartion failed reson$e");
    return false;
  }
}

Future<bool> triggerBot(int id) async {
  String currentLiveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
  var clientGroupName = SharedPrefsHelper().getClientGroupNameTest() ?? "";
  try {
    var k = await SnapPeNetworks().getSingleLeadJson(id.toString());
    final response = await NetworkHelper().request(
        RequestType.post,
        Uri.parse(
            'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/trigger'),
        requestBody: k,
        dissmissonTap: false);

    if (response != null && response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Attempt to trigger  bot was Successfull");
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("Trigger bot failed$e");
    return false;
  }
}

Future<String?> getPincode() async {
  String currentLiveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
  var clientGroupName = SharedPrefsHelper().getClientGroupNameTest() ?? "";
  try {
    final response = await NetworkHelper().request(
      RequestType.get,
      Uri.parse(
          'https://${Globals.DomainPointer}/snappe-services/rest/v1/merchants/$clientGroupName/properties?userId=$currentLiveAgentUserId'),
    );

    if (response != null && response.statusCode == 200) {
      var k = jsonDecode(response.body);
      List<dynamic> properties = k["properties"];
      for (int i = 0; i < properties.length; i++) {
        if (properties[i]["propertyName"] == "default_pincode") {
          print(properties[i]["propertyValue"]);
          return properties[i]["propertyValue"];
        }
      }
    } else {
      return null;
    }
  } catch (e) {
    print("getting pinceode falied $e");
    return null;
  }
}

Future<dynamic> getOverrideStatus(String? number, bool isfromLeadscreen) async {
  print(await SharedPrefsHelper().getFristappName());

  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  print(await SharedPrefsHelper().getUserSelectedChatbot(clientGroupName));
  String selectedApplication = isfromLeadscreen
      ? await getAppName(number) ??
          validateString(await SharedPrefsHelper()
              .getUserSelectedChatbot(clientGroupName)) ??
          await SharedPrefsHelper().getFristappName() ??
          ""
      : validateString(await SharedPrefsHelper()
              .getUserSelectedChatbot(clientGroupName)) ??
          await SharedPrefsHelper().getFristappName() ??
          "";
  final response = await NetworkHelper().request(
    RequestType.get,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/chatbot/liveagent/$selectedApplication/$number?merchantName=$clientGroupName'),
    requestBody: "",
  );
  if (response != null && response.statusCode == 200) {
    var data = jsonDecode(response.body);
    dynamic k = data["override"]["agent_override"];
    if (k == 0 || k == null) {
      return false;
    } else {
      return true;
    }
  } else {
    throw Exception('Failed to get agent override');
  }
}

Future<dynamic> deleteOverrideStatus(
    String? number, bool isfromLeadscreen) async {
  String clientGroupName =
      await SharedPrefsHelper().getClientGroupName() ?? "SnapPeLeads";
  String selectedApplication = isfromLeadscreen
      ? await getAppName(number) ??
          validateString(await SharedPrefsHelper()
              .getUserSelectedChatbot(clientGroupName)) ??
          await SharedPrefsHelper().getFristappName() ??
          ""
      : validateString(await SharedPrefsHelper()
              .getUserSelectedChatbot(clientGroupName)) ??
          await SharedPrefsHelper().getFristappName() ??
          "";
  String liveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
  final response = await NetworkHelper().request(
    RequestType.delete,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/chatbot/liveagent/$selectedApplication/$number?merchantName=$clientGroupName&userId=$liveAgentUserId'),
    requestBody: "",
  );
  if (response != null && response.statusCode == 200) {
    print("delete successs");
  } else {
    throw Exception('Failed to delete agent override');
  }
}

Future<dynamic> postOverrideStatus(
    String? number, bool isfromLeadscreen) async {
  String clientGroupName = await SharedPrefsHelper().getClientGroupName() ?? "";
  String selectedApplication = isfromLeadscreen
      ? await getAppName(number) ??
          validateString(await SharedPrefsHelper()
              .getUserSelectedChatbot(clientGroupName)) ??
          await SharedPrefsHelper().getFristappName() ??
          ""
      : validateString(await SharedPrefsHelper()
              .getUserSelectedChatbot(clientGroupName)) ??
          await SharedPrefsHelper().getFristappName() ??
          "";
  String liveAgentUserId = await SharedPrefsHelper().getMerchantUserId();
  final response = await NetworkHelper().request(
    RequestType.post,
    Uri.parse(
        'https://${Globals.DomainPointer}/snappe-services/rest/v1/chatbot/liveagent/$selectedApplication/$number?merchantName=$clientGroupName'),
    requestBody: jsonEncode({
      "live_agent_user_id": liveAgentUserId,
      "client_group": clientGroupName
    }),
  );
  if (response != null && response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return true;
  } else {
    throw Exception('Failed to post agent override');
  }
}


