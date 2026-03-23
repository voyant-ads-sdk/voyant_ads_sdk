import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../models/height_models/ad_height_normalization.dart';
import '../models/media_models/carousel_media_model.dart';
import '../models/media_models/media_model.dart';
import 'helper.dart';

class CarouselAdWidget extends StatefulWidget {
  final CarouselMediaModel model;
  final bool fullScreenMode;
  final Widget? footerWidget;
  final Color loadingColor;
  final bool showDots;
  final double reservedHeight;
  final BoxConstraints? constraints;
  final HeightConstraint? heightConstraint;

  const CarouselAdWidget({
    super.key,
    required this.model,
    this.fullScreenMode = false,
    this.footerWidget,
    this.loadingColor = Colors.blue,
    this.showDots = true,
    this.heightConstraint,
    this.reservedHeight = 0,
    this.constraints,
  });

  @override
  State<CarouselAdWidget> createState() => _CarouselAdWidgetState();
}

class _CarouselAdWidgetState extends State<CarouselAdWidget> {
  final ValueNotifier<int> carouselIndex = ValueNotifier<int>(0);
  final CarouselSliderController carouselController =
      CarouselSliderController();
  List<Widget> _items = [];
  double? maxHeight;
  double? maxWidth;

  @override
  void initState() {
    super.initState();
    for (var element in widget.model.imagesList) {
      if (element.height != null) {
        maxHeight ??= element.height;
        if (element.height! > maxHeight!) {
          maxHeight = element.height;
        }
      }
      if (element.width != null) {
        maxWidth ??= element.width;
        if (element.width! > maxWidth!) {
          maxWidth = element.width;
        }
      }
    }
    _items = _buildItems();
  }

  @override
  void dispose() {
    carouselIndex.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CarouselAdWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      _items = _buildItems();
    }
  }

  List<Widget> _buildItems() {
    final model = widget.model;
    if (model is LocalCarouselMediaModel) {
      return model.imagesList
          .map((image) => Image.file(File(image.path), fit: BoxFit.contain))
          .toList();
    }
    if (model is UrlCarouselMediaModel) {
      return model.imagesList
          .map(
            (image) => Image.network(
              image.url,
              fit: BoxFit.contain,
              frameBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    int? frame,
                    bool wasSynchronouslyLoaded,
                  ) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
              loadingBuilder:
                  (BuildContext ctx, Widget child, ImageChunkEvent? progress) {
                    if (progress == null) return child;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            color: widget.loadingColor,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
              errorBuilder: (_, __, ___) {
                return const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.red),
                );
              },
            ),
          )
          .toList();
    }
    if (model is MemoryCarouselMediaModel) {
      return model.imagesList
          .map((image) => Image.memory(image.bytes, fit: BoxFit.contain))
          .toList();
    }
    return const [];
  }

  Widget _mainWidget(double? height) {
    return Stack(
      children: [
        CarouselSlider(
          carouselController: carouselController,
          options: CarouselOptions(
            height: widget.fullScreenMode ? double.infinity : height,
            aspectRatio: 16 / 9,
            pageSnapping: true,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              carouselIndex.value = index;
            },
          ),
          items: _items,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showDots)
                ValueListenableBuilder(
                  valueListenable: carouselIndex,
                  builder: (_, int value, __) {
                    return Wrap(
                      children: List.generate(
                        widget.model.imagesList.length,
                        (index) => MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () =>
                                carouselController.animateToPage(index),
                            child: Container(
                              width: 12.0,
                              height: 12.0,
                              margin: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(
                                  alpha: carouselIndex.value == index ? 1 : 0.4,
                                ),
                                boxShadow: const [
                                  BoxShadow(color: Colors.grey, blurRadius: 5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              if (widget.footerWidget != null) widget.footerWidget!,
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fullScreenMode) {
      return _mainWidget(null);
    }
    return AdsHelper.getScaledMediaDimensions(
      constraints: widget.constraints,
      mediaHeight: maxHeight,
      mediaWidth: maxWidth,
      heightConstraint: widget.heightConstraint,
      reservedHeight: widget.reservedHeight,
      builder: (double? height, double? width) {
        return _mainWidget(height);
      },
    );
  }
}
