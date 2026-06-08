import 'package:flux_bank/models/quiz_question.dart';

const List<QuizQuestion> kQuizQuestions = [
  QuizQuestion(
    question: 'What is compound interest?',
    options: [
      'Interest earned only on the original principal',
      'Interest earned on both principal and accumulated interest',
      'A flat fee charged by banks',
      'Interest that changes every month'
    ],
    correctIndex: 1,
    explanation: 'Compound interest is "interest on interest." It makes your money grow faster over time because you earn interest on both your initial deposit and the interest it has already earned.',
  ),
  QuizQuestion(
    question: 'How does inflation affect your money?',
    options: [
      'It increases your purchasing power',
      'It has no effect on your money',
      'It reduces your purchasing power over time',
      'It makes your savings grow faster'
    ],
    correctIndex: 2,
    explanation: 'Inflation is the general increase in prices. As prices go up, the same amount of money buys fewer goods and services, reducing your purchasing power.',
  ),
  QuizQuestion(
    question: 'Why is diversification important in investing?',
    options: [
      'It guarantees a high return',
      'It spreads your investments to reduce risk',
      'It eliminates taxes on your investments',
      'It allows you to invest only in one company'
    ],
    correctIndex: 1,
    explanation: 'Diversification means not putting all your eggs in one basket. By spreading investments across different assets, you reduce the risk of losing money if one investment performs poorly.',
  ),
  QuizQuestion(
    question: 'What does the 50/30/20 budgeting rule suggest?',
    options: [
      '50% savings, 30% needs, 20% wants',
      '50% needs, 30% wants, 20% savings',
      '50% wants, 30% savings, 20% needs',
      '50% investments, 30% taxes, 20% spending'
    ],
    correctIndex: 1,
    explanation: 'The 50/30/20 rule is a simple budgeting method: allocate 50% of your after-tax income to needs (rent, groceries), 30% to wants (hobbies, dining out), and 20% to savings or debt payoff.',
  ),
  QuizQuestion(
    question: 'How large should a typical emergency fund be?',
    options: [
      '1 month of living expenses',
      '1 year of your full salary',
      '3-6 months of living expenses',
      'Just enough to cover one unexpected bill'
    ],
    correctIndex: 2,
    explanation: 'Financial experts generally recommend keeping 3 to 6 months of essential living expenses in an easily accessible account to cover unexpected events like job loss or medical emergencies.',
  ),
  QuizQuestion(
    question: 'What is the primary purpose of mobile money services like MTN MoMo?',
    options: [
      'To play mobile games for money',
      'To send and receive money via mobile without a traditional bank account',
      'To buy mobile phones on credit',
      'To invest in the stock market directly'
    ],
    correctIndex: 1,
    explanation: 'Mobile money allows users to store, send, and receive funds using their mobile phone number, bridging the gap for people without access to traditional banking infrastructure.',
  ),
  QuizQuestion(
    question: 'What is a credit score used for?',
    options: [
      'To determine how much money you have',
      'To track your stock portfolio',
      'To assess your creditworthiness and risk as a borrower',
      'To calculate your annual income taxes'
    ],
    correctIndex: 2,
    explanation: 'A credit score is a number that represents your credit risk. Lenders use it to decide whether to give you a loan or credit card, and what interest rate to charge you.',
  ),
  QuizQuestion(
    question: 'What is a key difference between a savings account and a current (checking) account?',
    options: [
      'Current accounts earn higher interest',
      'Savings accounts typically earn interest while current accounts usually do not',
      'You cannot withdraw from a current account',
      'Savings accounts are only for businesses'
    ],
    correctIndex: 1,
    explanation: 'Current accounts are designed for everyday transactions and rarely pay interest. Savings accounts are designed to hold money you don\'t need immediately and pay interest to help your money grow.',
  ),
  QuizQuestion(
    question: 'In finance, what does "liquidity" refer to?',
    options: [
      'How quickly you can convert an asset to cash without losing value',
      'The amount of debt a company has',
      'The profit made from selling an investment',
      'A type of stock market index'
    ],
    correctIndex: 0,
    explanation: 'Liquidity describes how easily and quickly an asset can be bought or sold for cash. Cash is the most liquid asset, while real estate is considered illiquid because it takes time to sell.',
  ),
  QuizQuestion(
    question: 'How is your "Net Worth" calculated?',
    options: [
      'Total income minus total expenses',
      'Total assets minus total liabilities (debts)',
      'Your annual salary multiplied by your age',
      'The total value of your investments'
    ],
    correctIndex: 1,
    explanation: 'Net worth is what you own (assets) minus what you owe (liabilities). It is a key measure of your overall financial health.',
  ),
];
