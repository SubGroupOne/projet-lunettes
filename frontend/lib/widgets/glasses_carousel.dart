import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/glasses_models.dart';
import 'glasses_viewer_3d.dart';

class GlassesCarousel extends StatefulWidget {
  final List<GlassesModel> glassesList;
  final Function(GlassesModel)? onGlassesSelected;

  const GlassesCarousel({
    super.key, // ✅ Correction: Utilisation de super.key
    required this.glassesList,
    this.onGlassesSelected,
  });

  @override
  State<GlassesCarousel> createState() => _GlassesCarouselState();
}

class _GlassesCarouselState extends State<GlassesCarousel> {
  int _currentIndex = 0;
  // ✅ Correction: CarouselController devient CarouselSliderController en v5.0.0
  final carousel.CarouselSliderController _carouselController = carousel.CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (widget.glassesList.isEmpty) {
      return const Center(
        child: Text('Aucune monture disponible'),
      );
    }

    return Column(
      children: [
        carousel.CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: widget.glassesList.length,
          itemBuilder: (context, index, realIndex) {
            final glasses = widget.glassesList[index];

            return AnimatedScale(
              scale: _currentIndex == index ? 1.0 : 0.85,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GlassesViewer3D(
                  glasses: glasses,
                  onTap: () {
                    if (widget.onGlassesSelected != null) {
                      widget.onGlassesSelected!(glasses);
                    }
                  },
                ),
              ),
            );
          },
          options: carousel.CarouselOptions(
            height: 400,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),

        const SizedBox(height: 20),

        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: widget.glassesList.length,
          effect: WormEffect(
            dotHeight: 12,
            dotWidth: 12,
            activeDotColor: Theme.of(context).primaryColor,
            dotColor: Colors.grey.shade300,
          ),
          onDotClicked: (index) {
            _carouselController.animateToPage(index);
          },
        ),

        const SizedBox(height: 20),
        _buildGlassesInfo(widget.glassesList[_currentIndex]),
      ],
    );
  }

  Widget _buildGlassesInfo(GlassesModel glasses) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(glasses.id),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ✅ Correction: .withOpacity est déprécié, on utilise .withValues
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        glasses.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        glasses.brand,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    // ✅ Correction: .withValues ici aussi
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${glasses.price.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildInfoChip(icon: Icons.category, label: glasses.category.toUpperCase()),
                _buildInfoChip(icon: Icons.palette, label: glasses.color),
                _buildInfoChip(icon: Icons.build, label: glasses.material),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              glasses.description,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: glasses.isAvailable
                    ? () => widget.onGlassesSelected?.call(glasses)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  glasses.isAvailable ? 'Essayer virtuellement' : 'Indisponible',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
