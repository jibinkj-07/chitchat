import 'package:chitchat/utils/app_colors.dart';
import 'package:chitchat/widgets/chat/selected_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPreviewPicker extends StatefulWidget {
  final ScrollController? scrollController;
  final String currentUserid;
  final String targetUserid;
  final ScrollController listScrollController;
  const GalleryPreviewPicker({
    super.key,
    this.scrollController,
    required this.currentUserid,
    required this.targetUserid,
    required this.listScrollController,
  });

  @override
  State<GalleryPreviewPicker> createState() => _GalleryPreviewPickerState();
}

class _GalleryPreviewPickerState extends State<GalleryPreviewPicker> {
  // This will hold all the assets we fetched
  List<AssetEntity> assets = [];
  int currentPage = 0;
  int? lastPage;

  handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        fetchAssets();
      }
    }
  }

  fetchAssets() async {
    lastPage = currentPage;
    // Set onlyAll to true, to fetch only the 'Recent' album
    // which contains all the photos/videos in the storage
    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );
    final recentAlbum = albums.first;

    // Now that we got the album, fetch all the assets it contains
    final recentAssets =
        await recentAlbum.getAssetListPaged(size: 60, page: currentPage);

    // Update the state and notify UI
    setState(() => assets = recentAssets);
  }

  @override
  void initState() {
    fetchAssets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppColors appColors = AppColors();
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          //top bar
          topBar(context: context, appColors: appColors),
          Divider(
            height: 0,
            color: appColors.textColorBlack.withOpacity(.3),
          ),
          //thumbnail previews
          Expanded(
            child: thumbnailPreview(),
          ),
        ],
      ),
    ));
  }

  Widget thumbnailPreview() =>
      NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scroll) {
            handleScrollEvent(scroll);
            return false;
          },
          child: GridView.builder(
            controller: widget.scrollController,
            itemCount: assets.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 1.0,
              childAspectRatio: .6,
              crossAxisSpacing: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return AssetThumbnail(
                asset: assets[index],
                currentUserid: widget.currentUserid,
                targetUserid: widget.targetUserid,
                scrollController: widget.listScrollController,
              );
            },
          ),
        ),
      );

  Widget topBar(
          {required BuildContext context, required AppColors appColors}) =>
      Material(
        color: appColors.textColorWhite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: appColors.textColorBlack,
              splashRadius: 20.0,
              iconSize: 20.0,
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text(
              'Photos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: appColors.textColorBlack,
              ),
            ),
            const IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.transparent,
              ),
              color: Colors.white,
              splashRadius: 20.0,
              iconSize: 20.0,
              onPressed: null,
            ),
          ],
        ),
      );
}

//thumbnail previewer
class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({
    Key? key,
    required this.asset,
    required this.currentUserid,
    required this.targetUserid,
    required this.scrollController,
  }) : super(key: key);
  final String currentUserid;
  final String targetUserid;
  final ScrollController scrollController;
  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    // We're using a FutureBuilder since thumbData is a future
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        // If we have no data, display a spinner
        if (bytes == null) return const SizedBox();
        // If there's data, display it as an image
        return InkWell(
          onTap: () {
            final navigator = Navigator.of(context);
            navigator.push(
              MaterialPageRoute(
                builder: (_) => SelectedImagePreview(
                  currentUserid: currentUserid,
                  targetUserid: targetUserid,
                  imageFile: asset.file,
                  scrollController: scrollController,
                ),
              ),
            );
          },
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      },
    );
  }
}
