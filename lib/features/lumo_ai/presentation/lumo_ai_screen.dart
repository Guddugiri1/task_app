import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// The primary screen for the LUMO AI feature, designed to capture user goals.
class LumoAiScreen extends StatelessWidget {
  const LumoAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // --- 1. Logo ---
            const _AiLogo(),
            const SizedBox(height: 48),

            // --- 2. Main Title ---
            Text(
              'What can I help you achieve?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.darkest,
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. Goal Input Field ---
            const _GoalInputField(),
            const SizedBox(height: 24),

            // --- 4. Suggestion Chips ---
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children: const [
                _SuggestionChip(text: 'Get Fit'),
                _SuggestionChip(text: 'Learn French'),
                _SuggestionChip(text: 'Build a portfolio'),
                _SuggestionChip(text: 'Launch my online store'),
                _SuggestionChip(text: 'Buy a house'),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- Reusable UI Widgets ---

/// Gradient AI Logo
class _AiLogo extends StatelessWidget {
  const _AiLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            AppColors.cornflowerBlue,
            AppColors.electricBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: const Icon(
        Icons.auto_awesome, // Sparkle icon
        color: Color(0xFFFFD700), // Gold
        size: 40,
      ),
    );
  }
}

/// Goal Input Field (without "Normal" dropdown)
class _GoalInputField extends StatelessWidget {
  const _GoalInputField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        hintText: 'Enter your goal',
        hintStyle: TextStyle(color: AppColors.darkest.withOpacity(0.7)),
        filled: true,
        fillColor: AppColors.cornflowerBlue.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        // Suffix Send Button
        suffixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.darkest,
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.darkest, width: 2),
        ),
      ),
    );
  }
}

/// Suggestion Chip
class _SuggestionChip extends StatelessWidget {
  final String text;
  const _SuggestionChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkest,
        backgroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.darkest.withOpacity(0.3)),
        ),
      ),
      child: Text(text),
    );
  }
}
