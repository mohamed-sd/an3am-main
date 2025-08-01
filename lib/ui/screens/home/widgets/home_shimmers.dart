import 'package:an3am/ui/screens/navigations/home_screen.dart';
import 'package:an3am/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:an3am/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class SliderShimmer extends StatelessWidget {
  const SliderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          CustomShimmer(
            height: 130,
            width: context.screenWidth,
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

class PromotedItemsShimmer extends StatelessWidget {
  const PromotedItemsShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 261,
        child: ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
                child: CustomShimmer(
                  height: 272,
                  width: 250,
                ),
              );
            }));
  }
}

class MostLikedItemsShimmer extends StatelessWidget {
  const MostLikedItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 162 / 274,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          crossAxisCount: 2),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: CustomShimmer(),
        );
      },
    );
  }
}

class NearbyItemsShimmer extends StatelessWidget {
  const NearbyItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        child: ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
                child: const CustomShimmer(
                  height: 200,
                  width: 300,
                ),
              );
            }));
  }
}

class MostViewdItemsShimmer extends StatelessWidget {
  const MostViewdItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: sidePadding,
        ),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 162 / 274,
            mainAxisSpacing: 15,
            crossAxisCount: 2),
        itemCount: 5,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: CustomShimmer(),
          );
        });
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        padding: const EdgeInsets.symmetric(
          horizontal: sidePadding,
        ),
        itemBuilder: (context, index) {
          return CustomShimmer(
            width: 100,
            height: 44,
            margin: const EdgeInsetsDirectional.only(end: 10, bottom: 5),
          );
        });
  }
}
