part of eye_dropper;

class EyeDropperOverlay extends StatelessWidget {
  const EyeDropperOverlay({
    Key? key,
    required this.color,
    this.overlayColor,
  }) : super(key: key);

  final Color color;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kOverlaySize.height,
      width: kOverlaySize.width,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: kEyeDropperSize * 4,
                height: kEyeDropperSize * 4,
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  'assets/color-picker-overlay.png',
                  fit: BoxFit.fitHeight,
                  color: overlayColor,
                  width: kEyeDropperSize * 4,
                  height: kEyeDropperSize * 4,
                ),
              ),
              Positioned(
                top: 4,
                left: 6,
                right: 6,
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: kEyeDropperSize,
            width: kEyeDropperSize,
            decoration: BoxDecoration(
                color: color,
                border: Border.all(
                    width: 1.0, color: overlayColor ?? Colors.black45),
                borderRadius: BorderRadius.circular(16)),
          ),
        ],
      ),
    );
  }
}
