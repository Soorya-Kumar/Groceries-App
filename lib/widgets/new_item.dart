import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:groceries_app/data/categories.dart';
import 'package:groceries_app/models/category.dart';
import 'package:groceries_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredname = "";
  var _enteredquantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveData() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });
      _formkey.currentState!.save();
      final url = Uri.https('groceries-app-b740c-default-rtdb.firebaseio.com',
          'grocerylist.json');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'name': _enteredname,
            'quantity': _enteredquantity.toDouble(),
            'category': _selectedCategory.title,
          },
        ),
      );

      final Map<String, dynamic> dResponse = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItem(
          id: dResponse['name'],
          name: _enteredname,
          quantity: _enteredquantity.toDouble(),
          category: _selectedCategory,
        ),
      );
    }
  }

  void _resetData() {
    _formkey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add a new Item"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        maxLength: 30,
                        initialValue: _enteredname,
                        decoration: const InputDecoration(
                          label: Text("Item Name"),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().length == 1 ||
                              value.trim().length > 50) {
                            return 'Must be between 1 and 50 characters long';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredname = newValue!;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        maxLength: 5,
                        initialValue: _enteredquantity.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text("Quantity"),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.parse(value) <= 0) {
                            return 'Must be a valid positive number';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enteredquantity = int.parse(newValue!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 300,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    height: 14,
                                    width: 14,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(category.value.title),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 100,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSending ? null : _resetData,
                      child: const Text("Reset Item"),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: _isSending ? null : _saveData,
                      child: _isSending
                          ? const Row(children: [Text("Submit"), CircularProgressIndicator(),],)
                          : const Text("Submit"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
