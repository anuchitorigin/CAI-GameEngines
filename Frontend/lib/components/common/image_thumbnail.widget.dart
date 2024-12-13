import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImageThumbnailWidget extends StatelessWidget {
  const ImageThumbnailWidget({super.key, required this.image, this.title});

  final Image image;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          showDialog(context: context, builder: (context) {
            return LayoutBuilder(
              builder: (context, BoxConstraints constraints) {
                BoxConstraints dialogConstraints = constraints;

                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      context.pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: dialogConstraints.maxHeight - 215,
                              ),
                              child: image,
                            ),
                            title != null ? Text(title!, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold,),) : const SizedBox(width: double.minPositive, height: double.minPositive,),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: image,
        ),
      ),
    );
  }
}