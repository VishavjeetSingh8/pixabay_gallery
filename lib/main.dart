import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/gallery/bloc/image_bloc.dart';
import 'features/gallery/ui/gallery_screen.dart';

void main() {
  runApp(const PixabayGalleryApp());
}

class PixabayGalleryApp extends StatelessWidget {
  const PixabayGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImageBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pixabay Gallery',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: GalleryScreen(),
      ),
    );
  }
}