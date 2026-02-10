// lib/widgets/glasses_viewer_3d.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/glasses_models.dart';

class GlassesViewer3D extends StatefulWidget {
  final GlassesModel glasses;
  final VoidCallback? onTap;

  const GlassesViewer3D({
    Key? key,
    required this.glasses,
    this.onTap,
  }) : super(key: key);

  @override
  State<GlassesViewer3D> createState() => _GlassesViewer3DState();
}

class _GlassesViewer3DState extends State<GlassesViewer3D>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationY = 0.0;
  double _scale = 1.0;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rotationY += details.delta.dx * 0.01;
      // Calculer l'index de l'image en fonction de la rotation
      if (widget.glasses.images.isNotEmpty) {
        int totalImages = widget.glasses.images.length;
        double normalizedRotation = (_rotationY % (2 * math.pi)) / (2 * math.pi);
        _currentImageIndex = (normalizedRotation * totalImages).floor() % totalImages;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: _onPanUpdate,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Auto-rotation subtile
          double autoRotation = _controller.value * 2 * math.pi;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(_rotationY + autoRotation * 0.1)
              ..scale(_scale),
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: Offset(
                      math.sin(_rotationY) * 10,
                      10,
                    ),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Image principale avec effet de brillance
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.8),
                          ],
                          stops: [0.0, 0.5, 1.0],
                          transform: GradientRotation(_controller.value * 2 * math.pi),
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.overlay,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Image.asset(
                          widget.glasses.images.isNotEmpty
                              ? 'assets/glasses/${widget.glasses.images[_currentImageIndex]}'
                              : 'assets/glasses/${widget.glasses.mainImage}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, size: 50),
                            );
                          },
                        ),
                      ),
                    ),

                    // Gradient overlay pour profondeur
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Informations de la monture
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.glasses.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.glasses.brand,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${widget.glasses.price.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Badge de disponibilité
                    if (!widget.glasses.isAvailable)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Indisponible',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}