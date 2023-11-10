import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// for web add http: ^0.13.3 to dependeciens in pubspec.yaml, run : flutter pub get

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginSignupPage(),
    );
  }
}

class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoginForm = true;

  // Function to validate email format
  bool _isEmailValid(String email) {
    // Define a regular expression for a simple email format
    // This example checks for an '@' symbol and '.com'
    RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Function to handle login or signup logic
  void _handleLoginSignup() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validate the email format
    if (!_isEmailValid(email)) {
      // Display an error message using an alert dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Email'),
            content: Text('Please enter a valid email address.'),
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
      return; // Exit the function early if the email is invalid
    }

    // Add your authentication logic here
    String apiUrl = 'http://127.0.0.1:5000/flutter_auth';
    // Make a POST request to your backend with email and password
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'email': email,
          'password': password,
          '_isLoginForm': _isLoginForm.toString(),
        },
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Successful authentication
        // Standard HTTP status code for success
        final responseData = json.decode(response.body);
        final customStatusCode = responseData['status_code'];
        final customMessage = responseData['message'];

        // Succesfful Login
        if (customStatusCode == 1) {
          print(customMessage);
        } else if (customStatusCode == 2 || customStatusCode == 3) {
          // CustomCode 2 :  Email or password is incorrect, alert message
          // CustomCode 3 : Email exist in databas, alert message
          showCustomDialog(customMessage);
        }
        // Succesfful Sign Up
        else if (customStatusCode == 3) {
          print(customMessage);
        }
      } else {
        // Handle authentication failure
        print('Authentication failed: ${response.body}');
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
        title: Text(''),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _handleLoginSignup,
                child: Text(_isLoginForm ? 'Login' : 'Signup'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginForm = !_isLoginForm;
                  });
                },
                child: Text(
                  _isLoginForm
                      ? 'Create an account'
                      : 'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
