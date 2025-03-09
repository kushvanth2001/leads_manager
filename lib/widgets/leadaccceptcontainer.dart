import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:leads_manager/helper/SharedPrefsHelper.dart';
import 'package:leads_manager/models/model_lead.dart';
import 'package:leads_manager/utils/snapPeNetworks.dart';

class FlameContainer extends StatefulWidget {
  final Function(Lead) onAccept;

  FlameContainer({required this.onAccept});

  @override
  _FlameContainerState createState() => _FlameContainerState();
}

class _FlameContainerState extends State<FlameContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Lead>(
      onAccept: (lead) async{
        widget.onAccept(lead);
     String? favString = await SharedPrefsHelper().getFavoriteLeads();
  
  List<String> favoriteLeads;

  if (favString == null) {
    // Initialize a new list if no favorite leads are present
    favoriteLeads = [lead.id.toString()];
  } else {
    // Decode the existing favorite leads
    favoriteLeads = List<String>.from(jsonDecode(favString));
    
    if (!favoriteLeads.contains(lead.id.toString())) {
      // Add the new leadId only if it is not already in the list
      favoriteLeads.add(lead.id.toString());
    }
  }

  // Encode the updated list back to JSON
  String updatedFavString = jsonEncode(favoriteLeads);
  
  // Save the updated favorite leads list back to SharedPreferences
  await SharedPrefsHelper().setFavoriteLeads(updatedFavString);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(height: 100,width: MediaQuery.of(context).size.width,color: Colors.blue.shade300,child: Center(child: Text("Add it to Favourite"),),);
          },
        );
      },
    );
  }
}

class FlamePainter extends CustomPainter {
  final List<Color> colors;
  
  final double animationValue;

  FlamePainter({required this.colors, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();

    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i].withOpacity(1 - (i / colors.length));
      path.moveTo(size.width / 2, size.height);
      path.quadraticBezierTo(
        size.width / 2 + (i * 10) * sin(animationValue * pi * 2),
        size.height / 2,
        size.width / 2 + (i * 20) * cos(animationValue * pi * 2),
        0,
      );
      path.lineTo(size.width / 2 - (i * 20) * cos(animationValue * pi * 2), 0);
      path.quadraticBezierTo(
        size.width / 2 - (i * 10) * sin(animationValue * pi * 2),
        size.height / 2,
        size.width / 2,
        size.height,
      );
      canvas.drawPath(path, paint);
      path.reset();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
