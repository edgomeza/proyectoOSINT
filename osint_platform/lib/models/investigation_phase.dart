enum InvestigationPhase {
  planning('Planificación', 'planning'),
  collection('Recopilación', 'collection'),
  processing('Procesamiento', 'processing'),
  analysis('Análisis', 'analysis'),
  reports('Informes', 'reports');

  final String displayName;
  final String routeName;

  const InvestigationPhase(this.displayName, this.routeName);

  int get indice => InvestigationPhase.values.indexOf(this);

  InvestigationPhase? get next {
    final currentIndex = InvestigationPhase.values.indexOf(this);
    if (currentIndex < InvestigationPhase.values.length - 1) {
      return InvestigationPhase.values[currentIndex + 1];
    }
    return null;
  }

  InvestigationPhase? get previous {
    final currentIndex = InvestigationPhase.values.indexOf(this);
    if (currentIndex > 0) {
      return InvestigationPhase.values[currentIndex - 1];
    }
    return null;
  }
}
