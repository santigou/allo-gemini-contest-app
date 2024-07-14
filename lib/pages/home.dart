import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final TextEditingController _controller = TextEditingController();
  final List<String> randomTextList = [
    "Quiero prepararme para una entrevista como programador backend junior",
    "Voy a trabajar como mecero en Italia que necesito saber?",
    "Quiero aprender ingles para responder correctamente a mi profesor",
    "Tendre un examen oral en portuges, soy estudiante de universidad"
  ];
  String _apiResponse = "";

  void setRandomText(){
    final random = Random();
    final randomText = randomTextList[random.nextInt(randomTextList.length)];
    setState(() {
      _controller.text = randomText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // Menu
      drawer: const Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountEmail: Text("danielsantiago@gmail.com"),
              accountName: Text("Daniel Santiago"),
              currentAccountPicture: Icon(Icons.person),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("H O M E"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("S E T T I N G S"),
            ),
          ],
        ),
      ),

      //Cuadro de texto y botones
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'What do you want do learn...',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: setRandomText,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Random'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await GeminiApiCall();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _apiResponse,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),

    );
  }

  //TODO: Pasar este codigo al servicio
  //Call gemini api
  Future<void> GeminiApiCall() async {
    final String user_prompt = _controller.text;
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyDDaieCLfRwr9KUyHvC7XTF98Noka1GsLY');

    try {

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                //TODO: reemplazar con un buen prompt que retorne el camino a seguir por el usuario
                {'text': 'Hello'}
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final text = responseData['candidates'][0]['content']['parts'][0]['text'];
        print(text);
        setState(() {
          _apiResponse = text;
        });
      } else {
        _apiResponse = ('Failed to fetch API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: $e';
      });
    }
  }

}
