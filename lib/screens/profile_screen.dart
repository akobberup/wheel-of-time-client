import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// Profil skærm hvor brugeren kan se og redigere deres profil information.
/// Viser navn, email og profil billede.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
        ),
        body: const Center(
          child: Text('Ingen bruger data tilgængelig'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 24),

          // Profil avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    _getInitials(user.name),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                      onPressed: () {
                        // TODO: Implementer billede upload
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Billede upload kommer snart'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Implementer billede upload
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Billede upload kommer snart'),
                  ),
                );
              },
              child: const Text('Tryk for at ændre billede'),
            ),
          ),

          const SizedBox(height: 40),

          // Personlig information sektion
          Text(
            'PERSONLIG INFORMATION',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),

          const SizedBox(height: 16),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Navn
                  TextFormField(
                    initialValue: user.name,
                    decoration: const InputDecoration(
                      labelText: 'Navn',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    readOnly: true, // TODO: Gør redigerbar når backend endpoint er klar
                  ),

                  const SizedBox(height: 16),

                  // Email (kun læsbar)
                  TextFormField(
                    initialValue: user.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      helperText: 'Email kan ikke ændres',
                    ),
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Gem knap (deaktiveret indtil backend er klar)
          FilledButton.icon(
            onPressed: null, // TODO: Aktiver når backend endpoint er klar
            icon: const Icon(Icons.save),
            label: const Text('Gem ændringer'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Profil redigering kommer snart',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Henter initialer fra fuldt navn (f.eks. "John Doe" -> "JD")
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}
