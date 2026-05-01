import 'package:flutter/material.dart';

/// A stateful toggle switch styled to match Rythmify's design.
/// Active state uses SoundCloud orange [0xFFFF5500], inactive uses grey.
/// Thumb is always white. Accepts an [initValue] and an [onChanged] callback.
class SwitchWidget extends StatefulWidget {
  final bool initValue;
  final ValueChanged<bool>? onChanged;

  const SwitchWidget({super.key, this.initValue = false, this.onChanged});

  @override
  State<SwitchWidget> createState() => _SwitchStateWidget();
}

class _SwitchStateWidget extends State<SwitchWidget> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initValue;
  }

  @override
  void didUpdateWidget(SwitchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initValue != widget.initValue) {
      _value = widget.initValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _value = !_value);
        widget.onChanged?.call(_value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 14,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _value ? const Color(0xFFFF5500) : Colors.grey,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: _value ? 20 : -4,
              top: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
