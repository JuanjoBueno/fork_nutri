import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import '../models/entities.dart';
import '../screens/screens.dart';

class SwiperFood extends StatefulWidget {
  final Usuario cliente;
  final IconData icon;
  final bool isSelectionMode;
  final Function(Recipe)? onRecipeSelect;
  final int? day;

  const SwiperFood({
    super.key,
    required this.icon,
    this.isSelectionMode = false,
    this.onRecipeSelect,
    required this.cliente,
    this.day,
  });

  @override
  State<SwiperFood> createState() => _SwiperFoodState();
}

class _SwiperFoodState extends State<SwiperFood> {
  int currentIndex = 0;

  void updateRecipe(Recipe newRecipe) {
    setState(() {
      widget.cliente.menu?.menusDiarios[currentIndex].recetas[currentIndex] =
          newRecipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Recipe> recetas =
        widget.cliente.menu?.menusDiarios[widget.day ?? 0].recetas ?? [];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child:
              _SwiperTimeFoodLabel(widget: widget, currentIndex: currentIndex),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            height: 200,
            child: Swiper(
              itemCount: recetas.length,
              onIndexChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return _SwiperImage(
                  widget: widget,
                  receta: recetas[index],
                  index: index,
                  onRecipeChanged: updateRecipe,
                  isSelectionMode: widget.isSelectionMode,
                  onRecipeSelect: widget.onRecipeSelect,
                  cliente: widget.cliente,
                );
              },
              pagination: SwiperPagination(
                builder: DotSwiperPaginationBuilder(
                  activeColor: const Color(0xFF00B894),
                  color: const Color(0xFF00B894).withAlpha(50),
                ),
              ),
              control: const SwiperControl(color: Color(0xFF00B894)),
            ),
          ),
        ),
        Text(
          recetas[currentIndex].name,
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 50, width: 330, child: const Divider()),
      ],
    );
  }
}

class _SwiperTimeFoodLabel extends StatelessWidget {
  const _SwiperTimeFoodLabel({
    required this.widget,
    required this.currentIndex,
  });

  final SwiperFood widget;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Text("");
  }
}

class _SwiperImage extends StatelessWidget {
  final Recipe receta;
  final int index;
  final Function(Recipe) onRecipeChanged;
  final bool isSelectionMode;
  final Function(Recipe)? onRecipeSelect;
  final Usuario cliente;

  const _SwiperImage(
      {required this.widget,
      required this.receta,
      required this.index,
      required this.onRecipeChanged,
      this.isSelectionMode = false,
      this.onRecipeSelect,
      required this.cliente});

  final SwiperFood widget;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {},
              child: FadeInImage(
                placeholder: const AssetImage('assets/images/loading.gif'),
                image: NetworkImage(receta.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
