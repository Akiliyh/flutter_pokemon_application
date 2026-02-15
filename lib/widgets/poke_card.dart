import 'package:flutter/material.dart';
import '../api/pokemon_api.dart';

class PokeCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onLikeToggle;
  const PokeCard({
    super.key,
    required this.pokemon,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // in logical pixels
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.blue[500]),
      child: Row(
        children: [
          Image.network(
            pokemon.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image_not_supported);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 56,
                height: 56,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          ),

          const SizedBox(width: 12),

          IconButton(
            icon: Icon(
              pokemon.isFavorited
                  ? Icons.favorite
                  : Icons.favorite_border_outlined,
            ),
            tooltip: 'Like',
            onPressed: onLikeToggle,
          ),
          Text(pokemon.name, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
