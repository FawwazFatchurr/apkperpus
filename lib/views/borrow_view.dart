import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/library_viewmodel.dart';
import '../theme/app_theme.dart';

class BorrowView extends StatefulWidget {
  const BorrowView({super.key});

  @override
  State<BorrowView> createState() => _BorrowViewState();
}

class _BorrowViewState extends State<BorrowView> {
  final _memberCodeCtrl = TextEditingController();
  final _bookCodeCtrl = TextEditingController();
  final _returnBookCodeCtrl = TextEditingController();
  final _searchTitleCtrl = TextEditingController();
  String _searchResult = '';

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LibraryViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PANEL PEMINJAMAN
          const Text(
            'Input Peminjaman',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _memberCodeCtrl,
            decoration: const InputDecoration(
              labelText: 'Kode Anggota (Cth: ANG-001)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bookCodeCtrl,
            decoration: const InputDecoration(
              labelText: 'Kode Buku (Cth: BK-001)',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                final msg = vm.processBorrow(
                  _memberCodeCtrl.text,
                  _bookCodeCtrl.text,
                );
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(msg)));
                if (msg == 'Berhasil dipinjam!') {
                  _memberCodeCtrl.clear();
                  _bookCodeCtrl.clear();
                }
              },
              child: const Text(
                'Proses Peminjaman',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          const Divider(height: 60, thickness: 1),

          // PANEL PENGEMBALIAN BUKU
          const Text(
            'Input Pengembalian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _returnBookCodeCtrl,
            decoration: const InputDecoration(
              labelText: 'Kode Buku yang Dikembalikan (Cth: BK-001)',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme
                    .secondary, // Warna berbeda agar tidak tertukar dengan tombol pinjam
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                final msg = vm.processReturn(_returnBookCodeCtrl.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: msg.contains('berhasil')
                        ? AppTheme.primary
                        : Colors.red.shade400,
                  ),
                );
                if (msg.contains('berhasil')) {
                  _returnBookCodeCtrl.clear();
                }
              },
              child: const Text(
                'Proses Pengembalian',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Divider(height: 60, thickness: 1),

          // PANEL PENCARIAN STATUS BUKU
          const Text(
            'Cek Status Buku',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchTitleCtrl,
            decoration: const InputDecoration(
              labelText: 'Cari Judul Buku...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (val) {
              setState(() => _searchResult = vm.checkBookStatusByTitle(val));
            },
          ),
          const SizedBox(height: 16),
          if (_searchResult.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _searchResult,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
