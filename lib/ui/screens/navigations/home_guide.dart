// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:an3am/app/routes.dart';
import 'package:an3am/data/cubits/category/fetch_category_cubit.dart';
import 'package:an3am/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:an3am/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:an3am/data/cubits/favorite/favorite_cubit.dart';
import 'package:an3am/data/cubits/fetch_blogs_cubit.dart';
import 'package:an3am/data/cubits/slider_cubit.dart';
import 'package:an3am/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:an3am/data/model/item/item_model.dart';
import 'package:an3am/data/model/system_settings_model.dart';
import 'package:an3am/ui/screens/home/GoldShimmerCard.dart';
import 'package:an3am/ui/screens/home/slider_widget.dart';
import 'package:an3am/ui/screens/home/widgets/category_widget_home.dart';
import 'package:an3am/ui/screens/home/widgets/location_widget.dart';
import 'package:an3am/ui/screens/widgets/CustomDrawerWidget.dart';
import 'package:an3am/ui/screens/widgets/marqeeWidget.dart';
import 'package:an3am/ui/theme/theme.dart';
//import 'package:uni_links/uni_links.dart';
import 'package:an3am/utils/app_icon.dart';
import 'package:an3am/utils/constant.dart';
import 'package:an3am/utils/custom_text.dart';
import 'package:an3am/utils/extensions/extensions.dart';
import 'package:an3am/utils/hive_utils.dart';
import 'package:an3am/utils/notification/awsome_notification.dart';
import 'package:an3am/utils/notification/notification_service.dart';
import 'package:an3am/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

const double sidePadding = 10;

class HomeGuide extends StatefulWidget {
  final String? from;

  const HomeGuide({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeGuide>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeGuide> {
  //
  @override
  bool get wantKeepAlive => true;

  //
  List<ItemModel> itemLocalList = [];

  //
  bool isCategoryEmpty = false;

  //
  late final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Color mainColor = Color(0xff271301);
  Color marqueeBgColor = Color(0xff150900);
  @override
  void initState() {
    super.initState();
    initializeSettings();
    addPageScrollListener();
    notificationPermissionChecker();
    LocalAwesomeNotification().init(context);
    ///////////////////////////////////////
    NotificationService.init(context);
    //for marquee
    context.read<FetchBlogsCubit>().fetchBlogs();
    //
    loadItemData();
    if (HiveUtils.isUserAuthenticated()) {
      context.read<FavoriteCubit>().getFavorite();
      //fetchApiKeys();
      context.read<GetBuyerChatListCubit>().fetch();
      context.read<BlockedUsersListCubit>().blockedUsersList();
    }
  }

  void _openCustomSideSheet(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent, // خلفية شفافة
      builder: (context) {
        return Align(
          alignment: Alignment.centerRight,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              bottomLeft: Radius.circular(50),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              height: double.infinity,
              width: MediaQuery.of(context).size.width * 0.70,
              color: Color.fromARGB(255, 66, 37, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: context.color.mainGold,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(50)),
                    child: Icon(
                      Icons.close,
                      color: context.color.mainGold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: context.color.mainGold, width: 1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: UiUtils.getSvg(AppIcons.appbarLogo,
                            fit: BoxFit.cover),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Equipation@info.com",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void loadItemData() {
    context.read<SliderCubit>().fetchSlider(
          context,
        );
    context.read<FetchCategoryCubit>().fetchCategories();
    /*  context.read<FetchHomeScreenCubit>().fetch(
          city: HiveUtils.getCityName(),
          country: HiveUtils.getCountryName(),
          state: HiveUtils.getStateName(),
          radius: HiveUtils.getNearbyRadius(),
          longitude: HiveUtils.getLongitude(),
          latitude: HiveUtils.getLatitude(),
        );
    context.read<FetchHomeAllItemsCubit>().fetch(
        city: HiveUtils.getCityName(),
        radius: HiveUtils.getNearbyRadius(),
        longitude: HiveUtils.getLongitude(),
        latitude: HiveUtils.getLatitude(),
        country: HiveUtils.getCountryName(),
        state: HiveUtils.getStateName()); */
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) ?? false;
    }
  }

  void addPageScrollListener() {
    //homeScreenController.addListener(pageScrollListener);
  }

  bool section1 = false;
  bool section2 = false;
  bool section3 = false;
  bool section4 = false;
  bool section5 = false;
  bool section6 = false;
  bool section7 = false;
  bool section8 = false;
  bool section9 = false;
  bool section10 = false;
  bool section11 = false;
  bool section12 = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          //leadingWidth: double.maxFinite,
          titleSpacing: 0,
          title: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.profileScreen);
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            width: 1, color: Colors.white)),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: InkWell(
              //       onTap: () {
              //         showModalBottomSheet(
              //             context: context,
              //             isScrollControlled: true,
              //             backgroundColor: Colors.transparent,
              //             shape: RoundedRectangleBorder(
              //               borderRadius:
              //                   BorderRadius.vertical(top: Radius.circular(25)),
              //             ),
              //             builder: (context) => const CustomDrawerWidget());
              //         // _openCustomSideSheet(context);
              //       },
              //       child: Icon(Icons.menu)),
              // ),
              Padding(
                  padding: EdgeInsetsDirectional.only(end: sidePadding),
                  child: appbarTitleWidget()),
            ],
          ),
          backgroundColor: context.color.mainBrown,
          foregroundColor: context.color.mainGold,
          // backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          actions: appbarActionsWidget(),
        ),
        backgroundColor: context.color.mainGold,
        body: Column(
          children: [
            blogMarqueeWidget(),
            Container(

                padding: const EdgeInsetsDirectional.only(
                    start: sidePadding, end: sidePadding, bottom: 10, top: 0),
                alignment: AlignmentDirectional.centerStart,
                child: LocationWidget()),
            // SizedBox(
            //   height: 10,
            // ),
            // Container(
            //     margin: EdgeInsets.symmetric(horizontal: 10),
            //     child: SliderWidget()),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 0),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                padding: EdgeInsetsDirectional.only(top: 10, bottom: 80),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    )),
                child: RefreshIndicator(
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  key: _refreshIndicatorKey,
                  color: context.color.territoryColor,
                  onRefresh: () async {
                    print("refresh-------");
                    loadItemData();
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    controller: _scrollController,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsetsDirectional.fromSTEB(30, 0, 20, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 15, 0, 5),
                              child: Text(
                                'أهلاً بك في  إجراءات انعام!',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'IBMPlexArabic'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 5, 3, 0),
                              child: Text(
                                'حيث نضع كلما تبحث عنه امام عينيك ،',
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'IBMPlexArabic'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 5, 3, 0),
                              child: Text(
                                'لتكون علي خطوة واحدة عن عالم الثروة الحيوانية.',
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'IBMPlexArabic'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      // SliderWidget(),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: const SliderWidget()),
                      SizedBox(
                        height: 10,
                      ),
                      CustomText(
                        'دليل انعام بين يديك',
                        textAlign: TextAlign.center,
                        height: 1,
                        customTextStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      InkWell(
                        onTap: () {
                          setState(() {
                            if (section1)
                              section1 = false;
                            else
                              section1 = true;
                          });
                        },
                        child: title_card(' الإجراءات الحكومية (الثروة الحيوانية)', section1,'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/enjaz%2F%D8%A5%D8%AF%D8%A7%D8%B1%D8%A9%20%D8%A7%D9%84%D8%B7%D9%84%D8%A8%D8%A7%D8%AA.png?alt=media&token=cde6bd1b-f856-4d00-b418-437ea6e9dbd7'),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (section1)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: [
                                  // The Card
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.guide);
                                    },
                                    child: GoldShimmerCard(
                                        title: 'وزارة الثروة الحيوانية والسمكية',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/anaam%2F21-%20%D9%88%D8%B2%D8%A7%D8%B1%D8%A9%20%D8%A7%D9%84%D8%AB%D8%B1%D9%88%D8%A9%20%D8%A7%D9%84%D8%AD%D9%8A%D9%88%D8%A7%D9%86%D9%8A%D8%A9.jpg?alt=media&token=f259b7af-4415-429d-ab35-c4df81faaa1e'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.guide);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' الهيئة العامة للخدمات البيطرية',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/anaam%2F22-%20%D8%A7%D9%84%D9%87%D9%8A%D8%A6%D8%A9%20%D8%A7%D9%84%D8%B9%D8%A7%D9%85%D8%A9%20%D9%84%D9%84%D8%AE%D8%AF%D9%85%D8%A7%D8%AA%20%D8%A7%D9%84%D8%A8%D9%8A%D8%B7%D8%B1%D9%8A%D8%A9.jpg?alt=media&token=bc3a2624-4859-48a9-a13c-c6f284d15880'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.guide);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' الإدارة العامة لصحة الحيوان ',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/anaam%2F23-%20%D8%A7%D9%84%D8%A5%D8%AF%D8%A7%D8%B1%D8%A9%20%D8%A7%D9%84%D8%B9%D8%A7%D9%85%D8%A9%20%D9%84%D8%B5%D8%AD%D8%A9%20%D8%A7%D9%84%D8%AD%D9%8A%D9%88%D8%A7%D9%86%20%D9%88%D8%A7%D9%84%D9%88%D9%82%D8%A7%D9%8A%D8%A9%20%D9%85%D9%86%20%D8%A7%D9%84%D8%A3%D9%88%D8%A8%D8%A6%D8%A9.jpg?alt=media&token=bd40d5dc-7217-4ff2-8bb1-2b56c810c234'),
                                  ),

                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.guide);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' إدارة الإنتاج الحيواني',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/anaam%2F26-%20%D8%A5%D8%AF%D8%A7%D8%B1%D8%A9%20%D8%A7%D9%84%D8%A5%D9%86%D8%AA%D8%A7%D8%AC%20%D8%A7%D9%84%D8%AD%D9%8A%D9%88%D8%A7%D9%86%D9%8A.jpg?alt=media&token=a2b85ce8-4d03-44b2-92c4-59a306242e16'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.guide);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' الجهاز القومي للمواصفات والمقاييس',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/anaam%2F24-%20%D8%A7%D9%84%D8%AC%D9%87%D8%A7%D8%B2%20%D8%A7%D9%84%D9%82%D9%88%D9%85%D9%8A%20%D9%84%D9%84%D9%85%D9%88%D8%A7%D8%B5%D9%81%D8%A7%D8%AA%20%D9%88%D8%A7%D9%84%D9%85%D9%82%D8%A7%D9%8A%D9%8A%D8%B3.jpg?alt=media&token=19045ebc-2160-4383-bb15-bdb12ff51220'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.guide);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' هيئة البحوث الزراعية – قسم بحوث الحيوان',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/anaam%2F25-%20%D9%87%D9%8A%D8%A6%D8%A9%20%D8%A7%D9%84%D8%A8%D8%AD%D9%88%D8%AB%20%D8%A7%D9%84%D8%B2%D8%B1%D8%A7%D8%B9%D9%8A%D8%A9.jpg?alt=media&token=2c9290a8-3891-45c0-bbe4-b1b4a73b632f'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 5,
                      ),

                      //section 2
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (section2)
                              section2 = false;
                            else
                              section2 = true;
                          });
                        },
                        child: title_card('التراخيص والإجراءات الولائية', section2,"https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/enjaz%2F%D8%AA%D9%88%D9%82%D9%8A%D8%B9%20%D8%B9%D9%82%D9%88%D8%AF%20%D8%A7%D9%84%D8%A7%D9%8A%D8%AC%D8%A7%D8%B1.png?alt=media&token=83b94bf3-c2d2-4f7d-9171-8b7035893a47"),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (section2)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: [
                                  // The Card
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' ولاية الخرطوم ',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/anaam%2F27-%20%D9%88%D9%84%D8%A7%D9%8A%D8%A9%20%D8%A7%D9%84%D8%AE%D8%B1%D8%B7%D9%88%D9%85.jpg?alt=media&token=d0efc361-f078-4e94-8b4c-1d7e3c7ce95b'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' ولاية نهر النيل ',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F24-%20%D9%88%D9%84%D8%A7%D9%8A%D8%A9%20%D9%86%D9%87%D8%B1%20%D8%A7%D9%84%D9%86%D9%8A%D9%84.jpg?alt=media&token=891f465f-c402-478b-9dd4-914a0073bf1e'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' ولاية البحر الأحمر',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F%D9%88%D9%84%D8%A7%D9%8A%D8%A9%20%D8%A7%D9%84%D8%A8%D8%AD%D8%B1%20%D8%A7%D9%84%D8%A3%D8%AD%D9%85%D8%B1.jpg?alt=media&token=eebaa313-ff1e-4786-95c9-0ae9d84d2ae1'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.guide);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' الولاية الشمالية ',
                                        url: 'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F25-%20%D8%A7%D9%84%D9%88%D9%84%D8%A7%D9%8A%D8%A9%20%D8%A7%D9%84%D8%B4%D9%85%D8%A7%D9%84%D9%8A%D8%A9.jpg?alt=media&token=f37b37fb-18a3-4ce4-be0c-b6a629302fe7'),
                                  ),


                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.soon);
                                    },
                                    child: custom_card_Item(
                                        context,
                                        ' ولاية جنوب كردفان',
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F27-%20%D8%AC%D9%86%D9%88%D8%A8%20%D9%83%D8%B1%D8%AF%D9%81%D8%A7%D9%86.jpg?alt=media&token=594f29b1-d055-4b72-bc0b-f1261bea0d89'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.soon);
                                    },
                                    child: custom_card_Item(
                                        context,
                                        '  ولاية سنار ',
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/anaam%2F28-%20%D9%88%D9%84%D8%A7%D9%8A%D8%A9%20%D8%B3%D9%86%D8%A7%D8%B1.jpg?alt=media&token=96431474-4971-45ac-a94c-6b7b8428af3f'),
                                  ),

                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.soon);
                                    },
                                    child: custom_card_Item(
                                        context,
                                        '  النيل الأزرق ',
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F28-%20%D9%88%D9%84%D8%A7%D9%8A%D8%A9%20%D8%A7%D9%84%D9%86%D9%8A%D9%84%20%D8%A7%D9%84%D8%A7%D8%B2%D8%B1%D9%82.jpg?alt=media&token=43f08a80-8b20-4008-8a55-ded5c09a507b'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.soon);
                                    },
                                    child: custom_card_Item(
                                        context,
                                        'ولايات دارفور ',
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F29-%20%D9%88%D9%84%D8%A7%D9%8A%D8%A7%D8%AA%20%D8%AF%D8%A7%D8%B1%D9%81%D9%88%D8%B1.jpg?alt=media&token=e1690cf1-9f4a-4a5b-9095-a0b15b80e121'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 5,
                      ),

                      //secation 3
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (section3)
                              section3 = false;
                            else
                              section3 = true;
                          });
                        },
                        child: title_card('  قسم الجمارك والتراخيص المرورية', section3,"https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/enjaz%2F%D8%AA%D8%AC%D9%87%D9%8A%D8%B2%20%D9%85%D8%B9%D8%AF%20%D9%88%D8%AA%D8%B3%D9%84%D9%8A%D9%85%D9%87%D8%A7.png?alt=media&token=6ab7e53d-6dc2-4b09-aef4-0f35b6374f45"),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (section3)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: [
                                  // The Card
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.guide);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' هيئة الجمارك السودانية ',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F30-%20%D9%87%D9%8A%D8%A6%D8%A9%20%D8%A7%D9%84%D8%AC%D9%85%D8%A7%D8%B1%D9%83.jpg?alt=media&token=e55c4d3f-e574-4c7e-ace5-cbb74bc38ef3'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' هيئة المواني البحرية ',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F31-%20%D9%87%D9%8A%D8%A6%D8%A9%20%D8%A7%D9%84%D9%85%D9%88%D8%A7%D9%86%D8%A6%20%D8%A7%D9%84%D8%A8%D8%AD%D8%B1%D9%8A%D8%A9.jpg?alt=media&token=7a0a6211-e999-438c-b361-8bb8fb2a1d94'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' شرطة المرور العامة ',
                                        url: 'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F32-%20%D8%B4%D8%B1%D8%B7%D8%A9%20%D8%A7%D9%84%D9%85%D8%B1%D9%88%D8%B1%20%D8%A7%D9%84%D8%B9%D8%A7%D9%85%D9%87.jpg?alt=media&token=54db6205-cbb4-4727-8b44-4d404c0a4e59'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 5,
                      ),

                      //section 4
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (section4)
                              section4 = false;
                            else
                              section4 = true;
                          });
                        },
                        child:
                            title_card(' العمل والتأمينات الاجتماعية', section4,"https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/enjaz%2F%D8%AA%D8%B4%D8%BA%D9%8A%D9%84%20%D8%A7%D9%84%D9%85%D8%B9%D8%AF%D8%A7%D8%AA%20%D9%81%D9%8A%20%D8%A7%D9%84%D9%85%D9%88%D9%82%D8%B9.png?alt=media&token=c878bc32-5137-46c1-a3ea-2ed74f00f12d"),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (section4)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: [
                                  // The Card
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' مكتب العمل المركزي ',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F33-%20%D9%85%D9%83%D8%AA%D8%A8%20%D8%A7%D9%84%D8%B9%D9%85%D9%84%20%D8%A7%D9%84%D9%85%D8%B1%D9%83%D8%B2%D9%8A.jpg?alt=media&token=90a1ad67-e167-4698-96b1-7c050eb826d6'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' مكاتب العمل بالولايات ',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F33-%20%D9%85%D9%83%D8%AA%D8%A8%20%D8%A7%D9%84%D8%B9%D9%85%D9%84%20%D8%A7%D9%84%D9%85%D8%B1%D9%83%D8%B2%D9%8A.jpg?alt=media&token=90a1ad67-e167-4698-96b1-7c050eb826d6'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' الهيئة القومية للتأمينات الاجتماعية ',
                                        url: 'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F34-%20%D8%A7%D9%84%D9%87%D9%8A%D8%A6%D8%A9%20%D8%A7%D9%84%D9%82%D9%88%D9%85%D9%8A%D8%A9%20%D9%84%D9%84%D8%AA%D8%A3%D9%85%D9%8A%D9%86%D8%A7%D8%AA%20%D8%A7%D9%84%D8%A5%D8%AC%D8%AA%D9%85%D8%A7%D8%B9%D9%8A%D8%A9.jpg?alt=media&token=ab0c94ee-5cc0-4f29-aebb-a27eac4502dc'),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 5,
                      ),

                      ///section 5
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (section5)
                              section5 = false;
                            else
                              section5 = true;
                          });
                        },
                        child: title_card('الإجراءات البنكية', section5,"https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/enjaz%2F%D8%B5%D9%8A%D8%A7%D9%86%D8%A9%20%D8%A7%D9%84%D9%85%D8%B9%D8%AF%D8%A7%D8%AA.png?alt=media&token=9a420a25-4ffe-43ef-8b90-fb66219733f2"),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (section5)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: [
                                  // The Card
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' بنك السودان المركزي ',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F35-%20%D8%A8%D9%86%D9%83%20%D8%A7%D9%84%D8%B3%D9%88%D8%AF%D8%A7%D9%86%20%D8%A7%D9%84%D9%85%D8%B1%D9%83%D8%B2%D9%8A.jpg?alt=media&token=22cd3214-3292-423c-81f5-9e993b9bd5e4'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' بنك الخرطوم ',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F36-%20%D8%A8%D9%86%D9%83%20%D8%A7%D9%84%D8%AE%D8%B1%D8%B7%D9%88%D9%85.jpg?alt=media&token=671f716c-5ca0-47b4-9e7c-b2065ca92d8d'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' بنك النيلين ',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F37-%20%D8%A8%D9%86%D9%83%20%D8%A7%D9%84%D9%86%D9%8A%D9%84%D9%8A%D9%86.jpg?alt=media&token=5c4dcb63-db13-4879-b06d-1091748baca3'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.soon);
                                    },
                                    child: custom_card_Item(
                                        context,
                                        ' بنك فيصل ',
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F38-%20%D8%A8%D9%86%D9%83%20%D9%81%D9%8A%D8%B5%D9%84.jpg?alt=media&token=0eec7be5-0030-468a-9ff1-cf3233eeda3d'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.soon);
                                    },
                                    child: custom_card_Item(
                                        context,
                                        ' بنك امدرمان ',
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F39-%20%D8%A8%D9%86%D9%83%20%D8%A7%D9%85%D8%AF%D8%B1%D9%85%D8%A7%D9%86.jpg?alt=media&token=464fd11d-8de6-486c-a182-0e8416bede8a'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.soon);
                                    },
                                    child: custom_card_Item(
                                        context,
                                        'بنك الثروة الحيوانية',
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F39-%20%D8%A8%D9%86%D9%83%20%D8%A7%D9%85%D8%AF%D8%B1%D9%85%D8%A7%D9%86.jpg?alt=media&token=464fd11d-8de6-486c-a182-0e8416bede8a'),
                                  ),


                                ],
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 5,
                      ),

                      //section 6
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (section6)
                              section6 = false;
                            else
                              section6 = true;
                          });
                        },
                        child: title_card('قسم شركات التأمين', section6,"https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/enjaz%2F%D8%AA%D9%88%D9%81%D9%8A%D8%B1%20%D9%82%D8%B7%D8%B9%20%D8%A7%D9%84%D8%BA%D9%8A%D8%A7%D8%B1.png?alt=media&token=9e024c50-e1e5-4e15-961d-0346ba9d5566"),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      if (section6)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                children: [
                                  // The Card
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: 'شركة شيكان للتأمين',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F40-%20%D8%B4%D8%B1%D9%83%D8%A9%20%D8%B4%D9%8A%D9%83%D8%A7%D9%86%20%D9%84%D9%84%D8%AA%D8%A3%D9%85%D9%8A%D9%86.jpg?alt=media&token=d3083e0c-32d7-4a24-a7b4-5c54c7dd03ee'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, Routes.soon);
                                    },
                                    child: GoldShimmerCard(
                                        title: 'الشركة التعاونية للتأمين',
                                        url:
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F41-%20%D8%A7%D9%84%D8%B4%D8%B1%D9%83%D8%A9%20%D8%A7%D9%84%D8%AA%D8%B9%D8%A7%D9%88%D9%86%D9%8A%D8%A9%20%D9%84%D9%84%D8%AA%D8%A7%D9%85%D9%8A%D9%86.jpg?alt=media&token=74f3dddb-27e7-4900-bc58-b6aa9fb3864b'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.guide);
                                    },
                                    child: GoldShimmerCard(
                                        title: ' شركة النيلين للتأمين ',
                                        url: 'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F42-%20%D8%A7%D9%84%D9%86%D9%8A%D9%84%D9%8A%D9%86%20%D9%84%D9%84%D8%AA%D8%A7%D9%85%D9%8A%D9%86.jpg?alt=media&token=061a77cc-eeae-4980-b568-2a0735c6b4dc'),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.soon);
                                    },
                                    child: custom_card_Item(
                                        context,
                                        ' شركة البركة للتأمين ',
                                        'https://firebasestorage.googleapis.com/v0/b/miningmarket-firebase.appspot.com/o/Bareeq%2F43-%20%D8%A7%D9%84%D8%A8%D8%B1%D9%83%D8%A9%20%D9%84%D9%84%D8%AA%D8%A7%D9%85%D9%8A%D9%86.jpg?alt=media&token=2c69f94f-5eb2-4b8d-ba58-b22525058a50'),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5,)

                            ],
                          ),
                        ),
                      SizedBox(
                        height: 5,
                      ),



                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container title_card(String title, bool section,String url ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 13),
      width: double.infinity,
      height: 100,
      padding: EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
      decoration: BoxDecoration(
        color: context.color.mainColor,
        // image: DecorationImage(
        //   image: AssetImage(AppIcons.categoryBg),
        //   fit: BoxFit.fill,
        // ),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x33000000),
            offset: Offset(
              0,
              2,
            ),
          )
        ],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white,
          width: 6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  section ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black,
                  weight: 8,
                  size: 35,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title ?? "",
                  fontSize: 16,
                  textAlign: TextAlign.right,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentDirectional(0, 1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: UiUtils.imageType(
                    url,
                    width: 60,
                    height: 55,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget appbarTitleWidget() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(Constant.appName,
              fontSize: context.font.large,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          //UiUtils.getSvg(AppIcons.appbarLogo, height: 40, width: 40 ,fit: BoxFit.cover ),
        ]);
  }

  Widget appbarIconWidget(IconData icon, Function callback) {
    return Container(
      width: 35,
      margin: EdgeInsets.only(top: 5,bottom: 5 , right: 3),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(50)),
      child: IconButton(
          onPressed: () {
            callback();
          },
          icon: Icon(
            icon,size: 20,color: context.color.mainBrown,
          )),
    );
  }

  List<Widget> appbarActionsWidget() {
    return [
      Padding(
        padding: EdgeInsets.only(top: 5 , left: 2, bottom: 5),
        child: appbarIconWidget(Icons.favorite_border, () {
          UiUtils.checkUser(
              onNotGuest: () {
                Navigator.pushNamed(context, Routes.favoritesScreen);
              },
              context: context);
        }),
      ),
      Padding(
        padding:  EdgeInsets.only(top: 5 , left: 2, bottom: 5),
        child: appbarIconWidget(Icons.search, () {
          Navigator.pushNamed(context, Routes.searchScreenRoute, arguments: {
            "autoFocus": true,
          });
        }),
      ),
      Padding(
        padding:  EdgeInsets.only(top: 5 , left: 10, bottom: 5),
        child: appbarIconWidget(Icons.notifications_active_outlined, () {
          UiUtils.checkUser(
              onNotGuest: () {
                Navigator.pushNamed(context, Routes.notificationPage);
              },
              context: context);
        }),
      ),
      // appbarIconWidget(Icons.person_2_outlined, () {
      //   Navigator.pushNamed(context, Routes.profileScreen );
      // }),
    ];
  }

  Widget blogMarqueeWidget() {
    return BlocBuilder<FetchBlogsCubit, FetchBlogsState>(
        builder: (context, state) {
      if (state is FetchBlogsSuccess) {
        String mergedTitle = state.blogModel.map((e) => e.title).join('\t\t\t');
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.blogsScreenRoute,
            );
          },
          child: Container(
            color: Color(0xff2364c5),
            padding: EdgeInsetsDirectional.symmetric(vertical: 5),
            child: MarqueeText(
              text: mergedTitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.white),
              velocity: 50,
            ),
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  Container custom_card_Item(BuildContext context, String title, String url) {
    return Container(
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: UiUtils.imageType(
               url,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 1), // أسود شبه شفاف في الأسفل
                    ],
                  ),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: context.font.smaller,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container the_gold_sec(String title) {
    bool expand = true;
    return Container(
        child: Column(children: [
      InkWell(
        onTap: () {
          if (expand)
            setState(() {
              expand = false;
            });
          else
            setState(() {
              expand = true;
            });
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 13),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppIcons.categoryBg),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                expand ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
              Expanded(
                child: CustomText(
                  title,
                  // item.name ?? "",
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                expand ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 10),
      if (expand)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  // The Card
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(
                      context,
                        'المسجل التجاري',
                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/23dwc45aegqv/8_copy.jpg'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(
                      context ,
                      ' وزارة الإستثمار ',

                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/8iy777zlezzx/9_copy.jpg'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(
                      context,
                       '   وزارة المعادن ',
                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/kqgp4p9tgsdw/10_copy.jpg'),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(context, ' الابحاث الجيلوجية ',
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/fu508h0w64cp/11_copy.jpg'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(context, ' الولايات والمحاليات  ',
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/irp2v834y4x6/12_copy.jpg'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(
                        context,
                        ' المالية والتخطيط الأقتصادي  ',
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/mina24dtpbp3/13_copy.jpg'),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(context, ' هيئة الجمارك ',
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/pxyx3p1md655/14_copy.jpg'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(context, ' وزارة التجارة ',
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/vq8ys7favedu/15_copy.jpg'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(context, ' مكتب العمل ',
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/a5ozl80fvqk4/16_copy.jpg'),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(context, 'وزارة العدل ',
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/aqm2fk2oi1cm/17_copy.jpg'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(context, ' التأمينات الإجتماعية ',
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/6iqubtvxmlic/18_copy.jpg'),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.guide);
                    },
                    child: custom_card_Item(context, ' شركات التأمين ',
                        'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/80k6u2xj7rn9/19_copy.jpg'),
                  ),
                ],
              ),
            ],
          ),
        ),
    ]));
  }
}

Future<void> notificationPermissionChecker() async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}

class GoldSection extends StatefulWidget {
  final String title;

  GoldSection({required this.title});

  @override
  _GoldSectionState createState() => _GoldSectionState();
}

class _GoldSectionState extends State<GoldSection> {
  bool expand = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expand = !expand;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 13),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppIcons.categoryBg),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    expand
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: CustomText(
                      widget.title,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    expand
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          if (expand)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.guide);
                        },
                        child: GoldShimmerCard(
                          title: 'المسجل التجاري',
                          url:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/mining-market-firebase-ym2dfj/assets/23dwc45aegqv/8_copy.jpg',
                        ),
                      ),
                      // باقي العناصر كما هي...
                      // نسخ كل InkWell والباقي كما هو عندك
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
