import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';
import 'home_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _validateApiKey() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final apiKey = _apiKeyController.text.trim();
    final url = Uri.parse("https://superheroapi.com/api/$apiKey/1");

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['response'] == 'success') {
        // Save API key to local storage
        await DatabaseHelper.instance.saveApiKey(apiKey);

        // Proceed to Home Page
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(apiKey: apiKey)),
          );
        }
      } else {
        setState(() {
          _errorText = "Invalid API key.";
        });
      }
    } catch (e) {
      setState(() {
        _errorText = "An error occurred. Check your internet or API key.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login with API Key")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: "Enter Hero API Key",
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _validateApiKey,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
