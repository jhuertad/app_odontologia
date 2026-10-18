import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../odontogram/presentation/screens/odontogram_screen.dart';
import '../../../appointments/presentation/screens/appointments_screen.dart';
import '../../../appointments/data/appointments_repository.dart';
import '../../../appointments/domain/models/appointment.dart';
import '../../../radiology/presentation/screens/radiology_screen.dart';
import '../../../consent/presentation/screens/consent_screen.dart';
import '../../../patients/presentation/screens/patients_screen.dart';
import '../../../billing_quotes/presentation/screens/billing_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AppointmentsRepository _repository = AppointmentsRepository();
  int? _selectedChair; // null means auto-detect most active

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,
      builder: (context, _) {
        final now = DateTime.now();
        final todayAppointments = _repository.getAppointmentsForDate(now);
        final activeApt = _repository.getActiveAppointment(preferredChair: _selectedChair);

        // Sillón appointments for tabs
        final sillon1Apt = _repository.getAppointmentForChair(1);
        final sillon2Apt = _repository.getAppointmentForChair(2);

        // Dynamic metrics
        final inWaitingCount = todayAppointments.where((a) => a.status == AppointmentStatus.inWaitingRoom).length;
        final inTreatmentCount = todayAppointments.where((a) => a.status == AppointmentStatus.inTreatment).length;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00A896), Color(0xFF028090)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00A896).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DentalCare Platform',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      'Dr. John Huerta • Clínica Odontológica',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Badge(
                    smallSize: 8,
                    backgroundColor: Color(0xFFE63946),
                    child: Icon(Icons.notifications_none_rounded, color: Color(0xFF334155), size: 22),
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Selector de Sillones & Tarjeta Hero Dinámica
                _buildHeroCard(activeApt, sillon1Apt, sillon2Apt),

                const SizedBox(height: 24),

                // 2. Métricas de la Clínica Dinámicas
                const Text(
                  'Resumen de la Jornada',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
                          );
                          setState(() {});
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: _buildMetricCard(
                          title: 'Citas Hoy',
                          value: '${todayAppointments.length} Pacientes',
                          badge: '$inWaitingCount en espera • $inTreatmentCount en sillón',
                          badgeColor: inTreatmentCount > 0 ? const Color(0xFF10B981) : const Color(0xFF028090),
                          icon: Icons.calendar_today_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BillingScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: _buildMetricCard(
                          title: 'Presupuestos',
                          value: '\$1,420',
                          badge: '94% aceptado',
                          badgeColor: const Color(0xFF10B981),
                          icon: Icons.attach_money_rounded,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 3. Módulos Clínicos (Grid Stitch)
                const Text(
                  'Módulos y Herramientas Clínicas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: [
                    _buildModuleTile(
                      context,
                      title: 'Odontograma Digital',
                      subtitle: 'Canvas FDI 32/20 con paleta interactiva',
                      badgeText: 'FDI ISO 3950',
                      icon: Icons.grid_view_rounded,
                      gradient: const [Color(0xFF00A896), Color(0xFF028090)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OdontogramScreen(
                              patientName: activeApt?.patientName,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildModuleTile(
                      context,
                      title: 'Agenda & Horarios',
                      subtitle: 'Citas, sillones y confirmación WhatsApp',
                      badgeText: 'Hoy ${todayAppointments.length} turnos',
                      icon: Icons.event_note_rounded,
                      gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
                        );
                        setState(() {});
                      },
                    ),
                    _buildModuleTile(
                      context,
                      title: 'Directorio de Pacientes',
                      subtitle: 'Fichas clínicas, DNI e historias SOAP',
                      badgeText: 'Historias',
                      icon: Icons.people_alt_rounded,
                      gradient: const [Color(0xFF028090), Color(0xFF00A896)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PatientsScreen()),
                        );
                      },
                    ),
                    _buildModuleTile(
                      context,
                      title: 'Visor Radiográfico',
                      subtitle: 'Periapicales, panorámicas y filtros RX',
                      badgeText: 'Cloudflare R2',
                      icon: Icons.filter_b_and_w_rounded,
                      gradient: const [Color(0xFF6366F1), Color(0xFF4338CA)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RadiologyScreen()),
                        );
                      },
                    ),
                    _buildModuleTile(
                      context,
                      title: 'Consentimiento Digital',
                      subtitle: 'Firma táctil biométrica y sellado PDF',
                      badgeText: 'Firma Legal',
                      icon: Icons.draw_rounded,
                      gradient: const [Color(0xFF10B981), Color(0xFF047857)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConsentScreen()),
                        );
                      },
                    ),
                    _buildModuleTile(
                      context,
                      title: 'Presupuestos & Cobros',
                      subtitle: 'Planes por fases, abonos y saldos',
                      badgeText: 'Financiero',
                      icon: Icons.receipt_long_rounded,
                      gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BillingScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(Appointment? activeApt, Appointment? s1Apt, Appointment? s2Apt) {
    if (activeApt == null) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sin Pacientes en Turno',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('No hay consultas activas en este momento.', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00A896)),
              icon: const Icon(Icons.calendar_today_rounded, size: 16),
              label: const Text('Ver Agenda Completa'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
                );
              },
            ),
          ],
        ),
      );
    }

    final isTreatment = activeApt.status == AppointmentStatus.inTreatment;
    final isWaiting = activeApt.status == AppointmentStatus.inWaitingRoom;
    final statusColor = isTreatment
        ? const Color(0xFF10B981)
        : (isWaiting ? const Color(0xFF028090) : const Color(0xFFF59E0B));
    final statusText = isTreatment
        ? 'EN ATENCIÓN • SILLÓN ${activeApt.chairNumber}'
        : (isWaiting
            ? 'EN ESPERA • SILLÓN ${activeApt.chairNumber}'
            : 'CONFIRMADA • SILLÓN ${activeApt.chairNumber}');
    final timeFormatted = DateFormat('hh:mm a').format(activeApt.startTime);
    final firstName = activeApt.patientName.split(' ').first;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de Sillones rápidos (Sillón 1 / Sillón 2)
          Row(
            children: [
              _buildChairPill(
                chairNum: 1,
                label: 'Sillón 1',
                sublabel: s1Apt != null ? s1Apt.patientName.split(' ').first : 'Libre',
                isActive: activeApt.chairNumber == 1,
                hasActivePatient: s1Apt?.status == AppointmentStatus.inTreatment,
                onTap: () {
                  setState(() => _selectedChair = 1);
                },
              ),
              const SizedBox(width: 8),
              _buildChairPill(
                chairNum: 2,
                label: 'Sillón 2',
                sublabel: s2Apt != null ? s2Apt.patientName.split(' ').first : 'Libre',
                isActive: activeApt.chairNumber == 2,
                hasActivePatient: s2Apt?.status == AppointmentStatus.inTreatment,
                onTap: () {
                  setState(() => _selectedChair = 2);
                },
              ),
              const Spacer(),
              Text(
                'Turno $timeFormatted',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Badge de Estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 4, backgroundColor: statusColor),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Nombre del Paciente Activo
          Text(
            activeApt.patientName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tratamiento: ${activeApt.reason}',
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 18),

          // Botones de Acción
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00A896),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                icon: const Icon(Icons.grid_view_rounded, size: 18),
                label: Text(
                  'Abrir Odontograma de $firstName',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OdontogramScreen(
                        patientName: activeApt.patientName,
                      ),
                    ),
                  );
                },
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                icon: const Icon(Icons.event_note_rounded, size: 18),
                label: const Text('Ver en Agenda', style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
                  );
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChairPill({
    required int chairNum,
    required String label,
    required String sublabel,
    required bool isActive,
    required bool hasActivePatient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF00A896) : Colors.white.withValues(alpha: 0.15),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 3.5,
              backgroundColor: hasActivePatient ? const Color(0xFF10B981) : Colors.white38,
            ),
            const SizedBox(width: 6),
            Text(
              '$label: $sublabel',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String badge,
    required Color badgeColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                title,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(icon, color: const Color(0xFF94A3B8), size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: TextStyle(color: badgeColor, fontWeight: FontWeight.w700, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
