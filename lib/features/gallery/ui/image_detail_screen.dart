import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/image_model.dart';

class ImageDetailScreen extends StatelessWidget {
  final ImageModel
      image; // ImageModel instance representing the image to be displayed

  const ImageDetailScreen(
      {super.key, required this.image}); // Constructor to receive image details

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Detail'), // AppBar with title
      ),
      body: Center(
        // Display the image from the cache or network
        child: CachedNetworkImage(
          imageUrl: image.largeImageUrl, // The URL of the large version of the image
          // Progress indicator while loading the image
          progressIndicatorBuilder: (context, url, downloadProgress) {
            int totalSize = downloadProgress.totalSize??100;
            return Center(
              child: CircularProgressIndicator(
                value: downloadProgress.downloaded/totalSize, // Progress indicator shows loading status
                color: Colors.black, // Set progress indicator color
              ),
            );
          },
          errorWidget: (context, url, error) => const Icon(
            Icons.error,
            color: Colors.red, // Show error icon if image fails to load
          ),
        )
      ),
    );
  }
}
