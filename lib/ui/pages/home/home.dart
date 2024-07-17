import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gemini_proyect/domain/services/api_service.dart';

class Home extends StatefulWidget {
  final ApiService apiService;
  const Home({super.key, required this.apiService});

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
                    onPressed: _callApi,
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
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Future<void> _callApi() async{
    final prompt = _controller.text;
    final response = await widget.apiService.geminiApiCall(prompt);
    //TODO: eliminar print
    print(response);
    setState(() {
      _apiResponse = response;
    });
  }

}
