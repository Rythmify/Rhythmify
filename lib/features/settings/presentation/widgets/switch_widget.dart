import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (val) {
        setState(() => _value = val);
        widget.onChanged?.call(val);
      },
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFFFF5500);
        }
        return Colors.grey;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
