import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;

class EditTodoPage extends StatefulWidget {
  final Map? todo;
  EditTodoPage({super.key, this.todo});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Check here what user use edit or add button
    final todo = widget.todo;
    //Prefill if todo is not null
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              //Change Title
              isEdit ? 'Edit Todo' : 'Add Todo'),
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: 'Description'),
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 8,
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: isEdit ? updateData : submitData,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    isEdit ? 'Update' : 'Submit',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateData() async {
    //Get data from previous form
    final todo = widget.todo;
    if (todo == null) {
      //To check if someone call this by mitake
      print('You can not call update without todo data');
      return;
    }
    final id = todo['_id'];
    //final isCompleted = todo['is_completed'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      // "is_completed": false
    };

    try {
      //Update data to server
      final url = 'https://api.nstack.in/v1/todos/$id';
      //convert url to uri
      final uri = Uri.parse(url);
      final response = await http.put(
        uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      //Show submit status
      if (response.statusCode == 200) {
        //after send data it will clear textfield
        titleController.text = '';
        descriptionController.text = '';
        showSuccessMessage('Update Success');
        Navigator.pop(context);
      }
    } catch (e) {
      showErrorMessage('Update Error');
    }
  }

  Future<void> submitData() async {
    //Get Data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    try {
      final url = 'https://api.nstack.in/v1/todos';
      //convert url to uri
      final uri = Uri.parse(url);
      final response = await http.post(uri,
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'});
      //Show submit status
      if (response.statusCode == 201) {
        //after send data it will clear textfield
        titleController.text = '';
        descriptionController.text = '';
        showSuccessMessage('Success');
      }
    } catch (e) {
      showErrorMessage('Error');
    }
    //submit data to server
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.amber,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.pop(context);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: HexColor('#DC5500'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
