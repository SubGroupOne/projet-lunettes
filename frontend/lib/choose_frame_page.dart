import 'package:flutter/material.dart';
import 'screens/glasses_selection_screen.dart';

/// Thin compatibility wrapper kept to avoid breaking references.
/// It simply delegates to the new `GlassesSelectionScreen` implementation.
class ChooseFramePage extends StatelessWidget {
  const ChooseFramePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GlassesSelectionScreen();
  }
}
