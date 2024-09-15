import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/image_model.dart';
import '../services/pixabay_service.dart'; // Importing the service that fetches images from Pixabay

part 'image_event.dart'; // Importing the events for the ImageBloc
part 'image_state.dart'; // Importing the states for the ImageBloc

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final PixabayService _pixabayService =
      PixabayService(); // Service instance for API calls
  int _page = 1; // Tracks the current page of images
  bool _hasMore = true; // Indicates if more images can be loaded
  String _query = ''; // Tracks the current search query

  ImageBloc() : super(ImageInitial()) {
    on<LoadImages>(
        _onLoadImages); // Register the event handler for loading images

    // Initially load images with an empty query to display default results
    add(LoadImages(''));
  }

  int queryCount =
      0; // Tracks the count of queries for debounce/cancellation logic

  // Event handler for loading images
  Future<void> _onLoadImages(LoadImages event, Emitter<ImageState> emit) async {
    queryCount++; // Increment the query counter
    int prevQueryCount = queryCount; // Capture the current query count

    try {
      // If a new search query is provided, reset the page and fetch new results
      if (event.query != _query) {
        _query = event.query;
        _page = 1;
        _hasMore = true;
      }

      // If starting a new search, show the loading indicator
      if (_page == 1) {
        emit(ImageLoading());
      }

      // If there are no more images to load, keep the current state
      if (!_hasMore) {
        emit(ImageLoaded(
            images: (state as ImageLoaded).images,
            hasMore: false,
            query: _query));
        return;
      }

      // Fetch images from the Pixabay service using the current query and page number
      final data = await _pixabayService.fetchImages(_query, _page);

      // If the query count has changed, discard outdated results (debounce logic)
      if (prevQueryCount != queryCount) {
        return;
      }

      // Parse the fetched images
      final List<ImageModel> loadedImages = (data['hits'] as List)
          .map((item) => ImageModel.fromJson(item))
          .toList();

      // Log the fetched images count
      //print('_page $_page _query $_query newImages ${loadedImages.length}');

      // If no images are found, show an error or update the state
      if (loadedImages.isEmpty) {
        _hasMore = false; // No more images to load
        // Show error if no images found on the first page
        if (state is! ImageLoaded || (state as ImageLoaded).images.isEmpty) {
          emit(ImageError('No Images found matching $_query'));
        }
        // Otherwise, keep the existing images in the state
        else if (state is ImageLoaded) {
          emit(ImageLoaded(
              images: (state as ImageLoaded).images,
              hasMore: _hasMore,
              query: _query));
        }
      } else {
        // Increment page for the next API call if there are more images
        _page++;

        // Append the newly loaded images to the existing list of images
        final images = (state is ImageLoaded)
            ? (state as ImageLoaded).images + loadedImages
            : loadedImages;

        //print('Total Image length ${images.length}');

        // Emit the updated state with the new images and loading status
        emit(ImageLoaded(images: images, hasMore: _hasMore, query: _query));
      }
    } catch (e, stack) {
      // Log the error and stack trace for debugging purposes
      print('Error: ${e.toString()}');
      print(stack);

      // Emit an error state if something goes wrong during image loading
      emit(ImageError('Failed to load images'));
    }
  }
}
