import 'dart:ui';

import 'package:example/utils/extension.dart';
import 'package:example/utils/item_card.dart';
import 'package:example/utils/item_tile.dart';
import 'package:flutter/material.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';

class User {
  final String name;
  final int index;

  User({required this.name, required this.index});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AnimationType appliedStyle = AnimationType.fadeIn;
  List<User> list = List.generate(8, (index) => User(name: "User $index", index: index));
  int addedNumber = 9;
  bool isGrid = true;

  List<AnimationEffect> animations = [];

  void insert() {
    addedNumber += 1;
    setState(() {
      list.insert(1, User(name: "User $addedNumber", index: addedNumber));
    });
  }

  void remove() {
    setState(() {
      if (list.isNotEmpty && list.length > 1) list.removeAt(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<AnimationType>(
                    iconEnabledColor: Colors.black87,
                    value: appliedStyle,
                    items: AnimationType.values.map((AnimationType animationType) {
                      return DropdownMenuItem<AnimationType>(
                        value: animationType,
                        child: Text(
                          animationType.name.capitalize(),
                          style: const TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (AnimationType? animationType) {
                      if (animationType == null) {
                        return;
                      }
                      animations = [];
                      AnimationEffect animation = AnimationProvider.buildAnimation(animationType);
                      animations.add(animation);
                      setState(() {
                        appliedStyle = animationType;
                      });
                    }),
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: insert,
                child: const Text(
                  'ADD',
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
                )),
            TextButton(
                onPressed: remove,
                child: const Text(
                  'DEL',
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
                ))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isGrid != false) {
                            isGrid = false;
                          }
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'List',
                          style: TextStyle(fontSize: 25),
                        ),
                      )),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () {
                      setState(() {
                        if (isGrid != true) {
                          isGrid = true;
                        }
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Grid',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: isGrid
                    ? AnimatedReorderableGridView(
                        items: list,
                        scrollDirection: Axis.vertical,
                        onReorderLongTap: (int index) {
                          print('onReorderLongTap');
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return ItemCard(key: Key(list[index].name), index: list[index].index);
                        },
                        sliverGridDelegate: SliverReorderableGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                        enterTransition: animations,
                        exitTransition: animations,
                        insertDuration: const Duration(milliseconds: 300),
                        removeDuration: const Duration(milliseconds: 300),
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            final User user = list.removeAt(oldIndex);
                            list.insert(newIndex, user);
                          });
                        },
                        onReorderEnd: (int index) {
                          print(" End index :  $index");
                        },
                        onReorderStart: (int index) {
                          print(" Start index :  $index");
                        },
                        proxyDecorator: proxyDecorator

                        /*  A custom builder that is for inserting items with animations.

                              insertItemBuilder: (Widget child, Animation<double> animation){
                                 return ScaleTransition(
                                       scale: animation,
                                       child: child,
                                     );
                                    },


                      */
                        /*  A custom builder that is for removing items with animations.

                                  removeItemBuilder: (Widget child, Animation<double> animation){
                                     return ScaleTransition(
                                       scale: animation,
                                       child: child,
                                     );
                                    },
                      */
                        )
                    : AnimatedReorderableListView(
                        items: list,
                        itemBuilder: (BuildContext context, int index) {
                          return ItemTile(key: Key(list[index].name), index: list[index].index);
                        },
                        enterTransition: animations,
                        exitTransition: animations,
                        insertDuration: const Duration(milliseconds: 300),
                        removeDuration: const Duration(milliseconds: 300),
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            final User user = list.removeAt(oldIndex);
                            list.insert(newIndex, user);
                          });
                        },
                        proxyDecorator: proxyDecorator

                        /*  A custom builder that is for inserting items with animations.

                              insertItemBuilder: (Widget child, Animation<double> animation){
                                 return ScaleTransition(
                                       scale: animation,
                                       child: child,
                                     );
                                    },


                      */
                        /*  A custom builder that is for removing items with animations.

                                  removeItemBuilder: (Widget child, Animation<double> animation){
                                     return ScaleTransition(
                                       scale: animation,
                                       child: child,
                                     );
                                    },
                      */
                        ),
              ),
            ],
          ),
        ));
  }
}

Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final double animValue = Curves.easeInOut.transform(animation.value);
      final double elevation = lerpDouble(0, 6, animValue)!;
      return Material(
        elevation: elevation,
        color: Colors.grey,
        shadowColor: Colors.black,
        child: child,
      );
    },
    child: child,
  );
}

enum AnimationType {
  fadeIn,
  flipInY,
  flipInX,
  landing,
  size,
  scaleIn,
  scaleInTop,
  scaleInBottom,
  scaleInLeft,
  scaleInRight,
  slideInLeft,
  slideInRight,
  slideInDown,
  slideInUp,
}

class AnimationProvider {
  static AnimationEffect buildAnimation(AnimationType animationType) {
    switch (animationType) {
      case (AnimationType.fadeIn):
        return FadeIn();
      case (AnimationType.flipInY):
        return FlipInY();
      case (AnimationType.flipInX):
        return FlipInX();
      case (AnimationType.landing):
        return Landing();
      case (AnimationType.size):
        return SizeAnimation();
      case (AnimationType.scaleIn):
        return ScaleIn();
      case (AnimationType.scaleInTop):
        return ScaleInTop();
      case (AnimationType.scaleInBottom):
        return ScaleInBottom();
      case (AnimationType.scaleInLeft):
        return ScaleInLeft();
      case (AnimationType.scaleInRight):
        return ScaleInRight();
      case (AnimationType.slideInLeft):
        return SlideInLeft();
      case (AnimationType.slideInRight):
        return SlideInRight();
      case (AnimationType.slideInUp):
        return SlideInUp();
      case (AnimationType.slideInDown):
        return SlideInDown();
    }
  }
}
