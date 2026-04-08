import 'package:flutter/material.dart';
import 'package:what2eat/models/dish.dart';
import 'package:what2eat/models/dish_group.dart';

class GroupDishesManagementPage extends StatefulWidget {
  final List<Dish> allDishes;
  final DishGroup group;
  final Function(DishGroup) onGroupUpdated;

  const GroupDishesManagementPage({
    super.key,
    required this.allDishes,
    required this.group,
    required this.onGroupUpdated,
  });

  @override
  State<GroupDishesManagementPage> createState() => _GroupDishesManagementPageState();
}

class _GroupDishesManagementPageState extends State<GroupDishesManagementPage> {
  late Set<String> _selectedDishIds;

  @override
  void initState() {
    super.initState();
    _selectedDishIds = Set.from(widget.group.dishIds);
  }

  void _toggleDish(String dishId, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        _selectedDishIds.add(dishId);
      } else {
        _selectedDishIds.remove(dishId);
      }
    });
  }

  void _save() {
    final updatedGroup = widget.group.copyWith(dishIds: _selectedDishIds.toList());
    widget.onGroupUpdated(updatedGroup);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerichte für "${widget.group.name}" verwalten'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.allDishes.length,
        itemBuilder: (context, index) {
          final dish = widget.allDishes[index];
          return CheckboxListTile(
            title: Text(dish.title),
            subtitle: Text(dish.description),
            value: _selectedDishIds.contains(dish.id),
            onChanged: (value) => _toggleDish(dish.id, value),
          );
        },
      ),
    );
  }
}