import 'package:flutter/material.dart';

class PaymentItem extends StatelessWidget {
  final String title;
  final String? category;
  final IconData iconData;
  final String amount;

  const PaymentItem(
      {super.key,
      required this.title,
      this.category,
      required this.iconData,
      required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: const Color(0xFF2c3135),
          boxShadow: [
            BoxShadow(
                color: Colors.white.withOpacity(0.05),
                offset: const Offset(-10, -10),
                spreadRadius: 0,
                blurRadius: 10),
            BoxShadow(
                color: Colors.black87.withOpacity(0.3),
                offset: const Offset(10, 10),
                spreadRadius: 0,
                blurRadius: 10)
          ]),
      child: Row(
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: NeumorphicCircle(
              innerShadow: false,
              outerShadow: true,
              backgroundColor: const Color(0xFF2c3135),
              shadowColor: Colors.black87,
              highlightColor: Colors.white.withOpacity(0.05),
              child: Icon(
                iconData,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 4,
              ),
              (category == null)
                  ? const SizedBox.shrink()
                  : Text(category!,
                      style: TextStyle(
                          color: Colors.yellow.shade200.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w600))
            ],
          )),
          Text(amount,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600))
        ],
      ),
    );
  }
}

class NeumorphicCircle extends StatelessWidget {
  final bool innerShadow;
  final bool outerShadow;
  final Color highlightColor;
  final Color shadowColor;
  final Color backgroundColor;
  final Widget? child;

  const NeumorphicCircle(
      {super.key,
      required this.innerShadow,
      required this.outerShadow,
      required this.highlightColor,
      required this.shadowColor,
      required this.backgroundColor,
      this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
          decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: (outerShadow)
                  ? [
                      BoxShadow(
                          color: highlightColor,
                          offset: const Offset(-10, -10),
                          blurRadius: 20,
                          spreadRadius: 0),
                      BoxShadow(
                          color: shadowColor,
                          offset: const Offset(10, 10),
                          blurRadius: 20,
                          spreadRadius: 0)
                    ]
                  : null)),
      (innerShadow)
          ? ClipPath(
              clipper: HighlightClipper(),
              child: CircleInnerHighlight(
                highlightColor: highlightColor,
                backgroundColor: backgroundColor,
              ))
          : const SizedBox.shrink(),
      (innerShadow)
          ? ClipPath(
              clipper: ShadowClipper(),
              child: CircleInnerShadow(
                shadowColor: shadowColor,
                backgroundColor: backgroundColor,
              ),
            )
          : const SizedBox.shrink(),
      (child != null) ? child! : const SizedBox.shrink()
    ]);
  }
}

class CircleInnerShadow extends StatelessWidget {
  final Color shadowColor;
  final Color backgroundColor;

  const CircleInnerShadow(
      {super.key, required this.shadowColor, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            backgroundColor,
            shadowColor,
          ],
          center: const AlignmentDirectional(0.05, 0.05),
          focal: const AlignmentDirectional(0, 0),
          radius: 0.5,
          focalRadius: 0,
          stops: const [0.75, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 0.45],
                colors: [backgroundColor.withOpacity(0), backgroundColor])),
      ),
    );
  }
}

class CircleInnerHighlight extends StatelessWidget {
  final Color highlightColor;
  final Color backgroundColor;

  const CircleInnerHighlight(
      {super.key, required this.highlightColor, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            backgroundColor,
            highlightColor,
          ],
          center: const AlignmentDirectional(-0.05, -0.05),
          focal: const AlignmentDirectional(-0.05, -0.05),
          radius: 0.6,
          focalRadius: 0.1,
          stops: const [0.75, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.55, 1],
                colors: [backgroundColor, backgroundColor.withOpacity(0)])),
      ),
    );
  }
}

class ShadowClipper extends CustomClipper<Path> {
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
}

class HighlightClipper extends CustomClipper<Path> {
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }
}
