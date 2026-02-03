import 'package:flutter/material.dart';
import 'products_page.dart';

/// Thin compatibility wrapper kept to avoid breaking references.
/// It simply delegates to the new `ProductsPage` implementation.
class ChooseFramePage extends StatelessWidget {
  const ChooseFramePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductsPage();
  }
}
