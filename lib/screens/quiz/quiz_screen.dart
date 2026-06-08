import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flux_bank/providers/quiz_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';
import 'package:flux_bank/widgets/flux_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    return Scaffold(
      backgroundColor: AppColors.shell,
      appBar: AppBar(
        title: const Text('Financial Quiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: quiz.isGameOver
          ? _buildGameOver(context, quiz)
          : (quiz.questions.isEmpty ? const Center(child: CircularProgressIndicator()) : _buildQuiz(context, quiz)),
    );
  }

  Widget _buildQuiz(BuildContext context, QuizProvider quiz) {
    final question = quiz.currentQuestion!;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${quiz.currentIndex + 1}/${quiz.totalQuestions}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: quiz.timeLeft <= 5 ? AppColors.debit : AppColors.quizPurple),
                      const SizedBox(width: 6),
                      Text(
                        '00:${quiz.timeLeft.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: quiz.timeLeft <= 5 ? AppColors.debit : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            LinearProgressIndicator(
              value: (quiz.currentIndex) / quiz.totalQuestions,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.quizPurple),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            
            const SizedBox(height: 40),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      question.question,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ).animate(key: ValueKey(quiz.currentIndex)).fadeIn().slideX(begin: 0.1, end: 0),
                    
                    const SizedBox(height: 40),
                    
                    ...List.generate(question.options.length, (index) {
                      final isSelected = quiz.selectedAnswerIndex == index;
                      final isCorrect = index == question.correctIndex;
                      final showCorrect = quiz.isAnswered && isCorrect;
                      final showWrong = quiz.isAnswered && isSelected && !isCorrect;
                      
                      Color bgColor = AppColors.surface;
                      Color borderColor = AppColors.divider;
                      Color textColor = AppColors.textPrimary;
                      
                      if (showCorrect) {
                        bgColor = AppColors.credit.withValues(alpha: 0.1);
                        borderColor = AppColors.credit;
                        textColor = AppColors.credit;
                      } else if (showWrong) {
                        bgColor = AppColors.debit.withValues(alpha: 0.1);
                        borderColor = AppColors.debit;
                        textColor = AppColors.debit;
                      } else if (isSelected) {
                        bgColor = AppColors.quizPurple.withValues(alpha: 0.1);
                        borderColor = AppColors.quizPurple;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () => quiz.selectAnswer(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    question.options[index],
                                    style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                if (showCorrect)
                                  const Icon(Icons.check_circle, color: AppColors.credit)
                                else if (showWrong)
                                  const Icon(Icons.cancel, color: AppColors.debit)
                              ],
                            ),
                          ),
                        ),
                      ).animate(key: ValueKey('${quiz.currentIndex}_$index')).fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1, end: 0);
                    }),
                    
                    if (quiz.isAnswered) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.lightbulb_outline, color: AppColors.blue, size: 20),
                                SizedBox(width: 8),
                                Text('Explanation', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question.explanation,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (quiz.isAnswered)
              FluxButton(
                quiz.currentIndex == quiz.totalQuestions - 1 ? 'See Results' : 'Next Question',
                onPressed: () => quiz.nextQuestion(),
                variant: FluxButtonVariant.primary,
              ).animate().fadeIn().slideY(begin: 0.2, end: 0)
            else
              const SizedBox(height: 52), // placeholder to prevent layout jump
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context, QuizProvider quiz) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.quizPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_outlined, color: AppColors.quizPurple, size: 64),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 32),
            
            const Text(
              'Quiz Completed!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 40),
            
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('YOUR SCORE', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${quiz.score} / ${quiz.totalQuestions}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 48, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Grade:', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        quiz.grade,
                        style: TextStyle(
                          color: quiz.grade == 'F' ? AppColors.debit : AppColors.credit,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 40),
            
            FluxButton(
              'Play Again',
              onPressed: () => quiz.startQuiz(),
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 16),
            
            FluxButton(
              'Back to Dashboard',
              variant: FluxButtonVariant.ghost,
              onPressed: () {
                quiz.resetQuiz();
                Navigator.pop(context);
              },
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
