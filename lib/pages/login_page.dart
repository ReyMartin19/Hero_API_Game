import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database_helper.dart';
import 'home_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
            // ignore: use_build_context_synchronously
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 370),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Yo-Gi-Oh",
                      style: GoogleFonts.gruppo(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    Text(
                      "Battle with legendary heroes, collect cards, and become the ultimate champion in Yo-Gi-Oh Hero Game!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: const Color.fromARGB(137, 0, 0, 0),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _apiKeyController,
                      style: GoogleFonts.gruppo(),
                      decoration: InputDecoration(
                        labelText: "Enter Hero API Key",
                        labelStyle: GoogleFonts.gruppo(
                          fontWeight: FontWeight.w900,
                        ),
                        errorText: _errorText,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _validateApiKey,
                      style: ElevatedButton.styleFrom(
                        textStyle: GoogleFonts.gruppo(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                "Login",
                                style: GoogleFonts.gruppo(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
