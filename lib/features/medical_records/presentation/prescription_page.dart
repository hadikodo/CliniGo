import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/prescription.dart';
import '../../../core/constants/theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CliniGoTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Prescription', style: TextStyle(fontSize: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _medicines.isEmpty 
              ? _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _medicines.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final m = _medicines[index];
                    return _MedicineCard(
                      medicine: m,
                      onDelete: () => setState(() => _medicines.removeAt(index)),
                    );
                  },
                ),
          ),
          _MedicineForm(
            nameCtrl: _nameCtrl,
            dosageCtrl: _dosageCtrl,
            freqCtrl: _freqCtrl,
            durCtrl: _durCtrl,
            onAdd: _addMedicine,
            onSave: _medicines.isEmpty ? null : () => Navigator.pop(context, _medicines),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_liquid_rounded, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text('No medications added yet', style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: CliniGoTheme.primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.medication_rounded, color: CliniGoTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(
                  '${medicine.dosage} · ${medicine.frequency} · ${medicine.duration}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle_outline_rounded, color: Colors.red[300], size: 20),
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
  final VoidCallback? onSave;

  const _MedicineForm({
    required this.nameCtrl,
    required this.dosageCtrl,
    required this.freqCtrl,
    required this.durCtrl,
    required this.onAdd,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medicine Name', prefixIcon: Icon(Icons.title_rounded)))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: dosageCtrl, decoration: const InputDecoration(labelText: 'Dosage', prefixIcon: Icon(Icons.scale_rounded)))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: freqCtrl, decoration: const InputDecoration(labelText: 'Frequency', prefixIcon: Icon(Icons.repeat_rounded)))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: durCtrl, decoration: const InputDecoration(labelText: 'Duration', prefixIcon: Icon(Icons.timer_rounded)))),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Item'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    side: const BorderSide(color: CliniGoTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                  child: const Text('Finalize'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
