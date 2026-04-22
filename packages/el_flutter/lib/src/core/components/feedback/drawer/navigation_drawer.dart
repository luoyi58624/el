// part of 'index.dart';
//
// // ignore_for_file: invalid_use_of_visible_for_testing_member
// // ignore_for_file: invalid_use_of_protected_member
//
// /// 构建导航抽屉，允许在边缘划出抽屉（仅支持左侧、右侧方向抽屉）
// class ElNavigationDrawer extends StatefulWidget {
//   const ElNavigationDrawer({
//     super.key,
//     this.drawer,
//     this.endDrawer,
//     this.enabledDrag,
//     this.edgeDragWidth = 20.0,
//     this.touchSlop,
//     this.child,
//   });
//
//   /// 左侧抽屉
//   final ElDrawer? drawer;
//
//   /// 右侧抽屉
//   final ElDrawer? endDrawer;
//
//   /// 是否开启边缘拖拽显示抽屉，若为 null，移动端将默认为 true，桌面端则为 false
//   final bool? enabledDrag;
//
//   /// 滑动边缘宽度，若为 null 则默认填充整个屏幕宽度
//   final double? edgeDragWidth;
//
//   /// 触发水平拖拽的偏移值，默认 [kTouchSlop]，该值越大就越不容易触发水平拖拽，用于防止误触
//   final double? touchSlop;
//
//   final Widget? child;
//
//   @override
//   State<ElNavigationDrawer> createState() => _ElNavigationDrawerState();
// }
//
// class _ElNavigationDrawerState extends State<ElNavigationDrawer> {
//   final _stackKey = GlobalKey();
//   ElDrawer? drawerWidget;
//   ElDrawer? endDrawerWidget;
//   ElDrawerState? drawerState;
//   ElDrawerState? endDrawerState;
//   late double edgeDragWidth;
//
//   double calcEdgeDragWidth(double maxWidth) {
//     if (widget.edgeDragWidth != null) return widget.edgeDragWidth!;
//     int drawerNums = 0;
//     if (widget.drawer != null) drawerNums++;
//     if (widget.endDrawer != null) drawerNums++;
//     if (drawerNums <= 0) return 0.0;
//     return maxWidth / drawerNums;
//   }
//
//   /// 将抽屉实例转变为导航抽屉
//   static ElDrawer toNavigationDrawer(
//     ElDrawer drawer, [
//     bool isEndDrawer = false,
//   ]) {
//     return ElDrawer(
//       key: drawer.key,
//       show: drawer.show,
//       overlayId: drawer.overlayId,
//       keepAlive: true,
//       onInsert: drawer.onInsert,
//       onRemove: drawer.onRemove,
//       onChanged: drawer.onChanged,
//       overlayBuilder: drawer.overlayBuilder,
//       enabledDragFeedback: drawer.enabledDragFeedback,
//       enabledDrag: drawer.enabledDrag,
//       maxPrimarySize: drawer.maxPrimarySize,
//       direction: isEndDrawer ? AxisDirection.right : AxisDirection.left,
//       modalColor: drawer.modalColor,
//       ignoreModalPointer: drawer.ignoreModalPointer,
//       child: drawer.child,
//     );
//   }
//
//   void setDrawer() {
//     if (widget.drawer == null) {
//       drawerWidget = null;
//       drawerState = null;
//       return;
//     }
//
//     drawerWidget = toNavigationDrawer(widget.drawer!);
//     nextTick(() {
//       _stackKey.currentContext!.visitChildElements((v) {
//         if (v.widget is ElPositioned) {
//           final id = (v.widget as ElPositioned).id;
//           if (id == #leftOverlay) {
//             v.visitChildElements((v) {
//               final result = (v as StatefulElement).state as ElDrawerState;
//               drawerState = result;
//               if (drawerState!.overlayEntry == null) {
//                 drawerState!.insertOverlay();
//               }
//             });
//           }
//         }
//       });
//     });
//   }
//
//   void setEndDrawer() {
//     if (widget.endDrawer == null) {
//       endDrawerWidget = null;
//       endDrawerState = null;
//       return;
//     }
//
//     endDrawerWidget = toNavigationDrawer(widget.endDrawer!, true);
//     nextTick(() {
//       _stackKey.currentContext!.visitChildElements((v) {
//         if (v.widget is ElPositioned) {
//           final id = (v.widget as ElPositioned).id;
//           if (id == #rightOverlay) {
//             v.visitChildElements((v) {
//               final result = (v as StatefulElement).state as ElDrawerState;
//               endDrawerState = result;
//               if (endDrawerState!.overlayEntry == null) {
//                 endDrawerState!.insertOverlay();
//               }
//             });
//           }
//         }
//       });
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     setDrawer();
//     setEndDrawer();
//   }
//
//   @override
//   void didUpdateWidget(covariant ElNavigationDrawer oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (widget.drawer != oldWidget.drawer) setDrawer();
//     if (widget.endDrawer != oldWidget.endDrawer) setEndDrawer();
//   }
//
//   Widget buildGestureSetting(BuildContext context, Widget child) {
//     if (widget.touchSlop == null) return child;
//
//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(
//         gestureSettings: DeviceGestureSettings(touchSlop: widget.touchSlop),
//       ),
//       child: child,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         edgeDragWidth = calcEdgeDragWidth(constraints.maxWidth);
//
//         final List<ElUniqueWidget> children = [];
//
//         if (_allowedDrag(widget.enabledDrag) == false) {
//           if (drawerWidget != null) {
//             children.add(ElPositioned(key: ValueKey('leftOverlay'), child: drawerWidget!));
//           }
//           if (endDrawerWidget != null) {
//             children.add(
//               ElPositioned(id: #rightOverlay, child: endDrawerWidget!),
//             );
//           }
//         } else {
//           final isLtr = context.ltr;
//           if (drawerWidget != null) {
//             children.addAll([
//               ElPositioned(id: #leftOverlay, child: drawerWidget!),
//               ElPositioned(
//                 id: #leftDrag,
//                 top: 0,
//                 bottom: 0,
//                 left: isLtr ? 0 : null,
//                 right: isLtr ? null : 0,
//                 child: Builder(
//                   builder: (context) {
//                     return buildGestureSetting(
//                       context,
//                       _DrawerDrag(
//                         onDragStart: () {
//                           drawerState!.showOverlay();
//                           drawerState!.lockObsUpdate = true;
//                         },
//                         onDragUpdate: (delta) {
//                           drawerState!.animationController.value += delta;
//                         },
//                         onDragEnd: (delta) {
//                           drawerState!.lockObsUpdate = null;
//                           drawerState!._dragEnd(delta);
//                         },
//                         behavior: HitTestBehavior.translucent,
//                         direction: drawerWidget!.direction.resolve(
//                           Directionality.of(context),
//                         ),
//                         getContentKey: () => drawerState!.contentKey,
//                         child: SizedBox(width: edgeDragWidth),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ]);
//           }
//           if (endDrawerWidget != null) {
//             children.addAll([
//               ElPositioned(id: #rightOverlay, child: endDrawerWidget!),
//               ElPositioned(
//                 id: #rightDrag,
//                 top: 0,
//                 bottom: 0,
//                 left: isLtr ? null : 0,
//                 right: isLtr ? 0 : null,
//                 child: Builder(
//                   builder: (context) {
//                     return buildGestureSetting(
//                       context,
//                       _DrawerDrag(
//                         onDragStart: () {
//                           endDrawerState!.showOverlay();
//                           endDrawerState!.lockObsUpdate = true;
//                         },
//                         onDragUpdate: (delta) {
//                           endDrawerState!.animationController.value += delta;
//                         },
//                         onDragEnd: (delta) {
//                           endDrawerState!.lockObsUpdate = null;
//                           endDrawerState!._dragEnd(delta);
//                         },
//                         behavior: HitTestBehavior.translucent,
//                         direction: endDrawerWidget!.direction.resolve(
//                           Directionality.of(context),
//                         ),
//                         getContentKey: () => endDrawerState!.contentKey,
//                         child: SizedBox(width: edgeDragWidth),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ]);
//           }
//         }
//
//         return ElStack(
//           key: _stackKey,
//           sizedByParent: true,
//           children: children,
//           child: widget.child,
//         );
//       },
//     );
//   }
// }
