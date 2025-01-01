import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shorten URL'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Enter your url here',
                hintText: 'https://www.example.com',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 8,
                    color: Colors.black
                  )
                )
              ),
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
              onPressed: () async{
                final shortenedUrl = await shortenUrl(url: controller.text);
                if(shortenedUrl != null){
                  showDialog(
                      context: context,
                      builder: (context) {
                        return  AlertDialog(
                          title: const Text('Url Shortened Successfully'),
                          content: SizedBox(
                            height: 100,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if(await canLaunchUrl(shortenedUrl as Uri)){
                                          await launchUrl(shortenedUrl as Uri);
                                        }
                                      },
                                      child: Container(
                                        color: Colors.grey.withOpacity(.2),
                                        child: Text(shortenedUrl),
                                      ),
                                    ),
                                    IconButton(onPressed: (){
                                      Clipboard.setData(ClipboardData(text: shortenedUrl)).then((_) =>
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Urls is copied to the clipboard'))
                                      ));
                                    }, icon: const Icon(Icons.copy))
                                  ],
                                ),
                                ElevatedButton.icon(onPressed: (){
                                  controller.clear();
                                  Navigator.pop(context);
                                }, icon: const Icon(Icons.close), label: const Text('Close'))
                              ],
                            ),
                          ),
                        );
                      }
                  );
                }
              },
              child: const Text('Shorten url'),
            )
          ],
        ),
      ),
    );
  }

  Future<String?> shortenUrl({required String url}) async {
    try{
      final result = await http.post(
        Uri.parse('https://cleanuri.com/api/v1/shorten'),
        body: {
          'url': url
        }
      );

      if(result.statusCode == 200){
        final jsonResult = jsonDecode(result.body);
        return jsonResult['result_url'];
      }
    }catch (e){
      print('Error ${e.toString()}');
    }
    return null;
  }
}