import 'dart:convert';

import 'package:basic_todo/pages/edit_todo_page.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart';
import 'package:iconly/iconly.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  //Swap AddTodo and EditTodo

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Todo '),
        ),
        //Show loading circle if the data is loading
        body: Visibility(
          visible: isLoading,
          child: Center(
            child: CircularProgressIndicator(),
          ),
          replacement: RefreshIndicator(
            onRefresh: fetchTodo,
            //If data not found this will show up
            child: Visibility(
              visible: items.isNotEmpty,
              replacement: Center(
                  child: Text(
                'Data Empty',
                style: Theme.of(context).textTheme.headlineLarge,
              )),
              child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index] as Map;
                    final id = item['_id'] as String;
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 12, right: 12, top: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Colors.black38,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(item['title']),
                          subtitle: Text(item['description']),
                          trailing: PopupMenuButton(onSelected: (value) {
                            if (value == 'edit') {
                              navigatorToEditPage(item);
                            } else if (value == 'delete') {
                              deleteById(id);
                            }
                          }, itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                child: Text('Edit'),
                                value: 'edit',
                              ),
                              PopupMenuItem(
                                child: Text('Delete'),
                                value: 'delete',
                              )
                            ];
                          }),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            navigatorToAddPage();
          },
          backgroundColor: Colors.amber,
          label: const Text('Add'),
          icon: Icon(Icons.library_add),
        ),
      ),
    );
  }

  Future<void> fetchTodo() async {
    try {
      final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map;
        final result = json['items'] as List;
        setState(() {
          items = result;
        });
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      showErrorMessage('Try Agin');
    }
  }

  Future<void> navigatorToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => EditTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigatorToAddPage() async {
    //start when go to EditTodoPage()
    final route = MaterialPageRoute(builder: (context) => EditTodoPage());

    //It will refresh after go back
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(String id) async {
    //Write $id แทน เลข id ต่อท้าย
    try {
      final url = 'https://api.nstack.in/v1/todos/$id';
      final uri = Uri.parse(url);

      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        // Show the item if it not the same id that we delete
        final filtered =
            items.where((element) => element['_id'] != id).toList();
        setState(() {
          items = filtered;
        });
        showSuccessMessage('Delete success');
      }
    } catch (e) {
      showErrorMessage('Try Agin');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.amber,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: HexColor('#DC5500'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
