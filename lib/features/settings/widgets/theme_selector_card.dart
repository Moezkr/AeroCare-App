import 'package:flutter/material.dart';
import '../../../providers/theme_provider.dart';

class _ThemeOption {
  final AppThemeMode mode;
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;

  const _ThemeOption({
    required this.mode,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accent,
  });
}

const List<_ThemeOption> _themes = [
  _ThemeOption(
    mode: AppThemeMode.light,
    label: 'Bleu Classique',
    subtitle: 'Propre & professionnel',
    icon: Icons.water_drop_rounded,
    gradient: [Color(0xFF3B82F6), Color(0xFF93C5FD), Color(0xFFDBEAFE)],
    accent: Color(0xFF3B82F6),
  ),
  _ThemeOption(
    mode: AppThemeMode.dark,
    label: 'Gris Doux',
    subtitle: 'Élégant & neutre',
    icon: Icons.cloud_rounded,
    gradient: [Color(0xFF64748B), Color(0xFF94A3B8), Color(0xFFCBD5E1)],
    accent: Color(0xFF64748B),
  ),
  _ThemeOption(
    mode: AppThemeMode.midnight,
    label: 'Bleu Ciel',
    subtitle: 'Doux & apaisant',
    icon: Icons.air_rounded,
    gradient: [Color(0xFF6366F1), Color(0xFFA5B4FC), Color(0xFFE0E7FF)],
    accent: Color(0xFF6366F1),
  ),
  _ThemeOption(
    mode: AppThemeMode.mint,
    label: 'Menthe Douce',
    subtitle: 'Frais & vivifiant',
    icon: Icons.spa_rounded,
    gradient: [Color(0xFF10B981), Color(0xFF6EE7B7), Color(0xFFD1FAE5)],
    accent: Color(0xFF10B981),
  ),
  _ThemeOption(
    mode: AppThemeMode.ruby,
    label: 'Rose Poudré',
    subtitle: 'Doux & chaleureux',
    icon: Icons.favorite_rounded,
    gradient: [Color(0xFFF43F5E), Color(0xFFFDA4AF), Color(0xFFFFE4E6)],
    accent: Color(0xFFF43F5E),
  ),
  _ThemeOption(
    mode: AppThemeMode.amethyst,
    label: 'Lilas Doux',
    subtitle: 'Mystérieux & créatif',
    icon: Icons.auto_awesome_rounded,
    gradient: [Color(0xFFA855F7), Color(0xFFD8B4FE), Color(0xFFF3E8FF)],
    accent: Color(0xFFA855F7),
  ),
  _ThemeOption(
    mode: AppThemeMode.forest,
    label: 'Vert Sauge',
    subtitle: 'Nature & sérénité',
    icon: Icons.eco_rounded,
    gradient: [Color(0xFF059669), Color(0xFF6EE7B7), Color(0xFFD1FAE5)],
    accent: Color(0xFF059669),
  ),
  _ThemeOption(
    mode: AppThemeMode.coffee,
    label: 'Crème Vanille',
    subtitle: 'Chaud & confortable',
    icon: Icons.coffee_maker_rounded,
    gradient: [Color(0xFFD97706), Color(0xFFFCD34D), Color(0xFFFEF3C7)],
    accent: Color(0xFFD97706),
  ),
];

class ThemeSelectorCard extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ThemeSelectorCard({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _themes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
        ),
        itemBuilder: (context, index) {
          final t = _themes[index];
          final isSelected = themeProvider.currentMode == t.mode;
          return _ThemeTile(
            option: t,
            isSelected: isSelected,
            onTap: () => themeProvider.setTheme(t.mode),
          );
        },
      ),
    );
  }
}

class _ThemeTile extends StatefulWidget {
  final _ThemeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ThemeTile> createState() => _ThemeTileState();
}

class _ThemeTileState extends State<_ThemeTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.option;
    final bool sel = widget.isSelected;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: t.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: sel ? t.accent : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: t.accent.withOpacity(0.45),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -8,
                bottom: -8,
                child: Icon(
                  t.icon,
                  size: 70,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: Icon(t.icon, size: 18, color: Colors.white),
                    ),

                    const Spacer(),

                    Text(
                      t.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 10,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),

              if (sel)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: t.accent.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(Icons.check_rounded, size: 14, color: t.accent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
