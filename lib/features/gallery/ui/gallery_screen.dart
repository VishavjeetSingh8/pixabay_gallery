import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/image_bloc.dart';
import '../utils/debounce.dart';
import 'image_detail_screen.dart';

class GalleryScreen extends StatelessWidget {
  final Debounce debounce = Debounce(const Duration(milliseconds: 500));

  GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixabay Gallery'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                debounce(() {
                  context.read<ImageBloc>().add(LoadImages(query));
                });
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state is ImageLoading && state is! ImageInitial) {
            return const Center(child: CircularProgressIndicator(color: Colors.black87));
          } else if (state is ImageLoaded) {
            final images = state.images;

            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!state.hasMore) return false;
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  context.read<ImageBloc>().add(LoadImages(state.query));
                }
                return false;
              },
              child: CustomScrollView(slivers: [
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
                            Expanded(
                              child: Center(
                                child: Image.network(
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.warning,color: Colors.yellow,);
                                  },
                                  image.webFormatUrl,
                                ),
                              ),
                            ),
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
                SliverToBoxAdapter(
                  child: state.hasMore ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: CircularProgressIndicator(color: Colors.black87)
                    ),
                  ) : const SizedBox(height: 0,width: 0,),
                ),
              ]),
            );
          } else if (state is ImageError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Pixabay Gallery'));
        },
      ),
    );
  }
}
