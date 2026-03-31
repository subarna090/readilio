import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(height: 8),
              const Text('✨', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Unlock Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'More stories, more pages, more adventures!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Feature list
              ...[
                const _Feature(icon: '📸', text: 'Up to 20 pages per story'),
                const _Feature(icon: '♾️', text: 'Unlimited stories per week'),
                const _Feature(icon: '🔊', text: 'Premium voices'),
                const _Feature(icon: '💾', text: '30-day story retention'),
                const _Feature(icon: '🚫', text: 'Ad-free experience'),
              ],
              const Spacer(),
              // Pricing options
              _PricingOption(
                label: 'Monthly',
                price: '\$2.99 / month',
                onTap: () => _purchase(context, monthly: true),
              ),
              const SizedBox(height: 12),
              _PricingOption(
                label: 'Yearly — Save 44%!',
                price: '\$19.99 / year',
                isHighlighted: true,
                onTap: () => _purchase(context, monthly: false),
              ),
              const SizedBox(height: 16),
              Text(
                'Cancel anytime. Billed via Google Play.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _purchase(BuildContext context, {required bool monthly}) async {
    // TODO: Integrate RevenueCat for real purchase flow
    // For MVP: simulate purchase
    await Get.find<StorageService>().setPremium(true);
    Get.back();
    Get.snackbar(
      'Welcome to Premium! ✨',
      'You now have access to all features.',
      backgroundColor: AppColors.secondary,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _Feature extends StatelessWidget {
  final String icon;
  final String text;
  const _Feature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _PricingOption extends StatelessWidget {
  final String label;
  final String price;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _PricingOption({
    required this.label,
    required this.price,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primary : Colors.white12,
          borderRadius: BorderRadius.circular(16),
          border: isHighlighted
              ? null
              : Border.all(color: Colors.white30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            Text(price,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
