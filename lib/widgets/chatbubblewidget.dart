import 'package:flutter/material.dart';

const double BUBBLE_RADIUS_IMAGE = 16;

class CustomchatBubble extends StatelessWidget {
  static const loadingWidget = Center(
    child: CircularProgressIndicator(),
  );

  final String id;
  final Widget image;
  final double bubbleRadius;
  final bool isSender;
  final Color color;
  final bool tail;
  final bool sent;
  final bool delivered;
  final bool seen;
  final List<String>? buttons;
  final void Function()? onTap;

  const CustomchatBubble({
    Key? key,
    required this.id,
    required this.image,
    this.bubbleRadius = BUBBLE_RADIUS_IMAGE,
    this.isSender = true,
    this.buttons,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.onTap,
  }) : super(key: key);

  /// image bubble builder method
  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (sent) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (delivered) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (seen) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    return Row(
      children: <Widget>[
        isSender
            ? const Expanded(
                child: SizedBox(
                  width: 5,
                ),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .6,
                maxHeight:  MediaQuery.of(context).size.height ),
            child: GestureDetector(
                child: Hero(
                  tag: id,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(bubbleRadius),
                                topRight: Radius.circular(bubbleRadius),
                                bottomLeft: Radius.circular(tail
                                    ? isSender
                                        ? bubbleRadius
                                        : 0
                                    : BUBBLE_RADIUS_IMAGE),
                                bottomRight: Radius.circular(tail
                                    ? isSender
                                        ? 0
                                        : bubbleRadius
                                    : BUBBLE_RADIUS_IMAGE),
                              ),
                            ),


                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(bubbleRadius),
                                child: image,
                              ),
                            ),
                          ),
                buttons!=null?    Column(children:buttons!.map((e){

                  return MaterialButton(
                    elevation: 4,
                    onPressed: (){},child: Container(
                      width: MediaQuery.of(context).size.width*0.3,
                      child: Center(child: Text(e))),color: Colors.white,);
                }).toList(),):Container(),
                    
                    
                        ],
                      ),
                  
                    ],
                  ),
                ),
                onTap: onTap ??
                    () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return _DetailScreen(
                          tag: id,
                          image: image,
                        );
                      }));
                    }),
          ),
        )
      ],
    );
  }
}

/// detail screen of the image, display when tap on the image bubble
class _DetailScreen extends StatefulWidget {
  final String tag;
  final Widget image;

  const _DetailScreen({Key? key, required this.tag, required this.image})
      : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

/// created using the Hero Widget
class _DetailScreenState extends State<_DetailScreen> {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        body: Center(
          child: Hero(
            tag: widget.tag,
            child: widget.image,
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
