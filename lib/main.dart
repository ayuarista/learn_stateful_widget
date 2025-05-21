import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contoh Input User',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: UserInputPage(onToggleTheme: toggleTheme, themeMode: _themeMode),
    );
  }
}

class UserInputPage extends StatefulWidget {
  final void Function(bool) onToggleTheme;
  final ThemeMode themeMode;

  const UserInputPage({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<UserInputPage> createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage> {
  final TextEditingController _controller = TextEditingController();
  String _displayText = '';
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadSavedText();
  }

  Future<void> _loadSavedText() async {
    final prefs = await SharedPreferences.getInstance();
    final savedText = prefs.getString('saved_text') ?? '';
    final savedHistory = prefs.getStringList('history') ?? [];
    setState(() {
      _displayText = savedText;
      _controller.text = savedText;
      _history = savedHistory;
    });
  }

  Future<void> _saveText(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_text', text);
    if (!_history.contains(text) && text.trim().isNotEmpty) {
      _history.add(text);
      await prefs.setStringList('history', _history);
    }
    _showSnackbar('Teks berhasil disimpan!');
  }

  Future<void> _reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_text');
    await prefs.remove('history');
    setState(() {
      _controller.clear();
      _displayText = '';
      _history.clear();
    });
    _showSnackbar('Data berhasil direset.');
  }

  void _showText() {
    final input = _controller.text.trim();
    if (input.isNotEmpty) {
      setState(() {
        _displayText = input;
      });
      _saveText(input);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _toggleTheme(bool value) {
    widget.onToggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input User'),
        actions: [
          Switch(
            value: isDarkMode,
            onChanged: _toggleTheme,
            activeColor: Colors.amber,
            inactiveThumbColor: Colors.grey,
          ),
          IconButton(
            onPressed: _reset,
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Reset Semua',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Masukkan Teks',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showText,
              icon: const Icon(Icons.send),
              label: const Text('Tampilkan Teks'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            if (_displayText.isNotEmpty)
              Card(
                elevation: 3,
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Teks: $_displayText',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            const SizedBox(height: 30),
            if (_history.isNotEmpty) ...[
              Text(
                'Riwayat Teks:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              ..._history.reversed.map((text) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(text),
                  )),
            ]
          ],
        ),
      ),
    );
  }
}
