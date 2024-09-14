import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/gallery/bloc/image_bloc.dart';
import 'features/gallery/ui/gallery_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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