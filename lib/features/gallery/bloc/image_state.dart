part of 'image_bloc.dart';

@sealed
abstract class ImageState {}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImageLoaded extends ImageState {
  final List<ImageModel> images;
  final bool hasMore;
  final String query;

  ImageLoaded({required this.images, required this.hasMore,required this.query});
}

class ImageError extends ImageState {
  final String message;

  ImageError(this.message);
}
