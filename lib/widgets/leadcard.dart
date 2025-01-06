import 'package:flutter/material.dart';

class LeadCard extends StatefulWidget {
  const LeadCard({super.key});

  @override
  State<LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<LeadCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Hero(
        tag: 'leadCardHero',
        child: Card(
          elevation: 4,
          child: AnimatedSize(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ensures the column takes only the necessary space
              children: [
                ListTile(
                  leading: Stack(
                    
                    children: [
                      Container(height: 10,width: 10,color: Colors.green.shade300,),
                      CircleAvatar(child: Text("T")),
                      Positioned(bottom: 0,left: -50,right: -50,child: Tooltip(message: "status",child: Container(height: 14,width: 10,color: Colors.purple.shade300,child: Center(child: Text("status")),)))
                    ],
                  ),
                  title: Text("name"),
                  trailing: Text("uii"),
                  subtitle: Text("hgghhg"),
                ),
                AnimatedOpacity(
                  opacity: _isExpanded ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 900),
                  child: _isExpanded
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.phone, color: Colors.blue),
                              Icon(Icons.email, color: Colors.blue),
                              Icon(Icons.map, color: Colors.blue),
                            ],
                          ),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
