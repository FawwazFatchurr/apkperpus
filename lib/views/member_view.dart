import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/library_viewmodel.dart';
import '../theme/app_theme.dart';
import '../models/library_models.dart';

class MemberView extends StatefulWidget {
  const MemberView({super.key});

  @override
  State<MemberView> createState() => _MemberViewState();
}

class _MemberViewState extends State<MemberView> {
  final nameCtrl = TextEditingController();

  // Untuk Input Anggota Baru
  String selectedJenjang = 'SD';
  final List<String> jenjangList = ['TK', 'SD', 'SMP', 'SMA', 'Umum'];

  // Untuk Filter Tampilan Anggota
  String filterJenjang = 'Semua';
  final List<String> filterList = ['Semua', 'TK', 'SD', 'SMP', 'SMA', 'Umum'];

  // Dialog Edit Anggota
  void _showEditMemberDialog(
    BuildContext context,
    LibraryViewModel vm,
    Member member,
  ) {
    final editNameCtrl = TextEditingController(text: member.name);
    String editJenjang = member.jenjang;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Edit Data Anggota',
            style: TextStyle(color: AppTheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editNameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: editJenjang,
                decoration: const InputDecoration(labelText: 'Jenjang'),
                items: jenjangList
                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                    .toList(),
                onChanged: (val) => setDialogState(() => editJenjang = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              onPressed: () {
                if (editNameCtrl.text.isNotEmpty) {
                  vm.editMember(member.id, editNameCtrl.text, editJenjang);
                  Navigator.pop(ctx);
                }
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Hapus Anggota
  void _confirmDeleteMember(
    BuildContext context,
    LibraryViewModel vm,
    Member member,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Anggota', style: TextStyle(color: Colors.red)),
        content: Text(
          'Hapus "${member.name}" (${member.memberCode}) secara permanen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              final msg = vm.deleteMember(member.memberCode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: msg.contains('Gagal')
                      ? Colors.red.shade400
                      : AppTheme.primary,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LibraryViewModel>(context);

    // Logika Filter Jenjang
    final filteredMembers = filterJenjang == 'Semua'
        ? vm.members
        : vm.members.where((m) => m.jenjang == filterJenjang).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // PANEL TAMBAH ANGGOTA
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedJenjang,
                  decoration: const InputDecoration(labelText: 'Jenjang'),
                  items: jenjangList
                      .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedJenjang = val!),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      vm.addMember(nameCtrl.text, selectedJenjang);
                      nameCtrl.clear();
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
              ),
            ],
          ),

          const Divider(height: 30, thickness: 1),

          // FILTER ANGGOTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Anggota',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<String>(
                  value: filterJenjang,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    labelText: 'Filter',
                  ),
                  items: filterList
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) => setState(() => filterJenjang = val!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // DAFTAR ANGGOTA (DENGAN TRACK RECORD)
          Expanded(
            child: filteredMembers.isEmpty
                ? const Center(child: Text('Tidak ada anggota di jenjang ini.'))
                : ListView.builder(
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, i) {
                      final member = filteredMembers[i];
                      final stats = vm.getMemberStats(
                        member.memberCode,
                      ); // Mengambil Track Record

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 16,
                                right: 8,
                                top: 8,
                              ),
                              leading: const CircleAvatar(
                                backgroundColor: AppTheme.secondary,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(
                                member.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'ID: ${member.memberCode} | Jenjang: ${member.jenjang}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: AppTheme.primary,
                                    ),
                                    onPressed: () => _showEditMemberDialog(
                                      context,
                                      vm,
                                      member,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _confirmDeleteMember(
                                      context,
                                      vm,
                                      member,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // BAGIAN BADGE TRACK RECORD
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatBadge(
                                    'Hari Ini',
                                    stats['daily'].toString(),
                                    Colors.orange.shade300,
                                  ),
                                  _buildStatBadge(
                                    'Minggu Ini',
                                    stats['weekly'].toString(),
                                    Colors.blue.shade300,
                                  ),
                                  _buildStatBadge(
                                    'Bulan Ini',
                                    stats['monthly'].toString(),
                                    Colors.green.shade300,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget Kustom untuk Badge Statistik
  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color.withOpacity(0.9),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
