import 'package:flutter/material.dart';

import 'package:cai_gameengine/components/common/image_thumbnail.widget.dart';

class FutureImageThumbnailWidget extends StatelessWidget {
  const FutureImageThumbnailWidget({super.key, required this.futureImage, this.title});

  final Future<Image> futureImage;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<Image>(
      future: futureImage,
      builder: (BuildContext context, AsyncSnapshot<Image> futureImageSnapshot) {
        if(futureImageSnapshot.hasData) {
          return ImageThumbnailWidget(image: futureImageSnapshot.data!, title: title);
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: colorScheme.secondary,
                ),
              ),
            ],
          );
        }
      }
    );
  }
}