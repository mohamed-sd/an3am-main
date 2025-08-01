// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:an3am/app/routes.dart';
import 'package:an3am/data/cubits/chat/delete_message_cubit.dart';
import 'package:an3am/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:an3am/data/cubits/chat/load_chat_messages.dart';
import 'package:an3am/data/cubits/chat/make_an_offer_item_cubit.dart';
import 'package:an3am/data/cubits/chat/send_message.dart';
import 'package:an3am/data/cubits/favorite/favorite_cubit.dart';
import 'package:an3am/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:an3am/data/cubits/item/change_my_items_status_cubit.dart';
import 'package:an3am/data/cubits/item/create_featured_ad_cubit.dart';
import 'package:an3am/data/cubits/item/delete_item_cubit.dart';
import 'package:an3am/data/cubits/item/fetch_item_from_slug_cubit.dart';
import 'package:an3am/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:an3am/data/cubits/item/item_total_click_cubit.dart';
import 'package:an3am/data/cubits/item/related_item_cubit.dart';
import 'package:an3am/data/cubits/renew_item_cubit.dart';
import 'package:an3am/data/cubits/report/fetch_item_report_reason_list.dart';
import 'package:an3am/data/cubits/report/item_report_cubit.dart';
import 'package:an3am/data/cubits/report/update_report_items_list_cubit.dart';
import 'package:an3am/data/cubits/safety_tips_cubit.dart';
import 'package:an3am/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:an3am/data/cubits/subscription/fetch_ads_listing_subscription_packages_cubit.dart';
import 'package:an3am/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:an3am/data/helper/widgets.dart';
import 'package:an3am/data/model/chat/chat_user_model.dart';
import 'package:an3am/data/model/item/item_model.dart';
import 'package:an3am/data/model/report_item/reason_model.dart';
import 'package:an3am/data/model/safety_tips_model.dart';
import 'package:an3am/data/model/subscription_package_model.dart';
import 'package:an3am/ui/screens/ad_banner_screen.dart';
import 'package:an3am/ui/screens/chat/chat_screen.dart';
import 'package:an3am/ui/screens/google_map_screen.dart';
import 'package:an3am/ui/screens/navigations/home_screen.dart';
import 'package:an3am/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:an3am/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:an3am/ui/screens/subscription/widget/featured_ads_subscription_plan_item.dart';
import 'package:an3am/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:an3am/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:an3am/ui/screens/widgets/errors/no_data_found.dart';
import 'package:an3am/ui/screens/widgets/errors/no_internet.dart';
import 'package:an3am/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:an3am/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:an3am/ui/screens/widgets/video_view_screen.dart';
import 'package:an3am/ui/theme/theme.dart';
import 'package:an3am/utils/api.dart';
import 'package:an3am/utils/app_icon.dart';
import 'package:an3am/utils/cloud_state/cloud_state.dart';
import 'package:an3am/utils/constant.dart';
import 'package:an3am/utils/custom_text.dart';
import 'package:an3am/utils/extensions/extensions.dart';
import 'package:an3am/utils/extensions/lib/currency_formatter.dart';
import 'package:an3am/utils/helper_utils.dart';
import 'package:an3am/utils/hive_utils.dart';
import 'package:an3am/utils/ui_utils.dart';
import 'package:an3am/utils/validator.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AdDetailsScreen extends StatefulWidget {
  final ItemModel? model;
  final String? slug;
  const AdDetailsScreen({
    super.key,
    this.model,
    this.slug,
  });

  @override
  AdDetailsScreenState createState() => AdDetailsScreenState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => FetchMyItemsCubit(),
            ),
            BlocProvider(
              create: (context) => CreateFeaturedAdCubit(),
            ),
            BlocProvider(
              create: (context) => FetchItemReportReasonsListCubit(),
            ),
            BlocProvider(
              create: (context) => ItemReportCubit(),
            ),
            BlocProvider(
              create: (context) => MakeAnOfferItemCubit(),
            ),
            BlocProvider(create: (context) => FetchItemFromSlugCubit())
          ],
          child: AdDetailsScreen(
            model: arguments?['model'],
            slug: arguments?['slug'],
            // from: arguments?['from'],
          ),
        ));
  }
}

class AdDetailsScreenState extends CloudState<AdDetailsScreen> {
  //ImageView
  int _rating = 4;
  int currentPage = 0;
  bool? isFeaturedLimit;
  List<String> selectedFeaturedAdsOptions = [];

  bool isShowReportAds = true;
  final PageController pageController = PageController();
  final List<String?> images = [];
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  late final ScrollController _pageScrollController = ScrollController();
  List<ReportReason>? reasons = [];
  late int selectedId;
  final TextEditingController _reportmessageController =
  TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _makeAnOffermessageController =
  TextEditingController();
  final GlobalKey<FormState> _offerFormKey = GlobalKey();
  int? _selectedPackageIndex;

  late ItemModel model;

  late bool isAddedByMe;
  bool isFeaturedWidget = true;
  String youtubeVideoThumbnail = "";
  int? categoryId;
  FlickManager? flickManager;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      initVariables(widget.model!);
    }
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
      });
    });
    _pageScrollController.addListener(_pageScroll);
  }

  void initVariables(ItemModel itemModel) {
    model = itemModel;

    isAddedByMe =
        (model.user?.id != null ? model.user!.id.toString() : model.userId) ==
            HiveUtils.getUserId();

    if (!isAddedByMe) {
      context.read<FetchItemReportReasonsListCubit>().fetch();
      context.read<FetchSafetyTipsListCubit>().fetchSafetyTips();
      context.read<FetchSellerRatingsCubit>().fetch(
          sellerId: (model.user?.id != null ? model.user!.id! : model.userId!));
    } else {
      context.read<FetchAdsListingSubscriptionPackagesCubit>().fetchPackages();
    }
    categoryId = model.category != null ? model.category?.id : model.categoryId;

    setItemClick();
    //ImageView
    combineImages();
    context.read<FetchRelatedItemsCubit>().fetchRelatedItems(
        categoryId: categoryId!,
        city: HiveUtils.getCityName(),
        areaId: HiveUtils.getAreaId(),
        country: HiveUtils.getCountryName(),
        state: HiveUtils.getStateName());
    _pageScrollController.addListener(_pageScroll);
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchRelatedItemsCubit>().hasMoreData()) {
        context.read<FetchRelatedItemsCubit>().fetchRelatedItemsMore(
            categoryId: categoryId!,
            city: HiveUtils.getCityName(),
            areaId: HiveUtils.getAreaId(),
            country: HiveUtils.getCountryName(),
            state: HiveUtils.getStateName());
      }
    }
  }

  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      model.latitude ?? 0,
      model.longitude ?? 0,
    ),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    super.dispose();
  }

  void combineImages() {
    images.add(model.image);
    if (model.galleryImages != null && model.galleryImages!.isNotEmpty) {
      for (var element in model.galleryImages!) {
        images.add(element.image);
      }
    }

    if (model.videoLink != null && model.videoLink!.isNotEmpty) {
      images.add(model.videoLink);
    }

    if (model.videoLink != "" &&
        model.videoLink != null &&
        !HelperUtils.isYoutubeVideo(model.videoLink ?? "")) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(model.videoLink!),
        ),
      );
      flickManager?.onVideoEnd = () {};
    }
    if (model.videoLink != "" &&
        model.videoLink != null &&
        HelperUtils.isYoutubeVideo(model.videoLink ?? "")) {
      String? videoId = YoutubePlayer.convertUrlToId(model.videoLink!);
      if (videoId != null) {
        String thumbnail = YoutubePlayer.getThumbnail(videoId: videoId);

        youtubeVideoThumbnail = thumbnail;
      }
    }
  }

  void setItemClick() {
    if (!isAddedByMe) {
      context.read<ItemTotalClickCubit>().itemTotalClick(model.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: context.color.secondaryDetailsColor,
        ),
        child: BlocConsumer<FetchItemFromSlugCubit, FetchItemFromSlugState>(
            listener: (context, state) {
              if (state is FetchItemFromSlugSuccess) {
                log('success');
                initVariables(state.item);
              }
            }, builder: (context, state) {
          if (state is FetchItemFromSlugInitial && widget.slug != null) {
            context
                .read<FetchItemFromSlugCubit>()
                .fetchItemFromSlug(slug: widget.slug!);
            log('fetching item');
            return Material(
              child: Center(
                child: UiUtils.progress(),
              ),
            );
          } else if (state is FetchItemFromSlugLoading) {
            log('loading');
            return Material(
              child: Center(
                child: UiUtils.progress(),
              ),
            );
          } else if (state is FetchItemFromSlugFailure) {
            log('failure');
            return SomethingWentWrong();
          }
          return BlocListener<MakeAnOfferItemCubit, MakeAnOfferItemState>(
            listener: (context, state) {
              if (state is MakeAnOfferItemInProgress) {
                Widgets.showLoader(context);
              }
              if (state is MakeAnOfferItemSuccess ||
                  state is MakeAnOfferItemFailure) {
                Widgets.hideLoder(context);
              }
            },
            child: Scaffold(
              appBar: UiUtils.buildAppBar(
                context,
                title: "تفاصيل إعلان / خدمة ",
                backgroundColor: context.color.mainBrown,
                showBackButton: true,
                actions: [
                  if (isAddedByMe && model.status == "active" ||
                      model.status == 'approved')
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          end: isAddedByMe &&
                              (model.status != "sold out" &&
                                  model.status != "review" &&
                                  model.status != "inactive" &&
                                  model.status != "rejected")
                              ? 30.0
                              : 15),
                      child: IconButton(
                        onPressed: () {
                          HelperUtils.shareItem(context, model.slug!, '');
                        },
                        icon: Icon(
                          Icons.share,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (isAddedByMe &&
                      (model.status != "sold out" &&
                          model.status != "review" &&
                          model.status != "inactive" &&
                          model.status != "rejected"))
                    MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => DeleteItemCubit(),
                        ),
                        BlocProvider(
                          create: (context) => ChangeMyItemStatusCubit(),
                        ),
                      ],
                      child: Builder(builder: (context) {
                        return BlocListener<DeleteItemCubit, DeleteItemState>(
                          listener: (context, deleteState) {
                            if (deleteState is DeleteItemSuccess) {
                              HelperUtils.showSnackBarMessage(context,
                                  "deleteItemSuccessMsg".translate(context));
                              context
                                  .read<FetchMyItemsCubit>()
                                  .deleteItem(model);
                              Navigator.pop(context, "refresh");
                            } else if (deleteState is DeleteItemFailure) {
                              HelperUtils.showSnackBarMessage(
                                  context, deleteState.errorMessage);
                            }
                          },
                          child: BlocListener<ChangeMyItemStatusCubit,
                              ChangeMyItemStatusState>(
                            listener: (context, changeState) {
                              if (changeState is ChangeMyItemStatusSuccess) {
                                HelperUtils.showSnackBarMessage(
                                    context, changeState.message);
                                Navigator.pop(context, "refresh");
                              } else if (changeState
                              is ChangeMyItemStatusFailure) {
                                HelperUtils.showSnackBarMessage(
                                    context, changeState.errorMessage);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(end: 30.0),
                              child: Container(
                                height: 24,
                                width: 24,
                                alignment: AlignmentDirectional.center,
                                child: PopupMenuButton(
                                  color: context.color.mainBrown,
                                  offset: Offset(-12, 15),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(17),
                                      bottomRight: Radius.circular(17),
                                      topLeft: Radius.circular(17),
                                      topRight: Radius.circular(0),
                                    ),
                                  ),
                                  child: SvgPicture.asset(
                                    AppIcons.more,
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    colorFilter: ColorFilter.mode(
                                        context.color.textDefaultColor,
                                        BlendMode.srcIn),
                                  ),
                                  itemBuilder: (context) => [
                                    if (model.status == "active" ||
                                        model.status == "approved")
                                      PopupMenuItem(
                                          onTap: () {
                                            Future.delayed(Duration.zero, () {
                                              context
                                                  .read<
                                                  ChangeMyItemStatusCubit>()
                                                  .changeMyItemStatus(
                                                  id: model.id!,
                                                  status: 'inactive');
                                            });
                                          },
                                          child: CustomText(
                                            "deactivate".translate(context),
                                            color: context.color.buttonColor,
                                          )),
                                    if (model.status == "active" ||
                                        model.status == "approved")
                                      PopupMenuItem(
                                        child: CustomText(
                                          "lblremove".translate(context),
                                          color: context.color.buttonColor,
                                        ),
                                        onTap: () async {
                                          var delete =
                                          await UiUtils.showBlurredDialoge(
                                            context,
                                            dialoge: BlurredDialogBox(
                                              title: "deleteBtnLbl"
                                                  .translate(context),
                                              content: CustomText(
                                                "deleteitemwarning"
                                                    .translate(context),
                                              ),
                                            ),
                                          );
                                          if (delete == true) {
                                            Future.delayed(
                                              Duration.zero,
                                                  () {
                                                context
                                                    .read<DeleteItemCubit>()
                                                    .deleteItem(model.id!);
                                              },
                                            );
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              ),
              backgroundColor: context.color.mainColor,
              bottomNavigationBar: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: bottomButtonWidget()),
              body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13.0, 0.0, 13.0, 13.0),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        // User Title
                        Padding(
                          padding:
                          EdgeInsetsDirectional.fromSTEB(10, 20, 10, 5),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: context.color.mainGold,
                                borderRadius: BorderRadius.circular(16)),
                            child: Text(
                              model.name!,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        // User Image Slider
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2),
                                      blurStyle: BlurStyle.normal),
                                ]),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Stack(children: [
                                    setImageViewer(),
                                    Opacity(
                                      opacity: 0.9,
                                      child: Align(
                                        alignment: AlignmentDirectional(1, -1),
                                        child: Padding(
                                          padding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              30, 15, 10, 0),
                                          child: Container(
                                            width: 70,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(2, 0, 2, 0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        3, 0, 3, 0),
                                                    child: Row(
                                                      mainAxisSize:
                                                      MainAxisSize.max,
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .remove_red_eye_outlined,
                                                          color:
                                                          Color(0xFF5C5C5C),
                                                          size: 20,
                                                        ),
                                                        Text(
                                                          model.views != null
                                                              ? model.views!
                                                              .toString()
                                                              : "0",
                                                          textAlign:
                                                          TextAlign.center,
                                                          style: TextStyle(
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ]),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: context.color.mainGold,
                                                borderRadius:
                                                BorderRadius.circular(12)),
                                            child: Text(
                                              model.price!.currencyFormat,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: context.color.mainGold,
                                                borderRadius:
                                                BorderRadius.circular(12)),
                                            child: Text(
                                              model.created!.formatDate(
                                                  format: "d MMM yyyy"),
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      10, 0, 10, 10),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(3),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children:
                                              List.generate(5, (index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _rating = index + 1;
                                                    });
                                                  },
                                                  child: Icon(
                                                    index < _rating
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: Colors.amber,
                                                    size: 20,
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),

                                          // Padding(
                                          //   padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                                          //   child: RatingBar.builder(
                                          //     onRatingUpdate: (newValue) =>
                                          //         safeSetState(() => _model.ratingBarValue = newValue),
                                          //     itemBuilder: (context, index) => Icon(
                                          //       FFIcons.k12,
                                          //       color: FlutterFlowTheme.of(context).buttonApp,
                                          //     ),
                                          //     direction: Axis.horizontal,
                                          //     initialRating: _model.ratingBarValue ??= 4,
                                          //     unratedColor: FlutterFlowTheme.of(context).boederColor,
                                          //     itemCount: 5,
                                          //     itemPadding: EdgeInsets.all(2),
                                          //     itemSize: 15,
                                          //     glowColor: FlutterFlowTheme.of(context).buttonApp,
                                          //   ),
                                          // ),
                                          Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment:
                                              AlignmentDirectional(0, 0),
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(5, 0, 5, 0),
                                                child: Text(
                                                  '139 تقييم',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 140,
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(10, 0, 10, 0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(3),
                                                    child: Text(
                                                      'عرض جمييع التقييمات',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        letterSpacing: 0.0,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // User Detailes Container
                        if (!isAddedByMe && model.user != null)
                          Container(
                            padding: EdgeInsets.all(5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2),
                                      blurStyle: BlurStyle.normal),
                                ]),
                            child: Row(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: model.user!.profile != null &&
                                        model.user!.profile != ""
                                        ? UiUtils.getImage(model.user!.profile!,
                                        fit: BoxFit.fill)
                                        : UiUtils.getSvg(
                                      AppIcons.defaultPersonLogo,
                                      color: context.color.mainBrown,
                                      fit: BoxFit.none,
                                    )),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        margin:
                                        EdgeInsets.symmetric(horizontal: 5),
                                        width: double.infinity,
                                        padding:
                                        EdgeInsets.symmetric(vertical: 2),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            )),
                                        child: Text(
                                          model.user!.name!,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Container(
                                        margin:
                                        EdgeInsets.symmetric(horizontal: 5),
                                        width: double.infinity,
                                        padding:
                                        EdgeInsets.symmetric(vertical: 2),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            )),
                                        child: Text(
                                          model.user!.email!,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, Routes.sellerProfileScreen,
                                        arguments: {
                                          "sellerId": model.user?.id
                                        });
                                  },
                                  child: Container(
                                    width: 120,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 216, 215, 215),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          10, 0, 10, 0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text('حساب المعلن',
                                              style: TextStyle(
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                        SizedBox(
                          height: 10,
                        ),

                        // User Basic Info
                        if (model.customFields!.isNotEmpty)
                          Container(
                              padding: EdgeInsets.only(top: 10, bottom: 5),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                        offset: Offset(0, 2),
                                        blurStyle: BlurStyle.normal),
                                  ]),
                              child: Column(
                                children: [
                                  Container(
                                    margin:
                                    EdgeInsets.symmetric(horizontal: 10),
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: context.color.mainGold,
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    child: Text(
                                      'المعلومات الاساسية',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Container(
                                    child: Wrap(
                                        alignment: WrapAlignment.start,
                                        children: [
                                          ...List.generate(
                                              model.customFields!.length,
                                                  (index) {
                                                if (model.customFields![index]
                                                    .value!.isNotEmpty) {
                                                  return Container(
                                                    width:
                                                    MediaQuery.sizeOf(context)
                                                        .width *
                                                        .42,
                                                    margin: EdgeInsets.symmetric(
                                                        vertical: 5, horizontal: 5),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      border: Border.all(
                                                          color: Color.fromARGB(
                                                              255, 197, 195, 195),
                                                          width: 1),
                                                    ),
                                                    child: SizedBox(
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                  10,
                                                                  vertical: 5),
                                                              width:
                                                              double.infinity,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      10),
                                                                  color: Color
                                                                      .fromARGB(
                                                                      255,
                                                                      220,
                                                                      220,
                                                                      220)),
                                                              child: Text(
                                                                model
                                                                    .customFields![
                                                                index]
                                                                    .name
                                                                    .toString(),
                                                                textAlign: TextAlign
                                                                    .center,
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w800),
                                                              )),
                                                          Container(
                                                              width:
                                                              double.infinity,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                  5),
                                                              child: Text(
                                                                model
                                                                    .customFields![
                                                                index]
                                                                    .value
                                                                    .toString(),
                                                                textAlign: TextAlign
                                                                    .center,
                                                                style: TextStyle(
                                                                    fontSize: 12,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  );

                                                  // return Container(
                                                  //   margin: EdgeInsets.all(2),
                                                  //   padding: EdgeInsets.all(2),
                                                  //   child: DecoratedBox(
                                                  //     decoration: BoxDecoration(
                                                  //         border: Border.all(
                                                  //             color: Colors.red.withValues(alpha: 0.0))),
                                                  //     child: SizedBox(
                                                  //       width: MediaQuery.sizeOf(context).width * .40,
                                                  //       child: Row(
                                                  //         crossAxisAlignment: CrossAxisAlignment.start,
                                                  //         mainAxisSize: MainAxisSize.min,
                                                  //         children: [
                                                  //           Container(
                                                  //             height: 25,
                                                  //             width: 25,
                                                  //             alignment: Alignment.center,
                                                  //             child: UiUtils.imageType(
                                                  //                 model.customFields![index].image!,
                                                  //                 fit: BoxFit.contain),
                                                  //           ),
                                                  //           SizedBox(width: 7),
                                                  //           Column(
                                                  //             crossAxisAlignment: CrossAxisAlignment.start,
                                                  //             mainAxisSize: MainAxisSize.min,
                                                  //             children: [
                                                  //               Tooltip(
                                                  //                 message: model.customFields![index].name,
                                                  //                 child: CustomText(
                                                  //                     (model.customFields?[index].name) ?? "",
                                                  //                     maxLines: 1,
                                                  //                     fontSize: context.font.small,
                                                  //                     color: context.color.textLightColor),
                                                  //               ),
                                                  //               valueContent(
                                                  //                   model.customFields![index].value),
                                                  //               const SizedBox(
                                                  //                 height: 12,
                                                  //               )
                                                  //             ],
                                                  //           ),
                                                  //         ],
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                  // );
                                                } else {
                                                  return SizedBox();
                                                }
                                              }),
                                        ]),
                                  ),
                                ],
                              )),

                        SizedBox(
                          height: 10,
                        ),

                        // The Detailes
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5 , vertical: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                    offset: Offset(0, 2),
                                    blurStyle: BlurStyle.normal),
                              ]),
                          child:Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: context.color.mainGold,
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                child: Text(
                                  ' تفاصيل الإعلان ',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(top: 5),
                                padding: EdgeInsets.only(top: 0, right: 3, left: 3, bottom: 3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    )),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5 , horizontal: 5),
                                  child: Text(
                                      model.description!
                                  ),
                                ),
                              )
                            ],
                          ),
                        )

                        // Container(
                        //     padding: EdgeInsets.all(5),
                        //     width: double.infinity,
                        //     decoration: BoxDecoration(
                        //         color: Colors.white,
                        //         borderRadius: BorderRadius.circular(20),
                        //         boxShadow: [
                        //           BoxShadow(
                        //               color: Colors.grey,
                        //               blurRadius: 5,
                        //               spreadRadius: 1,
                        //               offset: Offset(0, 2),
                        //               blurStyle: BlurStyle.normal),
                        //         ]),
                        //   child : Row(
                        //     mainAxisSize: MainAxisSize.max,
                        //     children: [
                        //       // Padding(
                        //       //   padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                        //       //   child: ClipRRect(
                        //       //     borderRadius: BorderRadius.circular(8),
                        //       //     child: Image.asset(
                        //       //       'assets/profile.jpg',
                        //       //       width: 60,
                        //       //       height: 60,
                        //       //       fit: BoxFit.cover,
                        //       //     ),
                        //       //   ),
                        //       // ),
                        //       Expanded(
                        //         // flex: 2,
                        //         child: Column(
                        //           mainAxisSize: MainAxisSize.min,
                        //           children: [
                        //             Expanded(
                        //               child: Container(
                        //                 width: double.infinity,
                        //                 child: Column(
                        //                   mainAxisSize: MainAxisSize.max,
                        //                   children: [
                        //                     Expanded(
                        //                       child: Padding(
                        //                         padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 2),
                        //                         child: Text('طالب الخدمة')
                        //                       ),
                        //                     ),
                        //                     Expanded(
                        //                       child: Padding(
                        //                         padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                        //                         child: Text('130 إعلان')
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //       Padding(
                        //         padding: EdgeInsetsDirectional.fromSTEB(5, 5, 10, 5),
                        //         child: Container(
                        //           width: 120,
                        //           height: 60,
                        //           decoration: BoxDecoration(
                        //             color: Colors.grey,
                        //             borderRadius: BorderRadius.circular(10),
                        //           ),
                        //           child: Padding(
                        //             padding: EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                        //             child: Column(
                        //               mainAxisSize: MainAxisSize.max,
                        //               mainAxisAlignment: MainAxisAlignment.center,
                        //               children: [
                        //                 Text(
                        //                   'حساب المعلن',
                        //                   style: TextStyle(
                        //                     letterSpacing: 0.0,
                        //                     fontWeight: FontWeight.w500,
                        //                   )
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   )
                        // ),

                        // Old Data *********************************************************************
                        ,
                        // Container(
                        //   margin: EdgeInsets.only(top: 50),
                        //   padding: EdgeInsets.all(2),
                        //   width: double.infinity,
                        //   decoration: BoxDecoration(
                        //       color: context.color.mainGold,
                        //       borderRadius: BorderRadius.circular(16)),
                        //   child: Center(
                        //     child: Padding(
                        //         padding:
                        //             const EdgeInsets.symmetric(vertical: 10),
                        //         child: CustomText(
                        //           model.name!,
                        //           color: context.color.textDefaultColor,
                        //           fontSize: context.font.large,
                        //           maxLines: 2,
                        //           fontStyle: FontStyle.normal,
                        //         )),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 5,
                        // ),
                        // Container(
                        //   padding: EdgeInsets.all(10),
                        //   decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(16),
                        //       boxShadow: [
                        //         BoxShadow(
                        //             color: Colors.grey,
                        //             blurRadius: 5,
                        //             spreadRadius: 1,
                        //             offset: Offset(0, 2),
                        //             blurStyle: BlurStyle.normal),
                        //       ]),
                        //   child: Column(
                        //     children: [
                        //       setImageViewer(),
                        //       if (isAddedByMe) setLikesAndViewsCount(),
                        //       setPriceAndStatus(),
                        //       if (isAddedByMe) setRejectedReason(),
                        //       if (model.address != null)
                        //         setAddress(isDate: true),
                        //     ],
                        //   ),
                        // ),

                        // Divider(
                        //     thickness: 1,
                        //     color: context.color.textDefaultColor
                        //         .withValues(alpha: 0.1)),
                        // if (!isAddedByMe && model.user != null)
                        //   setSellerDetails(),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        if (Constant.isGoogleBannerAdsEnabled == "1") ...[
                          Container(
                            alignment: AlignmentDirectional.center,
                            child:
                            AdBannerWidget(), // Custom widget for banner ad
                          ),
                        ]else
                          SizedBox(height: 0,),

                        // const SizedBox(
                        //   height: 10,
                        // ),
                        if (isAddedByMe)
                          if (!model.isFeature!) createFeaturesAds(),
                        // if (model.customFields!.isNotEmpty) customFields(),
                        //detailsContainer Widget
                        //Dynamic Ads here
                        // Divider(
                        //     thickness: 1,
                        //     color: context.color.textDefaultColor
                        //         .withValues(alpha: 0.1)),
                        // setDescription(),
                        SizedBox(
                          height: 10,
                        ),
                        // Divider(
                        //     thickness: 1,
                        //     color: context.color.textDefaultColor
                        //         .withValues(alpha: 0.1)),
                        //Dynamic Ads here
                        setLocation(),
                        if (Constant.isGoogleBannerAdsEnabled == "1") ...[
                          Divider(
                              thickness: 1,
                              color: context.color.textDefaultColor
                                  .withValues(alpha: 0.1)),
                          Container(
                            alignment: AlignmentDirectional.center,
                            child:
                            AdBannerWidget(), // Custom widget for banner ad
                          ),
                        ]else
                          SizedBox(height: 0,)
                        ,

                        if (!isAddedByMe) reportedAdsWidget(),
                        if (!isAddedByMe) relatedAds(),
                        // const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }));
  }

  Widget reportedAdsWidget() {
    return BlocBuilder<UpdatedReportItemCubit, UpdatedReportItemState>(
      builder: (context, state) {
        bool isItemInCubit =
        context.read<UpdatedReportItemCubit>().containsItem(model.id!);

        if (!isItemInCubit) {
          if (model.isAlreadyReported != null && !model.isAlreadyReported!) {
            return setReportAd();
          } else {
            return SizedBox(); // Return an empty widget if conditions are not met
          }
        } else {
          return SizedBox(); // Return an empty widget if item is not in cubit
        }
      },
    );
  }

  Widget relatedAds() {
    return BlocBuilder<FetchRelatedItemsCubit, FetchRelatedItemsState>(
        builder: (context, state) {
          if (state is FetchRelatedItemsInProgress) {
            return relatedItemShimmer();
          }
          if (state is FetchRelatedItemsFailure) {
            if (state.errorMessage is ApiException) {
              if (state.errorMessage == "no-internet") {
                return NoInternet(
                  onRetry: () {
                    context.read<FetchRelatedItemsCubit>().fetchRelatedItems(
                        categoryId: categoryId!,
                        city: HiveUtils.getCityName(),
                        areaId: HiveUtils.getAreaId(),
                        country: HiveUtils.getCountryName(),
                        state: HiveUtils.getStateName());
                  },
                );
              }
            }

            return const SomethingWentWrong();
          }

          if (state is FetchRelatedItemsSuccess) {
            if (state.itemModel.isEmpty || state.itemModel.length == 1) {
              return SizedBox.shrink();
            }

            return buildRelatedListWidget(state);
          }

          return const SizedBox.square();
        });
  }

  Widget buildRelatedListWidget(FetchRelatedItemsSuccess state) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: context.color.mainGold,
                borderRadius: BorderRadius.circular(7)
            ),
            child: Center(
              child: CustomText(
                "relatedAds".translate(context),
                fontSize: context.font.larger,
                fontWeight: FontWeight.w600,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          GridListAdapter(
            type: ListUiType.List,
            // height: MediaQuery.of(context).size.height / 3.5,
            height: 260,
            controller: _pageScrollController,
            listAxis: Axis.horizontal,
            listSeparator: (BuildContext p0, int p1) => const SizedBox(
              width: 14,
            ),
            isNotSidePadding: true,
            builder: (context, int index, bool) {
              ItemModel? item = state.itemModel[index];

              if (item.id != model.id) {
                return ItemCard(
                  bigCard: true,
                  item: item,
                  width: 170,
                );
              } else {
                return SizedBox.shrink();
              }
            },
            total: state.itemModel.length,
          ),
        ],
      ),
    );
  }

  Widget relatedItemShimmer() {
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

  Widget createFeaturesAds() {
    if (model.status == "active" || model.status == "approved") {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CreateFeaturedAdCubit(),
          ),
          BlocProvider(
            create: (context) => FetchUserPackageLimitCubit(),
          ),
        ],
        child: Builder(builder: (context) {
          return BlocListener<CreateFeaturedAdCubit, CreateFeaturedAdState>(
            listener: (context, state) {
              if (state is CreateFeaturedAdInSuccess) {
                HelperUtils.showSnackBarMessage(
                    context, state.responseMessage.toString(),
                    messageDuration: 3);

                Navigator.pop(context, "refresh");
              }
              if (state is CreateFeaturedAdFailure) {
                HelperUtils.showSnackBarMessage(context, state.error.toString(),
                    messageDuration: 3);
              }
            },
            child: BlocListener<FetchUserPackageLimitCubit,
                FetchUserPackageLimitState>(
              listener: (context, state) async {
                if (state is FetchUserPackageLimitFailure) {
                  UiUtils.noPackageAvailableDialog(context);
                }
                if (state is FetchUserPackageLimitInSuccess) {
                  await UiUtils.showBlurredDialoge(
                    context,
                    dialoge: BlurredDialogBox(
                        title: "createFeaturedAd".translate(context),
                        content: CustomText(
                          "areYouSureToCreateThisItemAsAFeaturedAd"
                              .translate(context),
                        ),
                        isAcceptContainerPush: true,
                        onAccept: () => Future.value().then((_) {
                          Future.delayed(
                            Duration.zero,
                                () {
                              context
                                  .read<CreateFeaturedAdCubit>()
                                  .createFeaturedAds(
                                itemId: model.id!,
                              );
                              Navigator.pop(context);
                              return;
                            },
                          );
                        })),
                  );
                }
              },
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 500),
                crossFadeState: isFeaturedWidget
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(12),
                  //height: 116,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: context.color.mainBrown.withValues(alpha: 0.1),
                    border:
                    Border.all(color: context.color.borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: SvgPicture.asset(
                          AppIcons.createAddIcon,
                          height: 74,
                          width: 62,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "${"featureYourAdsAttractMore".translate(context)}\n${"clientsAndSellFaster".translate(context)}",
                              color: context.color.textDefaultColor
                                  .withValues(alpha: 0.7),
                              fontSize: context.font.large,
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                context
                                    .read<FetchUserPackageLimitCubit>()
                                    .fetchUserPackageLimit(
                                    packageType: "advertisement");
                              },
                              child: Container(
                                height: 33,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: context.color.mainBrown,
                                ),
                                child: CustomText(
                                  "createFeaturedAd".translate(context),
                                  color: context.color.secondaryColor,
                                  fontSize: context.font.small,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: SizedBox.shrink(),
              ),
            ),
          );
        }),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget customFields() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                  blurStyle: BlurStyle.normal
              ),]
        ),
        child:
        Center(
          child:
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Wrap(
              children: [

                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: context.color.mainGold,
                      borderRadius: BorderRadius.circular(7)
                  ),
                  child: Center(
                      child: Text("معلومات إضافية" , style: TextStyle(
                        fontSize: 20,
                      ), )
                  ),
                ),

                ...List.generate(model.customFields!.length, (index) {
                  if (model.customFields![index].value!.isNotEmpty) {
                    return Container(
                      margin: EdgeInsets.all(2),
                      padding: EdgeInsets.all(2),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.red.withValues(alpha: 0.0))
                        ),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * .40,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Container(
                                height: 25,
                                width: 25,
                                alignment: Alignment.center,
                                child: UiUtils.imageType(
                                    model.customFields![index].image!,
                                    fit: BoxFit.contain),
                              ),
                              SizedBox(width: 7),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  Tooltip(
                                    message: model.customFields![index].name,
                                    child: CustomText(
                                        (model.customFields?[index].name) ?? "",
                                        maxLines: 1,
                                        fontSize: context.font.small,
                                        color: context.color.textLightColor),
                                  ),

                                  valueContent(model.customFields![index].value),
                                  const SizedBox(
                                    height: 12,
                                  )
                                ],
                              ),

                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox();
                  }
                }),


              ],
            ),
          ),
        )
    );
  }

  Widget valueContent(List<dynamic>? value) {
    if (((value![0].toString()).startsWith("http") ||
        (value[0].toString()).startsWith("https"))) {
      if ((value[0].toString()).toLowerCase().endsWith(".pdf")) {
        // Render PDF link as clickable text
        return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.pdfViewerScreen,
                  arguments: {"url": value[0]});
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: UiUtils.getSvg(AppIcons.pdfIcon,
                  color: context.color.textColorDark),
            ));
      } else if ((value[0]).toLowerCase().endsWith(".png") ||
          (value[0]).toLowerCase().endsWith(".jpg") ||
          (value[0]).toLowerCase().endsWith(".jpeg") ||
          (value[0]).toLowerCase().endsWith(".svg")) {
        // Render image
        return InkWell(
          onTap: () {
            UiUtils.showFullScreenImage(
              context,
              provider: NetworkImage(
                value[0],
              ),
            );
          },
          child: Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.color.mainBrown.withValues(alpha: 0.1)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: UiUtils.imageType(
                  value[0],
                  color: context.color.mainBrown,
                  fit: BoxFit.cover,
                ),
              )),
        );
      }
    }

    // Default text if not a supported format or not a URL
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * .3,
      child: CustomText(
        value.length == 1 ? value[0].toString() : value.join(','),
        softWrap: true,
        color: context.color.textDefaultColor,
      ),
    );
  }

  Widget itemData(
      int index, SubscriptionPackageModel model, StateSetter stateSetter) {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          if (model.isActive!)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 13.0),
              child: ClipPath(
                clipper: CapShapeClipper(),
                child: Container(
                    color: context.color.mainBrown,
                    width: MediaQuery.of(context).size.width / 3,
                    height: 17,
                    padding: EdgeInsets.only(top: 3),
                    child: CustomText(
                      'activePlanLbl'.translate(context),
                      color: context.color.secondaryColor,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    )),
              ),
            ),
          InkWell(
            onTap: () {
              _selectedPackageIndex = index;
              stateSetter(() {});
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.only(top: 17),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                      color: index == _selectedPackageIndex
                          ? context.color.mainBrown
                          : context.color.textDefaultColor
                          .withValues(alpha: 0.1),
                      width: 1.5)),
              child:
              !model.isActive! ? adsWidget(model) : activeAdsWidget(model),
            ),
          ),
        ],
      ),
    );
  }

  Widget adsWidget(SubscriptionPackageModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                model.name!,
                firstUpperCaseWidget: true,
                fontWeight: FontWeight.w600,
                fontSize: context.font.large,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    '${model.limit == "unlimited" ? "unlimitedLbl".translate(context) : model.limit.toString()}\t${"adsLbl".translate(context)}\t\t·\t\t',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    color:
                    context.color.textDefaultColor.withValues(alpha: 0.5),
                  ),
                  Flexible(
                    child: CustomText(
                      '${model.duration.toString()}\t${"days".translate(context)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      color:
                      context.color.textDefaultColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: 10.0),
          child: CustomText(
            model.finalPrice! > 0
                ? "${model.finalPrice!.currencyFormat}"
                : "free".translate(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget activeAdsWidget(SubscriptionPackageModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                model.name!,
                firstUpperCaseWidget: true,
                fontWeight: FontWeight.w600,
                fontSize: context.font.large,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: model.limit == "unlimited"
                          ? "${"unlimitedLbl".translate(context)}\t${"adsLbl".translate(context)}\t\t·\t\t"
                          : '',
                      style: TextStyle(
                        color: context.color.textDefaultColor
                            .withValues(alpha: 0.5),
                      ),
                      children: [
                        if (model.limit != "unlimited")
                          TextSpan(
                            text:
                            '${model.userPurchasedPackages![0].remainingItemLimit}',
                            style: TextStyle(
                                color: context.color.textDefaultColor),
                          ),
                        if (model.limit != "unlimited")
                          TextSpan(
                            text:
                            '/${model.limit.toString()}\t${"adsLbl".translate(context)}\t\t·\t\t',
                          ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: model.duration == "unlimited"
                            ? "${"unlimitedLbl".translate(context)}\t${"days".translate(context)}"
                            : '',
                        style: TextStyle(
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.5),
                        ),
                        children: [
                          if (model.duration != "unlimited")
                            TextSpan(
                              text:
                              '${model.userPurchasedPackages![0].remainingDays}',
                              style: TextStyle(
                                  color: context.color.textDefaultColor),
                            ),
                          if (model.duration != "unlimited")
                            TextSpan(
                              text:
                              '/${model.duration.toString()}\t${"days".translate(context)}',
                            ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: 10.0),
          child: CustomText(
            model.finalPrice! > 0
                ? "${model.finalPrice!.currencyFormat}"
                : "free".translate(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void showPackageSelectBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.85),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: context.color.borderColor,
                    ),
                    height: 6,
                    width: 60,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 17, horizontal: 20),
                child: CustomText(
                  'selectPackage'.translate(context),
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.bold,
                  fontSize: context.font.large,
                ),
              ),

              Divider(height: 1), // Add some space between title and options
              Expanded(child: packageList()),
            ],
          ),
        );
      },
    );
  }

  Widget packageList() {
    return BlocBuilder<FetchAdsListingSubscriptionPackagesCubit,
        FetchAdsListingSubscriptionPackagesState>(
      builder: (context, state) {
        print("state package***$state");
        if (state is FetchAdsListingSubscriptionPackagesInProgress) {
          return Center(
            child: UiUtils.progress(),
          );
        }
        if (state is FetchAdsListingSubscriptionPackagesFailure) {
          if (state.errorMessage is ApiException) {
            if (state.errorMessage == "no-internet") {
              return NoInternet(
                onRetry: () {
                  context
                      .read<FetchAdsListingSubscriptionPackagesCubit>()
                      .fetchPackages();
                },
              );
            }
          }

          return const SomethingWentWrong();
        }
        if (state is FetchAdsListingSubscriptionPackagesSuccess) {
          print(
              "subscription plan list***${state.subscriptionPackages.length}");
          if (state.subscriptionPackages.isEmpty) {
            return NoDataFound(
              onTap: () {
                context
                    .read<FetchAdsListingSubscriptionPackagesCubit>()
                    .fetchPackages();
              },
            );
          }

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          itemBuilder: (context, index) {
                            return itemData(index,
                                state.subscriptionPackages[index], setStater);
                          },
                          itemCount: state.subscriptionPackages.length),
                    ),
                    Builder(builder: (context) {
                      return BlocListener<RenewItemCubit, RenewItemState>(
                        listener: (context, changeState) {
                          if (changeState is RenewItemInSuccess) {
                            HelperUtils.showSnackBarMessage(
                                context, changeState.responseMessage);
                            Future.delayed(Duration.zero, () {
                              Navigator.pop(context);
                              Navigator.pop(context, "refresh");
                            });
                          } else if (changeState is RenewItemFailure) {
                            Navigator.pop(context);
                            HelperUtils.showSnackBarMessage(
                                context, changeState.error);
                          }
                        },
                        child: UiUtils.buildButton(context, onPressed: () {
                          if (state.subscriptionPackages[_selectedPackageIndex!]
                              .isActive!) {
                            Future.delayed(Duration.zero, () {
                              context.read<RenewItemCubit>().renewItem(
                                  packageId: state
                                      .subscriptionPackages[_selectedPackageIndex!]
                                      .id!,
                                  itemId: model.id!);
                            });
                          } else {
                            Navigator.pop(context);
                            HelperUtils.showSnackBarMessage(context,
                                "pleasePurchasePackage".translate(context));
                            Navigator.pushNamed(
                                context, Routes.subscriptionPackageListRoute);
                          }
                        },
                            radius: 10,
                            height: 46,
                            disabled: _selectedPackageIndex == null,
                            disabledColor:
                            context.color.textLightColor.withValues(alpha: 0.3),
                            fontSize: context.font.large,
                            buttonColor: context.color.mainBrown,
                            textColor: context.color.secondaryColor,
                            buttonTitle: "renewItem".translate(context),

                            //TODO: change title to Your Current Plan according to condition
                            outerPadding: const EdgeInsets.all(20)),
                      );
                    })
                  ],
                );
              });
        }

        return Container();
      },
    );
  }

  Widget bottomButtonWidget() {
    if (isAddedByMe) {
      final contextColor = context.color;

      if (model.status == "review") {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildButton("editBtnLbl".translate(context), () {
                addCloudData("edit_request", model);
                addCloudData("edit_from", model.status);
                Navigator.pushNamed(context, Routes.addItemDetails,
                    arguments: {"isEdit": true});
              }, contextColor.secondaryColor, contextColor.mainBrown),
            ),
            SizedBox(width: 10),
            BlocProvider(
              create: (context) => DeleteItemCubit(),
              child: Builder(builder: (context) {
                return BlocListener<DeleteItemCubit, DeleteItemState>(
                  listener: (context, deleteState) {
                    if (deleteState is DeleteItemSuccess) {
                      HelperUtils.showSnackBarMessage(
                          context, "deleteItemSuccessMsg".translate(context));
                      context.read<FetchMyItemsCubit>().deleteItem(model);
                      Navigator.pop(context, "refresh");
                    } else if (deleteState is DeleteItemFailure) {
                      HelperUtils.showSnackBarMessage(
                          context, deleteState.errorMessage);
                    }
                  },
                  child: Expanded(
                    child:
                    _buildButton("lblremove".translate(context), () async {
                      final delete = await UiUtils.showBlurredDialoge(
                        context,
                        dialoge: BlurredDialogBox(
                          title: "deleteBtnLbl".translate(context),
                          content: CustomText(
                            "deleteitemwarning".translate(context),
                          ),
                        ),
                      ) as bool? ??
                          false;
                      if (delete) {
                        context.read<DeleteItemCubit>().deleteItem(model.id!);
                      }
                    }, null, null),
                  ),
                );
              }),
            ),
          ],
        );
      } else if (model.status == "active" || model.status == "approved") {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildButton("editBtnLbl".translate(context), () {
                addCloudData("edit_request", model);
                addCloudData("edit_from", model.status);
                Navigator.pushNamed(context, Routes.addItemDetails,
                    arguments: {"isEdit": true});
              }, contextColor.secondaryColor, contextColor.mainBrown),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildButton("soldOut".translate(context), () async {
                Navigator.pushNamed(context, Routes.soldOutBoughtScreen,
                    arguments: {
                      "itemId": model.id,
                      "price": model.price,
                      "itemName": model.name,
                      "itemImage": model.image
                    });
              }, null, null),
            ),
          ],
        );
      } else if (model.status == "sold out" ||
          model.status == "inactive" ||
          model.status == "rejected") {
        return BlocProvider(
          create: (context) => DeleteItemCubit(),
          child: Builder(builder: (context) {
            return BlocListener<DeleteItemCubit, DeleteItemState>(
              listener: (context, deleteState) {
                if (deleteState is DeleteItemSuccess) {
                  HelperUtils.showSnackBarMessage(
                      context, "deleteItemSuccessMsg".translate(context));

                  context.read<FetchMyItemsCubit>().deleteItem(model);
                  Navigator.pop(context, "refresh");
                } else if (deleteState is DeleteItemFailure) {
                  HelperUtils.showSnackBarMessage(
                      context, deleteState.errorMessage);
                }
              },
              child: _buildButton("lblremove".translate(context), () {
                Future.delayed(
                  Duration.zero,
                      () {
                    context.read<DeleteItemCubit>().deleteItem(model.id!);
                  },
                );
              }, null, null),
            );
          }),
        );
      } else if (model.status == "expired") {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildButton("renew".translate(context), () {
                // selectPackageDialog();
                showPackageSelectBottomSheet();
              }, contextColor.secondaryColor, contextColor.mainBrown),
            ),
            SizedBox(width: 10),
            BlocProvider(
              create: (context) => DeleteItemCubit(),
              child: Builder(builder: (context) {
                return BlocListener<DeleteItemCubit, DeleteItemState>(
                  listener: (context, deleteState) {
                    if (deleteState is DeleteItemSuccess) {
                      HelperUtils.showSnackBarMessage(
                          context, "deleteItemSuccessMsg".translate(context));
                      context.read<FetchMyItemsCubit>().deleteItem(model);
                      Navigator.pop(context, "refresh");
                    } else if (deleteState is DeleteItemFailure) {
                      HelperUtils.showSnackBarMessage(
                          context, deleteState.errorMessage);
                    }
                  },
                  child: Expanded(
                    child: _buildButton("lblremove".translate(context), () {
                      Future.delayed(
                        Duration.zero,
                            () {
                          context.read<DeleteItemCubit>().deleteItem(model.id!);
                        },
                      );
                    }, null, null),
                  ),
                );
              }),
            ),
          ],
        );
      } else {
        return const SizedBox();
      }
    } else {
      return BlocBuilder<GetBuyerChatListCubit, GetBuyerChatListState>(
        bloc: context.read<GetBuyerChatListCubit>(),
        builder: (context, State) {
          ChatUser? chatedUser = context.select((GetBuyerChatListCubit cubit) =>
              cubit.getOfferForItem(model.id!));

          return BlocListener<MakeAnOfferItemCubit, MakeAnOfferItemState>(
            listener: (context, state) {
              if (state is MakeAnOfferItemSuccess) {
                dynamic data = state.data;

                context.read<GetBuyerChatListCubit>().addOrUpdateChat(ChatUser(
                    itemId: data['item_id'] is String
                        ? int.parse(data['item_id'])
                        : data['item_id'],
                    amount: data['amount'] != null
                        ? double.parse(data['amount'])
                        : null,
                    buyerId: data['buyer_id'],
                    createdAt: data['created_at'],
                    id: data['id'],
                    sellerId: data['seller_id'],
                    updatedAt: data['updated_at'],
                    buyer: Buyer.fromJson(data['buyer']),
                    item: Item.fromJson(data['item']),
                    seller: Seller.fromJson(data['seller'])));

                if (state.from == 'offer') {
                  HelperUtils.showSnackBarMessage(
                    context,
                    state.message.toString(),
                  );
                }

                Navigator.push(context, BlurredRouter(
                  builder: (context) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => SendMessageCubit(),
                        ),
                        BlocProvider(
                          create: (context) => LoadChatMessagesCubit(),
                        ),
                        BlocProvider(
                          create: (context) => DeleteMessageCubit(),
                        ),
                      ],
                      child: ChatScreen(
                        profilePicture: model.user!.profile ?? "",
                        userName: model.user!.name!,
                        userId: model.user!.id!.toString(),
                        from: "item",
                        itemImage: model.image!,
                        itemId: model.id.toString(),
                        date: model.created!,
                        itemTitle: model.name!,
                        itemOfferId: state.data['id'],
                        itemPrice: model.price!,
                        status: model.status!,
                        buyerId: HiveUtils.getUserId(),
                        itemOfferPrice: state.data['amount'] != null
                            ? double.parse(state.data['amount'])
                            : null,
                        isPurchased: model.isPurchased!,
                        alreadyReview: model.review == null
                            ? false
                            : model.review!.isEmpty
                            ? false
                            : true,
                        isFromBuyerList: true,
                      ),
                    );
                  },
                ));
              }
              if (state is MakeAnOfferItemFailure) {
                HelperUtils.showSnackBarMessage(
                  context,
                  state.errorMessage.toString(),
                );
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (chatedUser == null)
                  Expanded(
                    child: _buildButton("makeAnOffer".translate(context), () {
                      UiUtils.checkUser(
                          onNotGuest: () {
                            safetyTipsBottomSheet();
                            //makeOfferBottomSheet(model);
                          },
                          context: context);
                    }, null, null),
                  ),
                if (chatedUser == null) SizedBox(width: 10),
                Expanded(
                  child: _buildButton("chat".translate(context), () {
                    UiUtils.checkUser(
                        onNotGuest: () {
                          if (chatedUser != null) {
                            Navigator.push(context, BlurredRouter(
                              builder: (context) {
                                return MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) => SendMessageCubit(),
                                    ),
                                    BlocProvider(
                                      create: (context) =>
                                          LoadChatMessagesCubit(),
                                    ),
                                    BlocProvider(
                                      create: (context) => DeleteMessageCubit(),
                                    ),
                                  ],
                                  child: ChatScreen(
                                    itemId: chatedUser.itemId.toString(),
                                    profilePicture: chatedUser.seller != null &&
                                        chatedUser.seller!.profile != null
                                        ? chatedUser.seller!.profile!
                                        : "",
                                    userName: chatedUser.seller != null &&
                                        chatedUser.seller!.name != null
                                        ? chatedUser.seller!.name!
                                        : "",
                                    date: chatedUser.createdAt!,
                                    itemOfferId: chatedUser.id!,
                                    itemPrice: chatedUser.item != null &&
                                        chatedUser.item!.price != null
                                        ? chatedUser.item!.price!
                                        : 0.0,
                                    itemOfferPrice: chatedUser.amount != null
                                        ? chatedUser.amount!
                                        : null,
                                    itemImage: chatedUser.item != null &&
                                        chatedUser.item!.image != null
                                        ? chatedUser.item!.image!
                                        : "",
                                    itemTitle: chatedUser.item != null &&
                                        chatedUser.item!.name != null
                                        ? chatedUser.item!.name!
                                        : "",
                                    userId: chatedUser.sellerId.toString(),
                                    buyerId: chatedUser.buyerId.toString(),
                                    status: chatedUser.item!.status,
                                    from: "item",
                                    isPurchased: model.isPurchased!,
                                    alreadyReview: model.review == null
                                        ? false
                                        : model.review!.isEmpty
                                        ? false
                                        : true,
                                    isFromBuyerList: true,
                                  ),
                                );
                              },
                            ));
                          } else {
                            context
                                .read<MakeAnOfferItemCubit>()
                                .makeAnOfferItem(id: model.id!, from: "chat");
                          }
                        },
                        context: context);
                  }, null, null),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void safetyTipsBottomSheet() {
    List<SafetyTipsModel>? tipsList =
    context.read<FetchSafetyTipsListCubit>().getList();
    if (tipsList == null || tipsList.isEmpty) {
      makeOfferBottomSheet(model);
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: context.color.textColorDark.withValues(alpha: 0.1),
                    ),
                    height: 6,
                    width: 60,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: UiUtils.getSvg(
                  AppIcons.safetyTipsIcon,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 5),
                child: CustomText(
                  'safetyTips'.translate(context),
                  fontWeight: FontWeight.w600,
                  fontSize: context.font.larger,
                  textAlign: TextAlign.center,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: tipsList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return checkmarkPoint(
                    context,
                    tipsList[index].translatedName!,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildButton(
                  "continueToOffer".translate(context),
                      () {
                    Navigator.pop(context);
                    makeOfferBottomSheet(model);
                  },
                  context.color.mainBrown,
                  context.color.secondaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget checkmarkPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiUtils.getSvg(
            AppIcons.active_mark,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: CustomText(
                text.firstUpperCase(),
                textAlign: TextAlign.start,
                color: context.color.textDefaultColor,
                fontSize: context.font.large,
              )),
        ],
      ),
    );
  }

  Widget _buildButton(String title, VoidCallback onPressed, Color? buttonColor,
      Color? textColor) {
    return UiUtils.buildButton(
      context,
      onPressed: onPressed,
      radius: 10,
      height: 46,
      border: buttonColor != null
          ? BorderSide(color: context.color.mainBrown)
          : null,
      buttonColor: context.color.mainGold,
      textColor: Colors.black,
      buttonTitle: title,
      width: 50,
    );
  }

//ImageView
  Widget setImageViewer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      // padding: const EdgeInsets.symmetric(vertical: 10),
      // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          PageView.builder(
            itemCount: images.length,
            // Increase itemCount if videoLink is present
            controller: pageController,
            itemBuilder: (context, index) {
              if (index == images.length - 1 &&
                  model.videoLink != "" &&
                  model.videoLink != null) {
                return Stack(
                  children: [
                    // Thumbnail Image
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return VideoViewScreen(
                                videoUrl: model.videoLink ?? "",
                                flickManager: flickManager,
                              );
                            },
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: UiUtils.getImage(
                          youtubeVideoThumbnail,
                          fit: BoxFit.cover,
                          height: 250,
                          width: double.maxFinite,
                        ),
                      ),
                    ),
                    // Play Button
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return VideoViewScreen(
                                  videoUrl: model.videoLink ?? "",
                                  flickManager: flickManager,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Display image
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00FFFFFF),
                        Color(0x00FFFFFF),
                        Color(0x00FFFFFF),
                        Color(0x7F060606)
                      ],
                    ).createShader(bounds);
                    //TODO: change black color to some other app color if required
                  },
                  blendMode: BlendMode.darken,
                  child: InkWell(
                    child: UiUtils.getImage(
                      images[index]!,
                      fit: BoxFit.cover,
                      height: 250,
                    ),
                    onTap: () {
                      UiUtils.imageGallaryView(context,
                          images: images, initalIndex: index);
                    },
                  ),
                );
              }
            },
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  // Increase number of dots if videoLink is present
                      (index) => buildDot(index),
                ),
              ),
            ),
          ),
          if (model.isFeature != null)
            if (model.isFeature!)
              setTopRowItem(
                alignment: AlignmentDirectional.topStart,
                marginVal: 15,
                cornerRadius: 5,
                backgroundColor: context.color.mainBrown,
                childWidget: CustomText(
                  "featured".translate(context),
                  fontSize: context.font.small,
                  color: context.color.backgroundColor,
                ),
              ),
          favouriteButton()
        ]),
      ),
    );
  }

  Widget favouriteButton() {
    if (!isAddedByMe) {
      return BlocBuilder<FavoriteCubit, FavoriteState>(
        bloc: context.read<FavoriteCubit>(),
        builder: (context, favState) {
          bool isLike = context
              .select((FavoriteCubit cubit) => cubit.isItemFavorite(model.id!));

          return BlocConsumer<UpdateFavoriteCubit, UpdateFavoriteState>(
            bloc: context.read<UpdateFavoriteCubit>(),
            listener: (context, state) {
              if (state is UpdateFavoriteSuccess) {
                if (state.wasProcess) {
                  context.read<FavoriteCubit>().addFavoriteitem(state.item);
                } else {
                  context.read<FavoriteCubit>().removeFavoriteItem(state.item);
                }
              }
            },
            builder: (context, state) {
              return setTopRowItem(
                  alignment: AlignmentDirectional.topStart,
                  marginVal: 10,
                  backgroundColor: Colors.white,
                  cornerRadius: 30,
                  childWidget: InkWell(
                    onTap: () {
                      UiUtils.checkUser(
                          onNotGuest: () {
                            context.read<UpdateFavoriteCubit>().setFavoriteItem(
                              item: model,
                              type: isLike ? 0 : 1,
                            );
                          },
                          context: context);
                    },
                    child: state is UpdateFavoriteInProgress
                        ? UiUtils.progress(
                      height: 22,
                      width: 22,
                    )
                        : UiUtils.getSvg(
                        isLike ? AppIcons.like_fill : AppIcons.like,
                        color: context.color.mainGold,
                        width: 22,
                        height: 22),
                  ));
            },
          );
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget setTopRowItem(
      {required AlignmentDirectional alignment,
        required double marginVal,
        required double cornerRadius,
        required Color backgroundColor,
        required Widget childWidget}) {
    return Align(
        alignment: alignment,
        child: Container(
            margin: EdgeInsets.all(marginVal),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius),
                color: backgroundColor),
            child: childWidget)
      //TODO: swap icons according to liked and non-liked -- favorite_border_rounded and favorite_rounded
    );
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      width: currentPage == index ? 12.0 : 8.0,
      height: 8.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentPage == index ? Colors.white : Colors.grey),
    );
  }

//ImageView

  Widget setLikesAndViewsCount() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1,
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.1))),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 46,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UiUtils.getSvg(AppIcons.eye,
                          color: context.color.textDefaultColor),
                      const SizedBox(
                        width: 8,
                      ),
                      CustomText(
                        model.views != null ? model.views!.toString() : "0",
                        color: context.color.textDefaultColor
                            .withValues(alpha: 0.8),
                        fontSize: context.font.large,
                      )
                    ],
                  ))),
          SizedBox(width: 20),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1,
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.1))),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 46,
                  //alignment: AlignmentDirectional.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UiUtils.getSvg(AppIcons.like,
                          color: context.color.textDefaultColor),
                      const SizedBox(
                        width: 8,
                      ),
                      CustomText(
                          model.totalLikes == null
                              ? "0"
                              : model.totalLikes.toString(),
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.8),
                          fontSize: context.font.large)
                    ],
                  ))),
        ],
      ),
    );
  }

  Widget setRejectedReason() {
    if (model.status == "rejected" &&
        (model.rejectedReason != null || model.rejectedReason != "")) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: context.color.textDefaultColor.withValues(alpha: 0.1)),

          // Background color
        ),
        margin: const EdgeInsets.symmetric(vertical: 15),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.report,
                size: 20,
                color: Colors.red, // Icon color can be adjusted
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: CustomText(
                  '${"rejection_reason".translate(context)}: ${model.rejectedReason ?? 'N/A'}',
                  color: context.color.textDefaultColor,
                  fontSize: context.font.large,
                ),
              ),
            ]),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget setPriceAndStatus() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
          color: context.color.mainGold,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: CustomText(
              model.price!.currencyFormat,
              fontSize: context.font.large,
              color: context.color.mainBrown,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (model.status != null && isAddedByMe)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _getStatusColor(model.status),
              ),
              child: CustomText(
                _getStatusCustomText(model.status)!,
                fontSize: context.font.normal,
                color: _getStatusTextColor(model.status),
              ),
            )

          //TODO: change color according to status - confirm,pending,etc..
        ],
      ),
    );
  }

  String? _getStatusCustomText(String? status) {
    switch (status) {
      case "review":
        return "underReview".translate(context);
      case "active":
        return "active".translate(context);
      case "approved":
        return "approved".translate(context);
      case "inactive":
        return "deactivate".translate(context);
      case "sold out":
        return "soldOut".translate(context);
      case "rejected":
        return "rejected".translate(context);
      case "expired":
        return "expired".translate(context);
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "review":
        return pendingButtonColor.withValues(alpha: 0.1);
      case "active" || "approved":
        return activateButtonColor.withValues(alpha: 0.1);
      case "inactive":
        return deactivateButtonColor.withValues(alpha: 0.1);
      case "sold out":
        return soldOutButtonColor.withValues(alpha: 0.1);
      case "rejected":
        return deactivateButtonColor.withValues(alpha: 0.1);
      case "expired":
        return deactivateButtonColor.withValues(alpha: 0.1);
      default:
        return context.color.mainBrown.withValues(alpha: 0.1);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case "review":
        return pendingButtonColor;
      case "active" || "approved":
        return activateButtonColor;
      case "inactive":
        return deactivateButtonColor;
      case "sold out":
        return soldOutButtonColor;
      case "rejected":
        return deactivateButtonColor;
      case "expired":
        return deactivateButtonColor;
      default:
        return context.color.mainBrown;
    }
  }

  Widget setAddress({required bool isDate}) {
    return Container(

      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey , width: 1)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          mainAxisAlignment:
          (isDate) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              AppIcons.location,
              colorFilter:
              ColorFilter.mode(context.color.mainBrown, BlendMode.srcIn),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: 5.0),
                child: CustomText(
                  model.address!,
                  color: context.color.textDefaultColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            (isDate)
                ? Expanded(
                child: CustomText(
                  model.created!.formatDate(format: "d MMM yyyy"),
                  maxLines: 1,
                  color: context.color.textDefaultColor.withValues(alpha: 0.5),
                ))
                : const SizedBox.shrink()
            //TODO: add DATE from model
          ],
        ),
      ),
    );
  }

  Widget setDescription() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(0, 2),
                blurStyle: BlurStyle.normal
            ),]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: context.color.mainGold,
                borderRadius: BorderRadius.circular(7)
            ),
            child: Center(
              child: CustomText(
                "aboutThisItemLbl".translate(context),
                fontWeight: FontWeight.bold,
                fontSize: context.font.larger,
              ),
            ),
          ),

          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.only(top: 0 , right: 3 , left: 3, bottom: 3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                )
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: CustomText(
                model.description!,
                color: context.color.textDefaultColor.withValues(alpha: 0.5),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _navigateToGoogleMapScreen(BuildContext context) {
    Navigator.push(
      context,
      BlurredRouter(
        barrierDismiss: true,
        builder: (context) {
          return GoogleMapScreen(
            item: model,
            kInitialPlace: _kInitialPlace,
            controller: _controller,
          );
        },
      ),
    );
  }

  Widget setLocation() {
    final LatLng currentPosition = LatLng(model.latitude!, model.longitude!);

    return
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                  blurStyle: BlurStyle.normal
              ),]
        ),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              "locationLbl".translate(context),
              fontWeight: FontWeight.bold,
              fontSize: context.font.large,
            ),
            setAddress(isDate: false),
            SizedBox(
              height: 5,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 200,
                child: GoogleMap(
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: false,
                  onTap: (latLng) {
                    _navigateToGoogleMapScreen(context);
                  },
                  initialCameraPosition:
                  CameraPosition(target: currentPosition, zoom: 13),
                  mapType: MapType.normal,
                  markers: {
                    Marker(
                      markerId: MarkerId('currentPosition'),
                      position: currentPosition,
                      onTap: () {
                        // Navigate on marker tap
                        _navigateToGoogleMapScreen(context);
                      },
                    )
                  },
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget setReportAd() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 500),
      crossFadeState: isShowReportAds
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                  blurStyle: BlurStyle.normal
              ),]
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.report,
                    size: 20,
                    color: Colors.red, // Icon color can be adjusted
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: CustomText(
                      "didYouFindAnyProblemWithThisItem".translate(context),
                      maxLines: 2,
                      fontSize: context.font.large,
                    ),
                  ),
                ]),
            SizedBox(height: 15),
            BlocListener<ItemReportCubit, ItemReportState>(
              listener: (context, state) {
                if (state is ItemReportFailure) {
                  HelperUtils.showSnackBarMessage(
                      context, state.error.toString());
                }
                if (state is ItemReportInSuccess) {
                  HelperUtils.showSnackBarMessage(
                      context, state.responseMessage.toString());
                  context.read<UpdatedReportItemCubit>().addItem(model);
                }

                if (!Constant.isDemoModeOn)
                  setState(() {
                    isShowReportAds = false;
                  });
              },
              child: GestureDetector(
                onTap: () {
                  UiUtils.checkUser(
                      onNotGuest: () {
                        _bottomSheet(model.id!);
                      },
                      context: context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.color.mainBrown
                        .withValues(alpha: 0.1), // Button color can be adjusted
                  ),
                  child: CustomText(
                    "reportThisAd".translate(context),
                    color: context.color.mainBrown,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      secondChild: SizedBox.shrink(),
    );
  }

  void makeOfferBottomSheet(ItemModel model) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        content: makeAnOffer(),
        onCancel: () {
          _makeAnOffermessageController.clear();
        },
        acceptButtonName: "send".translate(context),
        isAcceptContainerPush: true,
        onAccept: () => Future.value().then((_) {
          if (_offerFormKey.currentState!.validate()) {
            context.read<MakeAnOfferItemCubit>().makeAnOfferItem(
                id: model.id!,
                from: "offer",
                amount:
                double.parse(_makeAnOffermessageController.text.trim()));
            Navigator.pop(context);
            return;
          }
        }),
      ),
    );
  }

  Widget makeAnOffer() {
    double bottomPadding = (MediaQuery.of(context).viewInsets.bottom - 50);
    bool isBottomPaddingNegative = bottomPadding.isNegative;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Form(
          key: _offerFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                "makeAnOffer".translate(context),
                fontSize: context.font.larger,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              Divider(
                thickness: 1,
                color: context.color.borderColor,
              ),
              const SizedBox(
                height: 15,
              ),
              RichText(
                text: TextSpan(
                  text: '${"sellerPrice".translate(context)} ',
                  style: TextStyle(
                      color:
                      context.color.textDefaultColor.withValues(alpha: 0.5),
                      fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                      text: model.price!.currencyFormat,
                      style: TextStyle(
                          color: context.color.textDefaultColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                    bottom: isBottomPaddingNegative ? 0 : bottomPadding,
                    start: 20,
                    end: 20,
                    top: 18),
                child: TextFormField(
                  maxLines: null,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: context.color.textDefaultColor),
                  controller: _makeAnOffermessageController,
                  cursorColor: context.color.mainBrown,
                  //autovalidateMode: AutovalidateMode.always,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return Validator.nullCheckValidator(val,
                          context: context);
                    } else {
                      double parsedVal = double.parse(val);
                      if (parsedVal <= 0.0) {
                        return "valueMustBeGreaterThanZeroLbl"
                            .translate(context);
                      } else if (parsedVal > model.price!) {
                        return "offerPriceWarning".translate(context);
                      }
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      fillColor: context.color.borderColor,
                      filled: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      hintText: "yourOffer".translate(context),
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.3)),
                      focusColor: context.color.mainBrown,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.color.borderColor)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.color.borderColor)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: context.color.mainBrown))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bottomSheet(int itemId) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
          title: "reportItem".translate(context),
          content: reportReason(),
          isAcceptContainerPush: true,
          onAccept: () => Future.value().then((_) {
            if (selectedId.isNegative) {
              if (_formKey.currentState!.validate()) {
                context.read<ItemReportCubit>().report(
                  item_id: model.id!,
                  reason_id: selectedId,
                  message: _reportmessageController.text,
                );
                Navigator.pop(context);
                return;
              }
            } else {
              context.read<ItemReportCubit>().report(
                item_id: model.id!,
                reason_id: selectedId,
              );
              Navigator.pop(context);
              return;
            }
          })),
    );
  }

  String formatPhoneNumber(String fullNumber, String countryCode) {
    // Normalize the country code (remove '+' if present)
    countryCode = countryCode.replaceAll('+', '');

    // Remove '+' from fullNumber if present
    fullNumber = fullNumber.replaceAll('+', '');

    // Check if the fullNumber already starts with the country code
    if (!fullNumber.startsWith(countryCode)) {
      // If not, prepend the country code
      fullNumber = countryCode + fullNumber;
    }

    // Add '+' to the beginning of the full number
    fullNumber = '+' + fullNumber;

    return fullNumber;
  }

  Widget setSellerDetails() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(0, 2),
                blurStyle: BlurStyle.normal
            ),]
      ),
      child: InkWell(
        child:
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(children: [
            SizedBox(
                height: 60,
                width: 60,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: model.user!.profile != null &&
                        model.user!.profile != ""
                        ? UiUtils.getImage(model.user!.profile!, fit: BoxFit.fill)
                        : UiUtils.getSvg(
                      AppIcons.defaultPersonLogo,
                      color: context.color.mainBrown,
                      fit: BoxFit.none,
                    ))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (model.user!.isVerified == 1)
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: context.color.forthColor),
                          padding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UiUtils.getSvg(AppIcons.verifiedIcon,
                                  width: 14, height: 14),
                              SizedBox(
                                width: 4,
                              ),
                              CustomText(
                                "verifiedLbl".translate(context),
                                color: context.color.secondaryColor,
                                fontWeight: FontWeight.w500,
                              )
                            ],
                          ),
                        ),
                      CustomText(model.user!.name!,
                          fontWeight: FontWeight.bold,
                          fontSize: context.font.large),
                      if (context.watch<FetchSellerRatingsCubit>().sellerData() !=
                          null)
                        if (context
                            .watch<FetchSellerRatingsCubit>()
                            .sellerData()!
                            .averageRating !=
                            null)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Icon(Icons.star_rounded,
                                        size: 17,
                                        color: context
                                            .color.textDefaultColor), // Star icon
                                  ),
                                  TextSpan(
                                    text:
                                    '\t${context.watch<FetchSellerRatingsCubit>().sellerData()!.averageRating!.toStringAsFixed(2).toString()}',
                                    // Rating value
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.color.textDefaultColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '  |  ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.color.textDefaultColor
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                    '${context.watch<FetchSellerRatingsCubit>().totalSellerRatings()}\t${"ratings".translate(context)}',
                                    // Rating count text
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.color.textDefaultColor
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      if (model.user!.showPersonalDetails == 1)
                        if (model.user!.email != null || model.user!.email != "")
                          CustomText(model.user!.email!,
                              color: context.color.textLightColor,
                              fontSize: context.font.small),
                    ]),
              ),
            ),
            if (model.user!.showPersonalDetails == 1)
              if (model.user!.mobile != null || model.user!.mobile != "")
                setIconButtons(
                    assetName: AppIcons.message,
                    onTap: () {
                      HelperUtils.launchPathURL(
                          isTelephone: false,
                          isSMS: true,
                          isMail: false,
                          value: formatPhoneNumber(
                              model.user!.mobile!, Constant.defaultCountryCode),
                          context: context);
                    }),
            SizedBox(width: 10),
            if (model.user!.showPersonalDetails == 1)
              if (model.user!.mobile != null || model.user!.mobile != "")
                setIconButtons(
                    assetName: AppIcons.call,
                    onTap: () {
                      HelperUtils.launchPathURL(
                          isTelephone: true,
                          isSMS: false,
                          isMail: false,
                          value: formatPhoneNumber(
                              model.user!.mobile!, Constant.defaultCountryCode),
                          context: context);
                    })
          ]),
        ),
        onTap: () {
          Navigator.pushNamed(context, Routes.sellerProfileScreen,
            arguments:  {"sellerId": model.user?.id}

          //   "model": model.user!,
          //   "total":
          //   context.read<FetchSellerRatingsCubit>().totalSellerRatings() ?? 0,
          //   "rating": context
          //       .read<FetchSellerRatingsCubit>()
          //       .sellerData()!
          //       .averageRating ?? null
           );
        },
      ),
    );
  }

  Widget setIconButtons({
    required String assetName,
    required void Function() onTap,
    Color? color,
    double? height,
    double? width,
  }) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.color.borderColor)),
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
                onTap: onTap,
                child: SvgPicture.asset(
                  assetName,
                  colorFilter: color == null
                      ? ColorFilter.mode(
                      context.color.mainBrown, BlendMode.srcIn)
                      : ColorFilter.mode(color, BlendMode.srcIn),
                ))));
  }

  Widget reportReason() {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom - 50;
    bool isBottomPaddingNegative = bottomPadding.isNegative;
    reasons = context.read<FetchItemReportReasonsListCubit>().getList() ?? [];

    if (reasons?.isEmpty ?? true) {
      selectedId = -10;
    } else {
      selectedId = reasons!.first.id;
    }
    setState(() {});
    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: reasons?.length ?? 0,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          selectedId = reasons![index].id;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.color.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedId == reasons![index].id
                                ? context.color.mainBrown
                                : context.color.borderColor,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: CustomText(
                            reasons![index].reason.firstUpperCase(),
                            color: selectedId == reasons![index].id
                                ? context.color.mainBrown
                                : context.color.textColorDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (selectedId.isNegative)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      bottom: isBottomPaddingNegative ? 0 : bottomPadding,
                      start: 0,
                      end: 0,
                    ),
                    child: TextFormField(
                      maxLines: null,
                      controller: _reportmessageController,
                      cursorColor: context.color.mainBrown,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "addReportReason".translate(context);
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "writeReasonHere".translate(context),
                        focusColor: context.color.mainBrown,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: context.color.mainBrown,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
