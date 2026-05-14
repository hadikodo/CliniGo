import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/prescription.dart';
import '../../../core/constants/theme.dart';
import 'prescription_preview_dialog.dart';
import 'package:flutter/services.dart';

class PrescriptionPage extends ConsumerStatefulWidget {
  final String patientId;
  final String appointmentId;

  const PrescriptionPage({
    super.key,
    required this.patientId,
    required this.appointmentId,
  });

  @override
  ConsumerState<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends ConsumerState<PrescriptionPage> {
  final List<Medicine> _medicines = [];
  
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _freqCtrl = TextEditingController();
  final _durCtrl = TextEditingController();

  final List<Medicine> _favorites = [
    Medicine(name: 'Amoxicillin', dosage: '500mg', frequency: '3x/day', duration: '7 days'),
    Medicine(name: 'Panadol', dosage: '1000mg', frequency: 'As needed', duration: '3 days'),
    Medicine(name: 'Augmentin', dosage: '625mg', frequency: '2x/day', duration: '5 days'),
  ];

  void _addMedicine() {
    if (_nameCtrl.text.isEmpty) return;
    setState(() {
      _medicines.add(Medicine(
        name: _nameCtrl.text.trim(),
        dosage: _dosageCtrl.text.trim(),
        frequency: _freqCtrl.text.trim(),
        duration: _durCtrl.text.trim(),
      ));
      _nameCtrl.clear();
      _dosageCtrl.clear();
      _freqCtrl.clear();
      _durCtrl.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _addFromFavorite(Medicine m) {
    setState(() => _medicines.add(m));
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CLINICAL MODULE', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    SizedBox(height: 8),
                    Text('Prescription Builder', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  ],
                ),
              ),
            ),
            actions: [
              if (_medicines.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => PrescriptionPreviewDialog(
                        medicines: _medicines,
                        patientName: 'Patient Name', // In real app, pass actual name
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      Navigator.pop(context, _medicines);
                    }
                  },
                  child: const Text('FINALIZE', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900)),
                ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: _SectionTitle(title: 'Quick Templates'),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _favorites.length,
                itemBuilder: (context, i) {
                  final m = _favorites[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _FavoriteCard(medicine: m, onTap: () => _addFromFavorite(m)),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: _SectionTitle(title: 'Prescribed Items'),
            ),
          ),
          if (_medicines.isEmpty)
            const SliverFillRemaining(child: _EmptyState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final m = _medicines[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: _MedicineCard(
                      medicine: m,
                      onDelete: () => setState(() => _medicines.removeAt(index)),
                    ),
                  );
                },
                childCount: _medicines.length,
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 300)),
        ],
      ),
      bottomSheet: _MedicineForm(
        nameCtrl: _nameCtrl,
        dosageCtrl: _dosageCtrl,
        freqCtrl: _freqCtrl,
        durCtrl: _durCtrl,
        onAdd: _addMedicine,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 1));
  }
}

class _FavoriteCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;
  const _FavoriteCard({required this.medicine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: CliniGoTheme.primaryColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.star_rounded, color: CliniGoTheme.primaryColor, size: 14),
            ),
            const Spacer(),
            Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A), overflow: TextOverflow.ellipsis)),
            Text(medicine.dosage, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_liquid_rounded, size: 48, color: Colors.grey[200]),
          const SizedBox(height: 12),
          const Text('No items added yet', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onDelete;

  const _MedicineCard({required this.medicine, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.medication_rounded, color: Color(0xFF64748B), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(
                  '${medicine.dosage} · ${medicine.frequency} · ${medicine.duration}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171), size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _MedicineForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController dosageCtrl;
  final TextEditingController freqCtrl;
  final TextEditingController durCtrl;
  final VoidCallback onAdd;

  const _MedicineForm({
    required this.nameCtrl,
    required this.dosageCtrl,
    required this.freqCtrl,
    required this.durCtrl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, -10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _field(nameCtrl, 'Medicine Name', Icons.title_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _field(dosageCtrl, 'Dosage', Icons.scale_rounded)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field(freqCtrl, 'Frequency', Icons.repeat_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _field(durCtrl, 'Duration', Icons.timer_rounded)),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 20),
                SizedBox(width: 12),
                Text('Add Medication', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
