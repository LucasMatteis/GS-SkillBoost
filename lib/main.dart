import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TimerProvider())],
      child: const SkillBoostApp(),
    ),
  );
}

class SkillBoostApp extends StatelessWidget {
  const SkillBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillBoost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
          primary: const Color(0xFF3F51B5),
          secondary: const Color(0xFF26C6DA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F51B5),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// --- GERENCIAMENTO DE ESTADO (TIMER) ---
class TimerProvider with ChangeNotifier {
  int _seconds = 1500;
  Timer? _timer;
  bool _isRunning = false;

  int get seconds => _seconds;
  bool get isRunning => _isRunning;

  String get timeString {
    int minutes = _seconds ~/ 60;
    int secs = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void startStopTimer() {
    if (_isRunning) {
      _stop();
    } else {
      _start();
    }
  }

  void resetTimer() {
    _stop();
    _seconds = 1500;
    notifyListeners();
  }

  void _start() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        _seconds--;
        notifyListeners();
      } else {
        _stop();
        _seconds = 1500;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void _stop() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// --- TELA PRINCIPAL COM NAVEGAÇÃO ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const LearningScreen(),
    const TimerScreen(),
    const MoodScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 133, 155, 255),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school, color: Color(0xFF3F51B5)),
              label: 'Aprender',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer, color: Color(0xFF3F51B5)),
              label: 'Foco',
            ),
            NavigationDestination(
              icon: Icon(Icons.mood_outlined),
              selectedIcon: Icon(Icons.mood, color: Color(0xFF3F51B5)),
              label: 'Humor',
            ),
          ],
        ),
      ),
    );
  }
}

// --- TELA 1: MICRO LEARNING ---
class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lessons = [
      {'title': 'Liderança Ágil', 'cat': 'Soft Skills', 'time': '2 min'},
      {'title': 'Introdução à IA', 'cat': 'Tech', 'time': '5 min'},
      {'title': 'Gestão de Tempo', 'cat': 'Produtividade', 'time': '3 min'},
      {
        'title': 'Comunicação Não-Violenta',
        'cat': 'Soft Skills',
        'time': '4 min',
      },
      {'title': 'Ética de Dados', 'cat': 'Tech', 'time': '6 min'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upskilling Diário"),
        // Borda arredondada no cabeçalho
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          return LessonCard(
            title: lessons[index]['title']!,
            category: lessons[index]['cat']!,
            time: lessons[index]['time']!,
          );
        },
      ),
    );
  }
}

// --- CARD INTELIGENTE ---
class LessonCard extends StatefulWidget {
  final String title;
  final String category;
  final String time;

  const LessonCard({
    super.key,
    required this.title,
    required this.category,
    required this.time,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 207, 207, 207),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF3F51B5)),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            "${widget.category} • ${widget.time}",
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey.shade400,
            size: 28,
          ),
          onPressed: () {
            setState(() {
              isCompleted = !isCompleted;
            });
          },
        ),
      ),
    );
  }
}

// --- TELA 2: TIMER ---
class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0), Color(0xFF7986CB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "MODO PRODUTIVIDADE",
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // relógio
              Text(
                timerProvider.timeString,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 80,
                  fontWeight: FontWeight.w200,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(height: 50),

              // botões estilizados
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TimerButton(
                    icon: timerProvider.isRunning
                        ? Icons.pause
                        : Icons.play_arrow,
                    label: timerProvider.isRunning ? "PAUSAR" : "INICIAR",
                    color: Colors.white,
                    textColor: const Color(0xFF3F51B5),
                    onPressed: timerProvider.startStopTimer,
                  ),
                  const SizedBox(width: 20),
                  _TimerButton(
                    icon: Icons.refresh,
                    label: "RESETAR",
                    color: Colors.white.withOpacity(0.2),
                    textColor: Colors.white,
                    onPressed: timerProvider.resetTimer,
                  ),
                ],
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text(
                  "25 min Foco • 5 min Pausa",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// botão customizado do timer
class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
    );
  }
}

// --- TELA 3: HUMOR ---
class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diário de Bordo"),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Olá, Colaborador!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Como você está se sentindo em relação ao seu trabalho hoje?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _MoodButton(
              emoji: "😰",
              label: "Estressado",
              color: const Color(0xFFFFCDD2),
              textColor: const Color(0xFFC62828),
            ),
            const SizedBox(height: 16),
            _MoodButton(
              emoji: "😐",
              label: "Normal",
              color: const Color(0xFFFFF9C4),
              textColor: const Color(0xFFFBC02D),
            ),
            const SizedBox(height: 16),
            _MoodButton(
              emoji: "😁",
              label: "Produtivo",
              color: const Color(0xFFC8E6C9),
              textColor: const Color(0xFF2E7D32),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final Color textColor;

  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Botão ocupa largura total
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.all(20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Registro salvo: $label. Obrigado!"),
              backgroundColor: textColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
