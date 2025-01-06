import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class SkeletonItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(),body: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white,
            ),
            SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white,
            ),
            SizedBox(height: 8.0),
            Container(
              width: 100.0,
              height: 16.0,
              color: Colors.white,
            ),
          ],
        ),
      ),
    ) );
    
    
  }
}