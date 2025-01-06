import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:leads_manager/views/order/createquotation.dart';
import '../../constants/colorsConstants.dart';
import '../../models/model_community.dart';
import '../../models/model_consumer.dart';
import '../../models/model_order_summary.dart';
import '../../models/model_orders.dart';
import '../../utils/snapPeNetworks.dart';
import 'addquotation.dart';
import 'orderWidget.dart';
import '../../utils/snapPeUI.dart';
import '../../helper/SharedPrefsHelper.dart';

import 'cart/screen_cart.dart';

class OrderScreen extends StatefulWidget {
  final int tabIndex;
  final bool? isfromlead;
  OrderScreen({Key? key, this.tabIndex = 0,this.isfromlead=false}) : super(key: key);

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {

  bool isRequiredCompanyName = false;
  bool isNewCustomer = false;
  List<Community> communities = [];
  List<Order>? orders;
  String? _selectedCommunity;
  String? orderJson;
  String? pendingOrderJson;
  String? quotationJson;
  String? communityJson;
  late TabController _tabController;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.tabIndex); // Initialize TabController with number of tabs
    _tabController.addListener(_handleTabSelection);

    loadData(tabindex: 0);
    if(widget.tabIndex!=0){
    setState(() {
      tabIndex = widget.tabIndex;
      _tabController.index=widget.tabIndex;
   loadData(forcedReload: true, tabindex: _tabController.index);
  
    });
 
    print("Selected tab index: ${_tabController.index}");}
  }

  _handleTabSelection() {
    setState(() {
      tabIndex = _tabController.index;
    });
    loadData(forcedReload: true, tabindex: _tabController.index);
    print("Selected tab index: ${_tabController.index}");
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.resumed) {
  //     // Refresh your page here
  //     loadData(forcedReload: true, tabindex: tabIndex);
  //     setState(() {});
  //   }
  // }

  selectCustomerDialog(bool fromquotation) {
    final searchController = TextEditingController();

    return showCupertinoModalPopup(
      barrierColor: kPrimaryColor.withOpacity(0.3),
      barrierDismissible: true,
      filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          title: Text("Select Customer",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  TypeAheadField(
                    noItemsFoundBuilder: (context) {
                      return Text("No Customer Found.");
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                        controller: searchController,
                        decoration:
                            InputDecoration(labelText: "Search customer")),
                    suggestionsCallback: (pattern) async {
                      return await SnapPeNetworks()
                          .customerSuggestionsCallback(pattern);
                    },
                    itemBuilder: (context, OrderSummaryModel customer) {
                      return ListTile(
                        title: Text("${customer.customerName}"),
                        subtitle: Text("${customer.customerNumber}"),
                      );
                    },
                    onSuggestionSelected: (OrderSummaryModel customer) {
                      print(customer.customerNumber);
                      //var json = customerModelToJson(customer);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => fromquotation
                                ? QuotationCartScreeen(order: customer,onBack: ()async{

                                     await   loadData(forcedReload: true, tabindex: tabIndex);
                                },)
                                : CartScreen(order: customer),
                          ));
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "- - or - -",
                    style: TextStyle(color: kLightTextColor),
                  ),
                  MaterialButton(
                    child: Text("Create new Customer",
                        style: TextStyle(color: kLinkTextColor)),
                    onPressed: () async {
                      Navigator.pop(context);
                      isNewCustomer = false;
                      newCustomerDialog(fromquotation);
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  newCustomerDialog(bool fromquotation) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final mobileController = TextEditingController();
    final companyController = TextEditingController();
    final pincodeController = TextEditingController();
    final fullAddressController = TextEditingController();
    _selectedCommunity = null;

    return showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("New Customer"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Visibility(
                      visible: !isNewCustomer,
                      child: TextFormField(
                        controller: mobileController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                            hintText: "Enter Customer Mobile",
                            labelText: "Customer Mobile"),
                      ),
                    ),
                    Visibility(
                        visible: isNewCustomer,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: firstNameController,
                              keyboardType: TextInputType.name,
                              maxLength: 50,
                              decoration: InputDecoration(
                                  hintText: "Enter First Name",
                                  labelText: "First Name"),
                            ),
                            TextFormField(
                              controller: lastNameController,
                              keyboardType: TextInputType.name,
                              maxLength: 50,
                              decoration: InputDecoration(
                                  hintText: "Enter Last Name",
                                  labelText: "Last Name"),
                            ),
                            Visibility(
                              visible: isRequiredCompanyName,
                              child: TextFormField(
                                controller: companyController,
                                keyboardType: TextInputType.name,
                                maxLength: 100,
                                decoration: InputDecoration(
                                    hintText: "Enter Company Name",
                                    labelText: "Company"),
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedCommunity,
                              iconSize: 25,
                              elevation: 16,
                              hint: Text(
                                "Please choose a Community",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCommunity = newValue!;
                                });
                              },
                              items: communities.map<DropdownMenuItem<String>>(
                                  (Community value) {
                                return DropdownMenuItem<String>(
                                  value: value.communityName ?? "",
                                  child: Text("${value.communityName!}"),
                                );
                              }).toList(),
                            ),
                            TextFormField(
                              controller: pincodeController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: InputDecoration(
                                  hintText: "Enter pincode",
                                  labelText:
                                      "Pincode"), //errorText: 'value can\'t be empty'
                            ),
                            TextFormField(
                              controller: fullAddressController,
                              keyboardType: TextInputType.name,
                              maxLength: 100,
                              decoration: InputDecoration(
                                  hintText: "Enter Full Address",
                                  labelText: "Address"),
                            ),
                          ],
                        )),
                    Center(
                      child: ElevatedButton(
                        child: Text(isNewCustomer == false ? "Check" : "Save",
                            style: TextStyle(
                              color: Colors.white,
                            )),
                        onPressed: () async {
                          String mobile = mobileController.text.trim();

                          if (!isNewCustomer) {
                            if (mobile.length != 10) {
                              SnapPeUI().toastError(
                                  message: "Please Enter valid Input.");
                              return;
                            }
                            if (await SnapPeNetworks()
                                .checkIsExistCustomer(mobile)) {
                              SnapPeUI().toastError(
                                  message:
                                      "$mobile This mobile number already exist.");
                              return;
                            }
                            setState(() {
                              print("new customer");
                              isNewCustomer = true;
                            });
                            return;
                          }

                          String fName = firstNameController.text.trim();
                          String lName = lastNameController.text.trim();

                          String company = companyController.text.trim();
                          String pincode = pincodeController.text.trim();
                          String address = fullAddressController.text.trim();

                          if (fName == '' ||
                              lName == '' ||
                              pincode == '' ||
                              address == '' ||
                              _selectedCommunity == '') {
                            SnapPeUI().toastError(
                                message: "Please Enter valid Input.");
                            return;
                          }

                          ConsumerModel con = new ConsumerModel();
                          con.firstName = fName;
                          con.lastName = lName;
                          con.phoneNo = "91" + mobile;
                          con.organizationName = company;
                          con.pincode = int.parse(pincode);
                          con.community = _selectedCommunity;
                          con.houseNo = address;
                          con.addressType = "Home";
                          con.isValid = false;
                          bool result =
                              await SnapPeNetworks().createNewCustomer(con);
                          if (result) {
                            List<OrderSummaryModel> orders =
                                await SnapPeNetworks()
                                    .customerSuggestionsCallback(
                                        "${con.phoneNo}");
                            Navigator.pop(context);
                            if (orders.length == 0) {
                              SnapPeUI().toastError();
                              return;
                            }

                            Map<String,dynamic>? map= await SnapPeNetworks().getCustomerAdressForOrder(orders[0]!.userId.toString()??"0");
if(map!=null){
  orders[0].address=Address.fromJson(map['address']);
  orders[0].billingAddress=Address.fromJson(map['billingAddress']);
}
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => fromquotation
                                      ? QuotationCartScreeen(order: orders[0])
                                      : CartScreen(order: orders[0]),
                                ));
                          }
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  FloatingActionButton _fab() {
    return FloatingActionButton.extended(
      label: Text("Create Order"),
      icon: Icon(
        Icons.article,
        color: Colors.white,
      ),
      onPressed: () {
        selectCustomerDialog(false);
      },
    );
  }

  FloatingActionButton _fabq() {
    return FloatingActionButton.extended(
      label: Text("Create Quotation"),
      icon: Icon(
        Icons.article,
        color: Colors.white,
      ),
      onPressed: () {
        selectCustomerDialog(true);
      },
    );
  }

  _searchOrder({String keyword = ""}) async {
    int toTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    int fromTimestamp = toTimestamp - 2629743;
    print("insearch");
    if (keyword == "") {
      loadData(forcedReload: true);
    } else {
      print("has a keyword");
      try {
        loadData(orderSearch: keyword, tabindex: tabIndex, forcedReload: true);
      } catch (e) {
        print(e);
      }
    }
  }

  loadData(
      {String? orderSearch,
      bool forcedReload = false,
      int tabindex = 0}) async {
    int toTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    int fromTimestamp = (DateTime.now().subtract(Duration(days: 130)).millisecondsSinceEpoch/ 1000).round();

    if (forcedReload) {
      print("forced Reload");
      if (tabIndex == 1) {
        print("pending Orders Fetching ");
        pendingOrderJson = await SnapPeNetworks().getPendingOrders(
            fromTimestamp, toTimestamp, 0, 20,
            searchKeyword: orderSearch);
        if (pendingOrderJson == null) return;
        SharedPrefsHelper().setPendingOrders(pendingOrderJson!);
      } else if (tabIndex == 0) {
        print("Orders Fetching with searchKeyword");
        orderJson = await SnapPeNetworks().getOrderList(0, 20,
            searchKeyword: orderSearch,
            timeFrom: fromTimestamp,
            timeTo: toTimestamp);
        if (orderJson == null) return;
        SharedPrefsHelper().setOrders(orderJson!);
      } else {
        print("quotation Fetching ");
        quotationJson = await SnapPeNetworks().getQuotations(
            fromTimestamp, toTimestamp, 0, 20,
            searchKeyword: orderSearch);
      }
    } else if (orderJson == null ||
        pendingOrderJson == null ||
        communityJson == null ||
        quotationJson == null) {
      print("from DB");

      quotationJson = await SnapPeNetworks().getPendingOrders(
          fromTimestamp, toTimestamp, 0, 20,
          searchKeyword: orderSearch);

      orderJson = await SharedPrefsHelper().getOrders() ??
          await SnapPeNetworks().getOrderList(
            0,
            20,
            searchKeyword: orderSearch,
            timeFrom: fromTimestamp,
            timeTo: toTimestamp,
          );

      if (orderJson == null) return;
      SharedPrefsHelper().setOrders(orderJson!);

      pendingOrderJson = await SharedPrefsHelper().getPendingOrders() ??
          await SnapPeNetworks().getPendingOrders(
              fromTimestamp, toTimestamp, 0, 20,
              searchKeyword: orderSearch);

      if (pendingOrderJson == null) return;
      SharedPrefsHelper().setPendingOrders(pendingOrderJson!);

      communityJson = await SharedPrefsHelper().getCommunity() ??
          await SnapPeNetworks().getCommunity();

      if (communityJson == null) return;
      SharedPrefsHelper().setCommunity(communityJson!);

      isRequiredCompanyName = await SharedPrefsHelper().isRequiredCompany();
    }
    if (mounted) {
      setState(() {
        try {
          CommunityModel communityModel =
              communityModelFromJson(communityJson!);
          communities = communityModel.communities == null
              ? []
              : communityModel.communities!;
          if (tabIndex == 1) {
            setState(() {
              orders = orderModelFromJson(pendingOrderJson!).orders;
            });
          } else if (tabIndex == 2) {
            print(tabindex);
            print("index2 quotation");
            print(quotationJson);
            setState(() {
              orders = orderModelFromJson(quotationJson!).orders;
            });
            print(orders![0].orderStatus);
          } else {
            setState(() {
              orders = orderModelFromJson(orderJson!).orders;
            });
          }
        } catch (ex) {
          print(ex);
        }
      });
    }
  }

  _buildBody() {
    return RefreshIndicator(
      child: Padding(
        padding:widget.tabIndex!=0?EdgeInsets.fromLTRB(8, 60, 8, 0)   :EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          children: [
            CupertinoSearchTextField(
              placeholder: "Search Order",
              decoration: SnapPeUI().searchBoxDecoration(),
              onChanged: (value) {
                _searchOrder(keyword: value);
              },
            ),
            SizedBox(height: 5),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: 'Orders'),
                          Tab(text: 'Pending Orders'),
                          Tab(text: 'Quotation'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _orderList(),
                          _orderList(),
                          _orderList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onRefresh: () {
        return Future.delayed(
          Duration(seconds: 1),
          () {
            loadData(forcedReload: true, tabindex: tabIndex);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _orderList() {
    if (orders == null) {
      return SnapPeUI().loading();
    } else {
      return Column(
        children: [
          if (orders!.length != 0)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  return Future.delayed(
                    Duration(seconds: 1),
                    () {
                      loadData(forcedReload: true, tabindex: tabIndex);
                      setState(() {});
                    },
                  );
                },
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: orders!.length,
                    itemBuilder: (context, index) {
                      return OrderWidget(
isfromlead: widget.isfromlead!,
                        isquotation: tabIndex == 2 ? true : false,
                        onBack: () {
                          setState(() {
                            loadData(forcedReload: true, tabindex: tabIndex);
                          });
                          
                        },
                        order: orders![index],
                        orderScreenState: this,
                        
                      );
                    }),
              ),
            ),
          if (orders!.length == 0) SnapPeUI().noDataFoundImage()
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _buildBody(),
      floatingActionButton: tabIndex == 2 ? _fabq() : _fab(),
    );
  }
}
