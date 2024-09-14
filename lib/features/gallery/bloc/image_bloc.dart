import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/image_model.dart';
import '../services/pixabay_service.dart';

part 'image_event.dart';

part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final PixabayService _pixabayService = PixabayService();
  int _page = 1;
  bool _hasMore = true;
  String _query = '';

  ImageBloc() : super(ImageInitial()) {
    on<LoadImages>(_onLoadImages);

    //QUERY EMPTY TERM
    add(LoadImages(''));
  }

  int queryCount = 0;

  Future<void> _onLoadImages(LoadImages event, Emitter<ImageState> emit) async {
    queryCount++;
    int prevQueryCount = queryCount;
    try {
      if (event.query != _query) {
        _query = event.query;
        _page = 1;
        _hasMore = true;
      }

      if (_page == 1) {
        emit(ImageLoading());
      }

      if (!_hasMore) {
        emit(ImageLoaded(
            images: (state as ImageLoaded).images, hasMore: false, query: _query));
        return;
      }

      final data = await _pixabayService.fetchImages(_query, _page);
      if (prevQueryCount != queryCount) {
        //print('Cancelling search result $_query -- obsolete');
        return;
      }
      final List<ImageModel> loadedImages =
          (data['hits'] as List).map((item) => ImageModel.fromJson(item)).toList();

      print('_page $_page _query $_query newImages ${loadedImages.length}');

      if (loadedImages.isEmpty) {
        _hasMore = false;
        if (state is! ImageLoaded || (state as ImageLoaded).images.isEmpty) {
          emit(ImageError('No Images found matching $_query'));
        } else if (state is ImageLoaded) {
          emit(ImageLoaded(
              images: (state as ImageLoaded).images, hasMore: _hasMore, query: _query));
        }
      } else {
        _page++;
        final images = (state is ImageLoaded)
            ? (state as ImageLoaded).images + loadedImages
            : loadedImages;
        print('Total Image length ${images.length}');
        emit(ImageLoaded(images: images, hasMore: _hasMore, query: _query));
      }
    } catch (e, stack) {
      print('Error: ${e.toString()}');
      print(stack);
      emit(ImageError('Failed to load images'));
    }
  }
}
