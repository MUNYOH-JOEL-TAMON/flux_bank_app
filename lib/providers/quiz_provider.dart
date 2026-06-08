import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flux_bank/models/quiz_question.dart';
import 'package:flux_bank/screens/quiz/quiz_data.dart';

class QuizProvider extends ChangeNotifier {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isGameOver = false;
  int _timeLeft = 30;
  Timer? _timer;
  List<int?> _answerHistory = [];

  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  bool get isGameOver => _isGameOver;
  int get timeLeft => _timeLeft;
  List<int?> get answerHistory => _answerHistory;
  int get totalQuestions => _questions.length;
  bool get isAnswered => _selectedAnswerIndex != null;
  
  QuizQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return null;
    return _questions[_currentIndex];
  }

  String get grade {
    if (totalQuestions == 0) return 'F';
    final percentage = _score / totalQuestions;
    if (percentage >= 0.9) return 'A+';
    if (percentage >= 0.8) return 'A';
    if (percentage >= 0.7) return 'B';
    if (percentage >= 0.6) return 'C';
    return 'F';
  }

  void startQuiz() {
    _questions = List.from(kQuizQuestions)..shuffle();
    _currentIndex = 0;
    _score = 0;
    _selectedAnswerIndex = null;
    _isGameOver = false;
    _answerHistory = List.filled(_questions.length, null);
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        // Time's up
        _timer?.cancel();
        _selectedAnswerIndex = -1; // -1 indicates timeout
        _answerHistory[_currentIndex] = -1;
        notifyListeners();
        
        Future.delayed(const Duration(seconds: 2), () {
          nextQuestion();
        });
      }
    });
  }

  void selectAnswer(int index) {
    if (isAnswered) return;
    
    _timer?.cancel();
    _selectedAnswerIndex = index;
    _answerHistory[_currentIndex] = index;
    
    if (index == currentQuestion?.correctIndex) {
      _score++;
    }
    
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _selectedAnswerIndex = null;
      _startTimer();
    } else {
      _isGameOver = true;
      _timer?.cancel();
    }
    notifyListeners();
  }

  void resetQuiz() {
    _timer?.cancel();
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _selectedAnswerIndex = null;
    _isGameOver = false;
    _answerHistory = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
