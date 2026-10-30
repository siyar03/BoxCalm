enum VisualStyle {
  box('Box trace', 'A point travels the square'),
  circle('Breathing circle', 'A soft circle expands and contracts'),
  minimal('Minimal', 'Just the count and a quiet ring'),
  lotus('Lotus', 'Petals bloom with every inhale');

  const VisualStyle(this.label, this.description);
  final String label;
  final String description;

  static VisualStyle fromId(String? id) => values.firstWhere(
        (v) => v.name == id,
        orElse: () => VisualStyle.box,
      );
}
