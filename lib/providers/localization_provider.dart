import 'package:flutter/material.dart';

class LocalizationProvider with ChangeNotifier {
  String _locale = 'en'; // default to English

  String get locale => _locale;

  void toggleLanguage() {
    _locale = _locale == 'en' ? 'fr' : 'en';
    notifyListeners();
  }

  void setLanguage(String lang) {
    if (_locale != lang) {
      _locale = lang;
      notifyListeners();
    }
  }

  String t(String key) {
    if (_locale == 'fr') {
      return _fr[key] ?? _en[key] ?? key;
    }
    return _en[key] ?? key;
  }

  // --- ENGLISH DICTIONARY ---
  static const Map<String, String> _en = {
    // Splash
    'banking_reimagined': 'Banking Reimagined',

    // Onboarding
    'bank_grade_security': 'Bank-Grade Security',
    'bank_grade_security_desc': 'Your money is protected with end-to-end encryption and multi-factor authentication.',
    'instant_transfers': 'Instant Transfers',
    'instant_transfers_desc': 'Send money to anyone instantly — via bank transfer, MTN MoMo, or Orange Money.',
    'smart_analytics': 'Smart Analytics',
    'smart_analytics_desc': 'Visualize your spending patterns and take control of your financial future.',
    'skip': 'Skip',
    'next': 'Next',
    'get_started': 'Get Started',

    // Login
    'welcome_back': 'Welcome back',
    'sign_in_to_flux': 'Sign in to your FLUX account',
    'email': 'Email',
    'email_hint': 'Enter your email',
    'password': 'Password',
    'password_hint': 'Enter your password',
    'forgot_password_q': 'Forgot password?',
    'sign_up': 'Sign Up',
    'sign_in': 'Sign In',
    'or': 'Or',
    'continue_google': 'Continue with Google',
    'continue_apple': 'Continue with Apple',
    'email_required': 'Email is required',
    'invalid_email': 'Enter a valid email',
    'password_required': 'Password is required',

    // Register
    'create_account': 'Create Account',
    'join_flux': 'Join FLUX',
    'setup_free_account': 'Set up your free account in seconds',
    'full_name': 'Full Name',
    'full_name_hint': 'Enter your full name',
    'name_required': 'Name is required',
    'name_invalid': 'Enter your first and last name',
    'phone_number': 'Phone Number',
    'phone_number_hint': 'Enter your phone number',
    'create_password_hint': 'Create a password',
    'password_min_length': 'Password must be at least 6 characters',
    'confirm_password': 'Confirm Password',
    'confirm_password_hint': 'Confirm your password',
    'passwords_not_match': 'Passwords do not match',
    'already_have_account': 'Already have an account? ',

    // Forgot Password
    'reset_password': 'Reset Password',
    'check_inbox': 'Check your inbox',
    'reset_link_sent': 'We sent a password reset link to\n',
    'back_to_sign_in': 'Back to Sign In',
    'forgot_password_title': 'Forgot your password?',
    'forgot_password_desc': 'Enter the email address associated with your account and we will send you a link to reset your password.',
    'send_reset_link': 'Send Reset Link',

    // Home & Cards
    'hello': 'Hello, ',
    'total_balance': 'Total Balance',
    'account': 'ACCOUNT',
    'holder': 'HOLDER',
    'valid': 'VALID',
    'cardholder': 'CARDHOLDER',
    'top_up': 'Top Up',
    'transfer': 'Transfer',
    'analytics': 'Analytics',
    'quiz': 'Quiz',
    'my_card': 'My Card',
    'activity': 'Activity',
    'in': 'In',
    'out': 'Out',
    'transactions': 'Transactions',
    'see_all': 'See all',
    'no_recent_transactions': 'No recent transactions.',
  };

  // --- FRENCH DICTIONARY ---
  static const Map<String, String> _fr = {
    // Splash
    'banking_reimagined': 'La Banque Réinventée',

    // Onboarding
    'bank_grade_security': 'Sécurité Bancaire',
    'bank_grade_security_desc': 'Votre argent est protégé par un chiffrement de bout en bout et une authentification multifacteur.',
    'instant_transfers': 'Transferts Instantanés',
    'instant_transfers_desc': 'Envoyez de l\'argent instantanément — par virement bancaire, MTN MoMo ou Orange Money.',
    'smart_analytics': 'Analyses Intelligentes',
    'smart_analytics_desc': 'Visualisez vos dépenses et prenez le contrôle de votre avenir financier.',
    'skip': 'Passer',
    'next': 'Suivant',
    'get_started': 'Commencer',

    // Login
    'welcome_back': 'Bon retour',
    'sign_in_to_flux': 'Connectez-vous à votre compte FLUX',
    'email': 'E-mail',
    'email_hint': 'Entrez votre e-mail',
    'password': 'Mot de passe',
    'password_hint': 'Entrez votre mot de passe',
    'forgot_password_q': 'Mot de passe oublié ?',
    'sign_up': "S'inscrire",
    'sign_in': 'Se connecter',
    'or': 'Ou',
    'continue_google': 'Continuer avec Google',
    'continue_apple': 'Continuer avec Apple',
    'email_required': 'L\'e-mail est requis',
    'invalid_email': 'Entrez un e-mail valide',
    'password_required': 'Le mot de passe est requis',

    // Register
    'create_account': 'Créer un compte',
    'join_flux': 'Rejoindre FLUX',
    'setup_free_account': 'Configurez votre compte gratuit en quelques secondes',
    'full_name': 'Nom complet',
    'full_name_hint': 'Entrez votre nom complet',
    'name_required': 'Le nom est requis',
    'name_invalid': 'Entrez votre prénom et nom',
    'phone_number': 'Numéro de téléphone',
    'phone_number_hint': 'Entrez votre numéro de téléphone',
    'create_password_hint': 'Créer un mot de passe',
    'password_min_length': 'Le mot de passe doit comporter au moins 6 caractères',
    'confirm_password': 'Confirmer le mot de passe',
    'confirm_password_hint': 'Confirmez votre mot de passe',
    'passwords_not_match': 'Les mots de passe ne correspondent pas',
    'already_have_account': 'Vous avez déjà un compte ? ',

    // Forgot Password
    'reset_password': 'Réinitialiser le mot de passe',
    'check_inbox': 'Vérifiez votre boîte de réception',
    'reset_link_sent': 'Nous avons envoyé un lien de réinitialisation à\n',
    'back_to_sign_in': 'Retour à la connexion',
    'forgot_password_title': 'Mot de passe oublié ?',
    'forgot_password_desc': 'Saisissez l\'adresse e-mail associée à votre compte et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
    'send_reset_link': 'Envoyer le lien',

    // Home & Cards
    'hello': 'Bonjour, ',
    'total_balance': 'Solde Total',
    'account': 'COMPTE',
    'holder': 'TITULAIRE',
    'valid': 'VALIDE',
    'cardholder': 'TITULAIRE DE LA CARTE',
    'top_up': 'Recharger',
    'transfer': 'Transférer',
    'analytics': 'Analyses',
    'quiz': 'Quiz',
    'my_card': 'Ma Carte',
    'activity': 'Activité',
    'in': 'Entrée',
    'out': 'Sortie',
    'transactions': 'Transactions',
    'see_all': 'Voir tout',
    'no_recent_transactions': 'Aucune transaction récente.',
  };
}
