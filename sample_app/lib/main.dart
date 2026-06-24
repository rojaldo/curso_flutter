import 'package:flutter/material.dart';
import 'package:sample_app/ui/features/exercises/views/apod_page.dart';
import 'package:sample_app/ui/features/exercises/views/calculator.dart';
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

void main() {
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
        '/exercise_calculator': (_) => const CalculatorExample(),
        '/exercise_apod': (_) => const ApodPage(),
      },
    );
  }
}