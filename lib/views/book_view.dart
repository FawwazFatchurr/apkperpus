import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/library_viewmodel.dart';
import '../theme/app_theme.dart';

class BookView extends StatefulWidget {
  const BookView({super.key});

  @override
  State<BookView> createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  final titleCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  String? selectedGenre;

  // Fungsi untuk menampilkan Pop-up tambah genre
  void _showAddGenreDialog(BuildContext context, LibraryViewModel vm) {
    final newGenreCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Tambah Genre Baru',
          style: TextStyle(color: AppTheme.primary),
        ),
        content: TextField(
          controller: newGenreCtrl,
          decoration: const InputDecoration(
            labelText: 'Nama Genre',
            hintText: 'Cth: Psikologi',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () {
              if (newGenreCtrl.text.isNotEmpty) {
                vm.addGenre(newGenreCtrl.text);
                setState(() => selectedGenre = newGenreCtrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Fungsi konfirmasi hapus buku
  void _confirmDelete(BuildContext context, LibraryViewModel vm, var book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Buku', style: TextStyle(color: Colors.red)),
        content: Text(
          'Apakah Anda yakin ingin menghapus buku "${book.title}" secara permanen?',
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
              final msg = vm.deleteBook(book.bookCode);

              // Notifikasi hasil hapus (Merah jika gagal, Hijau jika berhasil)
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
    final booksGrouped = vm.booksByGenre;

    // Set nilai default dropdown
    if (selectedGenre == null && vm.availableGenres.isNotEmpty) {
      selectedGenre = vm.availableGenres.first;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kode (Cth: TEK-001)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Judul Buku'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedGenre,
                  decoration: const InputDecoration(labelText: 'Pilih Genre'),
                  items: vm.availableGenres.map((genre) {
                    return DropdownMenuItem(value: genre, child: Text(genre));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedGenre = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  tooltip: 'Tambah Genre Baru',
                  icon: const Icon(Icons.add, color: AppTheme.textDark),
                  onPressed: () => _showAddGenreDialog(context, vm),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty &&
                      codeCtrl.text.isNotEmpty &&
                      selectedGenre != null) {
                    vm.addBook(titleCtrl.text, codeCtrl.text, selectedGenre!);
                    titleCtrl.clear();
                    codeCtrl.clear();
                  }
                },
                child: const Text(
                  'Tambah Buku',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          const Divider(height: 40, thickness: 1),

          // DAFTAR BUKU (DROPDOWN PER GENRE)
          Expanded(
            child: ListView.builder(
              itemCount: booksGrouped.length,
              itemBuilder: (context, index) {
                String genre = booksGrouped.keys.elementAt(index);
                var booksInGenre = booksGrouped[genre]!;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: ExpansionTile(
                    iconColor: AppTheme.primary,
                    collapsedIconColor: AppTheme.textDark,
                    title: Text(
                      '$genre (${booksInGenre.length} Buku)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    children: booksInGenre.map((book) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 4,
                        ),
                        title: Text(
                          book.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('Kode: ${book.bookCode}'),
                        // Trailing sekarang berisi Icon Status dan Icon Hapus
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              book.isBorrowed
                                  ? Icons.do_disturb_on_rounded
                                  : Icons.check_circle_rounded,
                              color: book.isBorrowed
                                  ? Colors.red.shade400
                                  : AppTheme.primary,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Hapus Buku',
                              onPressed: () =>
                                  _confirmDelete(context, vm, book),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
