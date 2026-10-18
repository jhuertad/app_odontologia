import '../domain/models/quote.dart';

class BillingRepository {
  static final BillingRepository _instance = BillingRepository._internal();
  factory BillingRepository() => _instance;
  BillingRepository._internal() {
    _initSampleData();
  }

  final List<Quote> _quotes = [];

  void _initSampleData() {
    if (_quotes.isNotEmpty) return;
    final now = DateTime.now();

    _quotes.addAll([
      Quote(
        id: 'q-1',
        patientId: 'p-1',
        patientName: 'Camila Ramos Vega',
        createdAt: now.subtract(const Duration(days: 7)),
        status: QuoteStatus.approved,
        paidAmount: 110.0,
        discount: 20.0,
        phases: const [
          QuotePhase(
            phaseNumber: 1,
            title: 'Fase 1: Higiene & Operatoria Básica',
            items: [
              QuoteItem(id: 'qi-1', toothNumber: null, procedureName: 'Destartraje Ultrasónico & Profilaxis', cost: 45.0, isCompleted: true),
              QuoteItem(id: 'qi-2', toothNumber: 16, surface: 'OM', procedureName: 'Restauración Estética con Resina 3M Filtek', cost: 65.0, isCompleted: true),
              QuoteItem(id: 'qi-3', toothNumber: 21, surface: 'V', procedureName: 'Restauración Estética Incisal Resina', cost: 55.0, isCompleted: false),
            ],
          ),
          QuotePhase(
            phaseNumber: 2,
            title: 'Fase 2: Estética y Blanqueamiento',
            items: [
              QuoteItem(id: 'qi-4', toothNumber: null, procedureName: 'Blanqueamiento Dental LED en Consultorio', cost: 180.0, isCompleted: false),
            ],
          ),
        ],
      ),
      Quote(
        id: 'q-2',
        patientId: 'p-2',
        patientName: 'Marcos Delgado Solís',
        createdAt: now.subtract(const Duration(days: 4)),
        status: QuoteStatus.inProgress,
        paidAmount: 150.0,
        discount: 0.0,
        phases: const [
          QuotePhase(
            phaseNumber: 1,
            title: 'Fase 1: Terapia Endodóntica',
            items: [
              QuoteItem(id: 'qi-5', toothNumber: 36, procedureName: 'Endodoncia Mecanizada Multirradicular Molar', cost: 150.0, isCompleted: true),
            ],
          ),
          QuotePhase(
            phaseNumber: 2,
            title: 'Fase 2: Rehabilitación Protésica',
            items: [
              QuoteItem(id: 'qi-6', toothNumber: 36, procedureName: 'Perno de Fibra de Vidrio + Muñón', cost: 70.0, isCompleted: false),
              QuoteItem(id: 'qi-7', toothNumber: 36, procedureName: 'Corona Cerámica Monolítica en Zirconio', cost: 280.0, isCompleted: false),
            ],
          ),
        ],
      ),
    ]);
  }

  List<Quote> getAllQuotes() => List.unmodifiable(_quotes);

  Quote? getQuoteById(String id) {
    try {
      return _quotes.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  void recordPayment(String quoteId, double amount) {
    final idx = _quotes.indexWhere((q) => q.id == quoteId);
    if (idx != -1) {
      final current = _quotes[idx];
      final newPaid = current.paidAmount + amount;
      final newStatus = newPaid >= current.total ? QuoteStatus.completed : QuoteStatus.inProgress;
      _quotes[idx] = current.copyWith(paidAmount: newPaid, status: newStatus);
    }
  }
}
