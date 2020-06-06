import 'package:ehreader/models/gallery.dart';
import 'package:ehreader/repositories/ehentai_client.dart';
import 'package:ehreader/stores/image.dart';
import 'package:ehreader/widgets/stateful_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'store.dart';

class ViewAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  // ignore: avoid_field_initializers_in_const_classes
  final Size preferredSize = const Size.fromHeight(56);

  const ViewAppBar({Key key}) : super(key: key);

  @override
  _ViewAppBarState createState() => _ViewAppBarState();
}

class _ViewAppBarState extends State<ViewAppBar>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0,
    );
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewStore = Provider.of<ViewStore>(context);
    final imageStore = Provider.of<ImageStore>(context);
    final gallery = Provider.of<Gallery>(context);
    final client = Provider.of<EHentaiClient>(context);

    return StatefulWrapper(
      onInit: (context) {
        return reaction((_) => viewStore.navVisible, (bool visible) {
          if (visible) {
            _animationController.forward();
            SystemChrome.setEnabledSystemUIOverlays([
              SystemUiOverlay.top,
              SystemUiOverlay.bottom,
            ]);
          } else {
            _animationController.reverse();
            SystemChrome.setEnabledSystemUIOverlays([]);
          }
        });
      },
      builder: (context) {
        final height = widget.preferredSize.height;
        final position = Tween<Offset>(
          begin: Offset(0, -height),
          end: const Offset(0, 0),
        ).animate(_animationController);

        return SlideTransition(
          position: position,
          child: Observer(
            builder: (context) {
              final page = GalleryIdWithPage((b) => b
                ..galleryId = gallery.id.toBuilder()
                ..page = viewStore.currentPage + 1);
              final image = imageStore.data[imageStore.index[page]];

              return AppBar(
                elevation: 0,
                backgroundColor: Colors.black.withOpacity(0.5),
                title:
                    Text('${viewStore.currentPage + 1} / ${gallery.fileCount}'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.share),
                    tooltip: 'Share',
                    onPressed: () {
                      if (image != null) {
                        Share.share(
                          client.getImageUrl(image.id),
                          subject: gallery.title,
                        );
                      }
                    },
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }
}
