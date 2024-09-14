part of 'image_bloc.dart';

@sealed
abstract class ImageEvent {}

class LoadImages extends ImageEvent {
  final String query;

  LoadImages(this.query);
}
