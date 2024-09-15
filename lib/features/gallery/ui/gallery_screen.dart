import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/image_bloc.dart';
import '../utils/debounce.dart';
import 'image_detail_screen.dart';

class GalleryScreen extends StatelessWidget {
  // Debounce instance to limit search input triggering multiple API calls
  final Debounce debounce = Debounce(const Duration(milliseconds: 500));

  GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title and search text field
      appBar: AppBar(
        title: const Text('Pixabay Gallery'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            // TextField for user to input search query
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              // Triggers search with debounce when query changes
              onChanged: (query) {
                debounce(() {
                  // Loads images based on search query
                  context.read<ImageBloc>().add(LoadImages(query));
                });
              },
            ),
          ),
        ),
      ),
      // BlocBuilder listens for changes in ImageBloc state
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          // Show loading spinner if images are being fetched
          if (state is ImageLoading && state is! ImageInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black87),
            );
          }
          // Display images when they are loaded
          else if (state is ImageLoaded) {
            final images = state.images;

            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // Check if more images can be loaded when the user scrolls to the end
                if (!state.hasMore) return false;
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  // Load more images based on the current search query
                  context.read<ImageBloc>().add(LoadImages(state.query));
                }
                return false;
              },
              child: CustomScrollView(
                slivers: [
                  // SliverGrid to display images in a grid layout
                  SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (MediaQuery.of(context).size.width / 150).floor(),
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final image = images[index];
                      return GestureDetector(
                        // Navigate to ImageDetailScreen on image tap
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageDetailScreen(image: image),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display the image, fallback to a warning icon if loading fails
                              Expanded(
                                child: Center(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    imageUrl: image.webFormatUrl, // URL of the image to fetch
                                    errorWidget: (context, url, error) => const Icon(Icons.warning, color: Colors.yellow), // Error handling UI
                                  ),
                                )
                              ),
                              // Display image likes and views
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${image.likes} Likes, ${image.views} Views'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Display loading indicator when more images are being fetched
                  SliverToBoxAdapter(
                    child: state.hasMore
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: CircularProgressIndicator(color: Colors.black87),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          }
          // Show error message if image loading fails
          else if (state is ImageError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          // Display default message when no images are loaded
          return const Center(child: Text('Pixabay Gallery'));
        },
      ),
    );
  }
}
