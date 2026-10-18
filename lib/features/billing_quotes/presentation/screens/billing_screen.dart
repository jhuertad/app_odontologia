import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/billing_repository.dart';
import '../../domain/models/quote.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _repository = BillingRepository();

  @override
  Widget build(BuildContext context) {
    final quotes = _repository.getAllQuotes();
    final totalBudget = quotes.fold(0.0, (sum, q) => sum + q.total);
    final totalCollected = quotes.fold(0.0, (sum, q) => sum + q.paidAmount);
    final totalPending = totalBudget - totalCollected;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Presupuestos & Cobros', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            Text('Planes de tratamiento por fases y abonos', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen Financiero
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFinancialStat('TOTAL PRESUPUESTOS', '\$${totalBudget.toStringAsFixed(2)}', Colors.white),
                      _buildFinancialStat('RECAUDADO', '\$${totalCollected.toStringAsFixed(2)}', const Color(0xFF10B981)),
                      _buildFinancialStat('POR COBRAR', '\$${totalPending.toStringAsFixed(2)}', const Color(0xFFFFB703)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Planes de Tratamiento Activos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            ...quotes.map((q) => _buildQuoteCard(q)),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialStat(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildQuoteCard(Quote q) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final progress = q.total > 0 ? (q.paidAmount / q.total).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                q.patientName,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A896).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  q.status.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Color(0xFF00A896)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Creado el ${dateFormat.format(q.createdAt)}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          const Divider(height: 20),

          // Fases del presupuesto
          ...q.phases.map((phase) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        phase.title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF028090)),
                      ),
                      const Spacer(),
                      Text(
                        '\$${phase.phaseTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF028090)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...phase.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            item.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: item.isCompleted ? const Color(0xFF10B981) : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${item.toothNumber != null ? "Pieza ${item.toothNumber} • " : ""}${item.procedureName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: item.isCompleted ? Colors.grey : const Color(0xFF334155),
                                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          Text('\$${item.cost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),

          const Divider(height: 16),

          // Barra de progreso de pago
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Abonado: \$${q.paidAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
              Text('Pendiente: \$${q.balancePending.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE63946))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00A896)),
            ),
          ),
          const SizedBox(height: 14),

          // Botón registrar abono
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFF00A896)),
                ),
                icon: const Icon(Icons.add_card_rounded, size: 16, color: Color(0xFF00A896)),
                label: const Text('Registrar Abono', style: TextStyle(color: Color(0xFF00A896), fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => _showPaymentDialog(q),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Quote q) {
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Registrar Abono: ${q.patientName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo pendiente actual: \$${q.balancePending.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Color(0xFFE63946), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monto a Abonar (\$ USD)',
                prefixText: '\$ ',
                hintText: '50.00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00A896)),
            onPressed: () {
              final val = double.tryParse(amountCtrl.text.trim());
              if (val != null && val > 0) {
                _repository.recordPayment(q.id, val);
                setState(() {});
                Navigator.pop(ctx);
              }
            },
            child: const Text('Confirmar Pago'),
          ),
        ],
      ),
    );
  }
}
