enum QuoteStatus {
  draft,
  presented,
  approved,
  inProgress,
  completed,
}

class QuoteItem {
  final String id;
  final int? toothNumber;
  final String? surface;
  final String procedureName;
  final double cost;
  final bool isCompleted;

  const QuoteItem({
    required this.id,
    this.toothNumber,
    this.surface,
    required this.procedureName,
    required this.cost,
    this.isCompleted = false,
  });

  QuoteItem copyWith({bool? isCompleted}) {
    return QuoteItem(
      id: id,
      toothNumber: toothNumber,
      surface: surface,
      procedureName: procedureName,
      cost: cost,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class QuotePhase {
  final int phaseNumber;
  final String title;
  final List<QuoteItem> items;

  const QuotePhase({
    required this.phaseNumber,
    required this.title,
    required this.items,
  });

  double get phaseTotal => items.fold(0.0, (sum, item) => sum + item.cost);
}

class Quote {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime createdAt;
  final List<QuotePhase> phases;
  final double discount;
  final double paidAmount;
  final QuoteStatus status;

  const Quote({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.createdAt,
    required this.phases,
    this.discount = 0.0,
    this.paidAmount = 0.0,
    this.status = QuoteStatus.approved,
  });

  double get subtotal => phases.fold(0.0, (sum, p) => sum + p.phaseTotal);
  double get total => subtotal - discount;
  double get balancePending => total - paidAmount;

  Quote copyWith({double? paidAmount, QuoteStatus? status}) {
    return Quote(
      id: id,
      patientId: patientId,
      patientName: patientName,
      createdAt: createdAt,
      phases: phases,
      discount: discount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
    );
  }
}
