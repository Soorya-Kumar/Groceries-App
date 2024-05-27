import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groceries_app/data/categories.dart';
import 'package:http/http.dart' as http;
import 'package:groceries_app/models/grocery_item.dart';
import 'package:groceries_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItemstoDisplay = [];
  var _isloading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'groceries-app-b740c-default-rtdb.firebaseio.com', 'grocerylist.json');

    try {
      final response = await http.get(url);
      
      if (response.body == 'null') {
        setState(() {
          _isloading = false;
        });
        return;
      }

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later..';
        });
      }

      final Map<String, dynamic> onlineData = json.decode(response.body);
      final List<GroceryItem> itemsList = [];
      for (final gItem in onlineData.entries) {
        final category = categories.entries
            .firstWhere(
                (element) => element.value.title == gItem.value['category'])
            .value;
        itemsList.add(
          GroceryItem(
              id: gItem.key,
              name: gItem.value['name'],
              quantity: gItem.value['quantity'],
              category: category),
        );
      }

      setState(() {
        _groceryItemstoDisplay = itemsList;
        _isloading = false;
      });

    } catch (error) {
      setState(() {
        _error = 'SomeThing Went Wrong. Please try again later..';
      });
    }
  }

  void _addItem() async {
    final newgroceryItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newgroceryItem == null) {
      return;
    }

    setState(() {
      _groceryItemstoDisplay.add(newgroceryItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItemstoDisplay.indexOf(item);
    setState(() {
      _groceryItemstoDisplay.remove(item);
    });

    final url = Uri.https('groceries-app-b740c-default-rtdb.firebaseio.com',
        'grocerylist/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      //need to show snack bar
      setState(() {
        _groceryItemstoDisplay.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No Groceries Yet ... :)'));

    if (_isloading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItemstoDisplay.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItemstoDisplay.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItemstoDisplay[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItemstoDisplay[index]);
          },
          child: ListTile(
            title: Text(_groceryItemstoDisplay[index].name),
            iconColor: Colors.blue,
            leading: Container(
              color: _groceryItemstoDisplay[index].category.color,
              width: 20,
              height: 20,
            ),
            trailing: Text(
              _groceryItemstoDisplay[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: 
              Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("YOUR PURCHASE LIST"),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      body: content,
    );
  }
}
