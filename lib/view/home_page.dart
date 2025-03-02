import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedTone;
  bool isGenerating = false;
  String showError = "";
  String generatedContent = "";
  TextEditingController emailContentController = TextEditingController();

  List<String> toneOptions = [
    'Friendly',
    'Professional',
    'Corporate',
    'Business',
  ];

  Future<void> handleSubmitButton(String emailContent, String? tone) async {
    if (emailContent.isEmpty) {
      setState(() {
        showError = "Email content cannot be empty";
      });
      return;
    }

    try {
      setState(() {
        isGenerating = true;
        showError = "";
      });

      var dio = Dio();
      Response response = await dio.post(
        "http://localhost:8080/api/email/generate",
        data: {"emailContent": emailContent, "tone": tone},
      );

      setState(() {
        generatedContent = response.toString() ?? "No response received.";
      });
    } catch (e) {
      setState(() {
        showError = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome to MailNimble")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Email Generator",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailContentController,
                maxLines: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Original Email Content",
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Tone (Optional)",
                ),
                items:
                    toneOptions
                        .map(
                          (tone) =>
                              DropdownMenuItem(value: tone, child: Text(tone)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTone = value;
                  });
                },
              ),
              SizedBox(height: 20),
              InkWell(
                onTap:
                    isGenerating
                        ? null
                        : () => handleSubmitButton(
                          emailContentController.text,
                          selectedTone,
                        ),
                child: Container(
                  padding: EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isGenerating ? Colors.grey : Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child:
                        isGenerating
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              "Generate Reply",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (showError.isNotEmpty)
                Text(showError, style: TextStyle(color: Colors.red)),
              if (generatedContent.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    generatedContent,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
