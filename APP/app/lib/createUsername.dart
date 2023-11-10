// add image_picker: ^0.8.3 to dependencies in pubspec, run: flutter pub get

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(usernamePage());
}

class usernamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: usernamePageWidget(),
    );
  }
}

class usernamePageWidget extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<usernamePageWidget> {
  File? _image = File('./images/user.jpg');
  final picker = ImagePicker();
  TextEditingController _usernameController = TextEditingController();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // Function to handle username and PP
  void _handleUsernamePP() async {
    String username = _usernameController.text.trim();

    if (username.length < 4) {
      showCustomDialog("USername must be longer than four characters.");
      return;
    }

    // Add your authentication logic here
    String apiUrl = 'http://127.0.0.1:5000/flutter_usernamePP';

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    // Add form fields
    request.fields['username'] = username;

    // Add the file to the request
    var fileStream = http.ByteStream(Stream.castFrom(_image!.openRead()));
    var length = await _image?.length();

    var multipartFile = http.MultipartFile('image', fileStream, length ?? 0,
        filename: _image!.path.split('/').last);

    request.files.add(multipartFile);

    try {
      var response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        // Convert the streamed response to a string
        var responseBody = await response.stream.bytesToString();

        // Decode the response body using json.decode
        final responseData = json.decode(responseBody);
        final customStatusCode = responseData['status_code'];
        final customMessage = responseData['message'];

        // Succesfful Login
        if (customStatusCode == 5) {
          showCustomDialog(customMessage);
        } else {
          print(customMessage);
        }
      } else {
        print(response.statusCode);
        print('unSuccessfull');
      }
    } catch (e) {
      // Handle any network or server errors
      print('Error: $e');
    }
  }

  // Function to show a custom dialog
  void showCustomDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Placeholder(
                    fallbackHeight: 200,
                    fallbackWidth: double.infinity,
                  )
                : Image.file(
                    _image!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _handleUsernamePP();
                // You can also upload the image to your server here
                /*if (_image != null) {
                  // Upload logic for the image
                  print('Image path: ${_image!.path}');
                } */
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
