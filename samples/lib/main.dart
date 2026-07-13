import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample_app/ui/features/exercises/views/apod_page.dart';
import 'package:sample_app/ui/features/exercises/views/calculator.dart';
import 'package:sample_app/ui/features/exercises/views/user_form_page.dart';
import 'package:sample_app/ui/features/exercises/views/yolo_image_page.dart';
import 'package:sample_app/ui/features/exercises/view_models/calculator_cubit.dart';
import 'package:sample_app/ui/features/exercises/views/location_page.dart';
import 'package:sample_app/ui/features/exercises/views/star_wars_page.dart';
import 'package:sample_app/ui/home_page.dart';
import 'package:sample_app/ui/features/widget_concepts/views/stateless_vs_stateful_example.dart';
import 'package:sample_app/ui/features/widget_concepts/views/widget_lifecycle_example.dart';
import 'package:sample_app/ui/features/widget_concepts/views/keys_example.dart';
import 'package:sample_app/ui/features/widget_concepts/views/widget_tree_example.dart';
import 'package:sample_app/ui/features/widget_concepts/views/const_widget_example.dart';
import 'package:sample_app/ui/features/widget_concepts/views/composition_example.dart';
import 'package:sample_app/ui/features/widget_concepts/views/declarative_model_example.dart';
import 'package:sample_app/ui/features/widget_concepts/views/rebuild_optimization_example.dart';
import 'package:sample_app/ui/features/layout/views/container_example.dart';
import 'package:sample_app/ui/features/layout/views/row_column_example.dart';
import 'package:sample_app/ui/features/layout/views/stack_example.dart';
import 'package:sample_app/ui/features/layout/views/listview_example.dart';
import 'package:sample_app/ui/features/layout/views/gridview_example.dart';
import 'package:sample_app/ui/features/navigation/views/navigation_example.dart';
import 'package:sample_app/ui/features/navigation/views/bottom_nav_example.dart';
import 'package:sample_app/ui/features/navigation/views/tabbar_example.dart';
import 'package:sample_app/ui/features/navigation/views/drawer_example.dart';
import 'package:sample_app/ui/features/input/views/form_example.dart';
import 'package:sample_app/ui/features/input/views/controls_example.dart';
import 'package:sample_app/ui/features/input/views/gesture_example.dart';
import 'package:sample_app/ui/features/state_mgmt/views/setstate_example.dart';
import 'package:sample_app/ui/features/state_mgmt/views/value_notifier_example.dart';
import 'package:sample_app/ui/features/state_mgmt/views/inherited_widget_example.dart';
import 'package:sample_app/ui/features/animation/views/implicit_animation_example.dart';
import 'package:sample_app/ui/features/animation/views/hero_example.dart';
import 'package:sample_app/ui/features/animation/views/explicit_animation_example.dart';
import 'package:sample_app/ui/features/visual/views/icons_images_example.dart';
import 'package:sample_app/ui/features/visual/views/themes_example.dart';
import 'package:sample_app/ui/features/visual/views/custom_painter_example.dart';
import 'package:sample_app/ui/features/async_data/views/future_builder_example.dart';
import 'package:sample_app/ui/features/async_data/views/stream_builder_example.dart';
import 'package:sample_app/ui/features/async_data/views/http_json_example.dart';
import 'package:sample_app/ui/features/material/views/cards_example.dart';
import 'package:sample_app/ui/features/material/views/dialogs_example.dart';
import 'package:sample_app/ui/features/material/views/sliver_example.dart';
import 'package:sample_app/ui/features/material/views/chips_example.dart';
import 'package:sample_app/ui/features/interaction/views/drag_drop_example.dart';
import 'package:sample_app/ui/features/interaction/views/dismissible_example.dart';
import 'package:sample_app/ui/features/interaction/views/reorderable_example.dart';
import 'package:sample_app/ui/features/lists/views/generic_list_example.dart';
import 'package:sample_app/ui/features/lists/views/custom_list_example.dart';
import 'package:sample_app/ui/features/lists/views/expandable_list_example.dart';
import 'package:sample_app/ui/features/lists/views/checklist_list_example.dart';
import 'package:sample_app/ui/features/api_rest/views/api_get_list_example.dart';
import 'package:sample_app/ui/features/api_rest/views/api_get_detail_example.dart';
import 'package:sample_app/ui/features/api_rest/views/api_post_example.dart';
import 'package:sample_app/ui/features/api_rest/views/api_put_example.dart';
import 'package:sample_app/ui/features/api_rest/views/api_delete_example.dart';
import 'package:sample_app/ui/features/api_rest/views/api_pagination_example.dart';
import 'package:sample_app/ui/features/api_rest/views/api_search_example.dart';
import 'package:sample_app/ui/features/api_rest/views/api_errors_example.dart';
import 'package:sample_app/ui/features/api_rest/views/api_images_example.dart';
import 'package:sample_app/ui/features/maps/views/basic_map_example.dart';
import 'package:sample_app/ui/features/maps/views/camera_control_example.dart';
import 'package:sample_app/ui/features/maps/views/circles_example.dart';
import 'package:sample_app/ui/features/maps/views/info_window_example.dart';
import 'package:sample_app/ui/features/maps/views/map_styling_example.dart';
import 'package:sample_app/ui/features/maps/views/map_type_example.dart';
import 'package:sample_app/ui/features/maps/views/map_ui_controls_example.dart';
import 'package:sample_app/ui/features/maps/views/markers_example.dart';
import 'package:sample_app/ui/features/maps/views/my_location_example.dart';
import 'package:sample_app/ui/features/maps/views/polygons_example.dart';
import 'package:sample_app/ui/features/maps/views/polylines_example.dart';
import 'package:sample_app/ui/features/camera/views/camera_preview_page.dart';
import 'package:sample_app/ui/features/camera/views/camera_capture_page.dart';
import 'package:sample_app/ui/features/camera/views/camera_video_page.dart';
import 'package:sample_app/ui/features/camera/views/camera_flash_zoom_page.dart';
import 'package:sample_app/ui/features/camera/views/camera_timer_page.dart';
import 'package:sample_app/ui/features/camera/views/yolo_classifier_page.dart';

late final SharedPreferences _prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demostrador',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/stateless_vs_stateful': (_) => const StatelessVsStatefulExample(),
        '/widget_lifecycle': (_) => const WidgetLifecycleExample(),
        '/keys': (_) => const KeysExample(),
        '/widget_tree': (_) => const WidgetTreeExample(),
        '/const_widget': (_) => const ConstWidgetExample(),
        '/composition': (_) => const CompositionExample(),
        '/declarative_model': (_) => const DeclarativeModelExample(),
        '/rebuild_optimization': (_) => const RebuildOptimizationExample(),
        '/container': (_) => const ContainerExample(),
        '/row_column': (_) => const RowColumnExample(),
        '/stack': (_) => const StackExample(),
        '/listview': (_) => const ListviewExample(),
        '/gridview': (_) => const GridviewExample(),
        '/navigation': (_) => const NavigationExample(),
        '/bottom_nav': (_) => const BottomNavExample(),
        '/tabbar': (_) => const TabbarExample(),
        '/drawer': (_) => const DrawerExample(),
        '/form': (_) => const FormExample(),
        '/controls': (_) => const ControlsExample(),
        '/gesture': (_) => const GestureExample(),
        '/setstate': (_) => const SetStateExample(),
        '/value_notifier': (_) => const ValueNotifierExample(),
        '/inherited_widget': (_) => const InheritedWidgetExample(),
        '/implicit_animation': (_) => const ImplicitAnimationExample(),
        '/hero': (_) => const HeroExample(),
        '/explicit_animation': (_) => const ExplicitAnimationExample(),
        '/icons_images': (_) => const IconsImagesExample(),
        '/themes': (_) => const ThemesExample(),
        '/custom_painter': (_) => const CustomPainterExample(),
        '/future_builder': (_) => const FutureBuilderExample(),
        '/stream_builder': (_) => const StreamBuilderExample(),
        '/http_json': (_) => const HttpJsonExample(),
        '/cards': (_) => const CardsExample(),
        '/dialogs': (_) => const DialogsExample(),
        '/sliver': (_) => const SliverExample(),
        '/chips': (_) => const ChipsExample(),
        '/drag_drop': (_) => const DragDropExample(),
        '/dismissible': (_) => const DismissibleExample(),
        '/reorderable': (_) => const ReorderableExample(),
        '/generic_list': (_) => const GenericListExample(),
        '/custom_list': (_) => const CustomListExample(),
        '/expandable_list': (_) => const ExpandableListExample(),
        '/checklist_list': (_) => const ChecklistListExample(),
        '/api_get_list': (_) => const ApiGetListExample(),
        '/api_get_detail': (_) => const ApiGetDetailExample(),
        '/api_post': (_) => const ApiPostExample(),
        '/api_put': (_) => const ApiPutExample(),
        '/api_delete': (_) => const ApiDeleteExample(),
        '/api_pagination': (_) => const ApiPaginationExample(),
        '/api_search': (_) => const ApiSearchExample(),
        '/api_errors': (_) => const ApiErrorsExample(),
        '/api_images': (_) => const ApiImagesExample(),
        '/exercise_calculator': (_) => BlocProvider(
              create: (_) => CalculatorCubit(prefs: _prefs),
              child: const CalculatorExample(),
            ),
        '/exercise_user_form': (_) => UserFormPage(prefs: _prefs),
        '/exercise_yolo': (_) => const YoloImagePage(),
        '/exercise_apod': (_) => const ApodPage(),
        '/exercise_star_wars': (_) => const StarWarsPage(),
        '/exercise_location': (_) => const LocationPage(),
        '/map_basic': (_) => const BasicMapExample(),
        '/map_type': (_) => const MapTypeExample(),
        '/map_camera_control': (_) => const CameraControlExample(),
        '/map_markers': (_) => const MarkersExample(),
        '/map_info_window': (_) => const InfoWindowExample(),
        '/map_polylines': (_) => const PolylinesExample(),
        '/map_polygons': (_) => const PolygonsExample(),
        '/map_circles': (_) => const CirclesExample(),
        '/map_ui_controls': (_) => const MapUiControlsExample(),
        '/map_my_location': (_) => const MyLocationExample(),
        '/map_styling': (_) => const MapStylingExample(),
        '/camera_preview': (_) => const CameraPreviewPage(),
        '/camera_capture': (_) => const CameraCapturePage(),
        '/camera_video': (_) => const CameraVideoPage(),
        '/camera_flash_zoom': (_) => const CameraFlashZoomPage(),
        '/camera_timer': (_) => const CameraTimerPage(),
        '/camera_yolo': (_) => const YoloClassifierPage(),
      },
    );
  }
}