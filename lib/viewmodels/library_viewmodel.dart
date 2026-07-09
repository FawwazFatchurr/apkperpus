import 'package:flutter/material.dart';
import '../models/library_models.dart';

class LibraryViewModel extends ChangeNotifier {
  // Data Master
  final List<Member> _members = [
    Member(id: 'M1', memberCode: 'ANG-001', name: 'Fawwaz', jenjang: 'SMA'),
  ];

  final List<Book> _books = [
    Book(
      id: 'B1',
      bookCode: 'TEK-001',
      title: 'Pemrograman Flutter',
      genre: 'Teknologi',
    ),
    Book(
      id: 'B2',
      bookCode: 'TEK-002',
      title: 'Clean Architecture',
      genre: 'Teknologi',
    ),
    Book(id: 'B3', bookCode: 'FIK-001', title: 'Bumi Manusia', genre: 'Fiksi'),
    Book(
      id: 'B4',
      bookCode: 'FIK-002',
      title: 'Laskar Pelangi',
      genre: 'Fiksi',
    ),
    Book(id: 'B5', bookCode: 'SEJ-001', title: 'Sapiens', genre: 'Sejarah'),
  ];

  final List<BorrowRecord> _records = []; // Khusus yang SEDANG dipinjam
  final List<BorrowRecord> _borrowHistory =
      []; // Histori permanen untuk Track Record

  // --- FITUR GENRE DINAMIS ---
  final List<String> _availableGenres = ['Teknologi', 'Fiksi', 'Sejarah'];

  // Getters
  List<Member> get members => _members;
  List<Book> get books => _books;
  List<BorrowRecord> get records => _records;
  List<String> get availableGenres => _availableGenres;

  Map<String, List<Book>> get booksByGenre {
    Map<String, List<Book>> map = {};
    for (var book in _books) {
      if (!map.containsKey(book.genre)) map[book.genre] = [];
      map[book.genre]!.add(book);
    }
    return map;
  }

  // --- FITUR STATISTIK GRAFIK DASHBOARD ---
  List<double> get weeklyStats {
    double todayRecord = _records.length.toDouble();
    return [5, 8, 3, 10, todayRecord > 0 ? todayRecord : 2];
  }

  // --- FITUR TRACK RECORD ANGGOTA ---
  Map<String, int> getMemberStats(String memberCode) {
    final now = DateTime.now();
    int daily = 0;
    int weekly = 0;
    int monthly = 0;

    for (var record in _borrowHistory) {
      if (record.member.memberCode == memberCode) {
        final daysDiff = now.difference(record.borrowDate).inDays;

        // Harian (Hari ini)
        if (record.borrowDate.year == now.year &&
            record.borrowDate.month == now.month &&
            record.borrowDate.day == now.day) {
          daily++;
        }
        // Mingguan (7 hari terakhir)
        if (daysDiff <= 7) weekly++;
        // Bulanan (30 hari terakhir)
        if (daysDiff <= 30) monthly++;
      }
    }
    return {'daily': daily, 'weekly': weekly, 'monthly': monthly};
  }

  // --- TAMBAH GENRE BARU ---
  void addGenre(String newGenre) {
    String formatted = newGenre.trim();
    if (formatted.isNotEmpty && !_availableGenres.contains(formatted)) {
      _availableGenres.add(formatted);
      notifyListeners();
    }
  }

  // --- FITUR ANGGOTA (AUTO-ID & JENJANG) ---
  void addMember(String name, String jenjang) {
    int nextNumber = _members.length + 1;
    String autoCode = 'ANG-${nextNumber.toString().padLeft(3, '0')}';

    _members.add(
      Member(
        id: DateTime.now().toString(),
        memberCode: autoCode,
        name: name,
        jenjang: jenjang,
      ),
    );
    notifyListeners();
  }

  // --- FITUR EDIT ANGGOTA ---
  void editMember(String id, String newName, String newJenjang) {
    try {
      final index = _members.indexWhere((m) => m.id == id);
      if (index != -1) {
        final updatedMember = Member(
          id: id,
          memberCode: _members[index].memberCode,
          name: newName,
          jenjang: newJenjang,
        );
        _members[index] = updatedMember;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Gagal mengedit anggota: $e');
    }
  }

  // --- FITUR HAPUS ANGGOTA ---
  String deleteMember(String memberCode) {
    try {
      final member = _members.firstWhere((m) => m.memberCode == memberCode);

      final isCurrentlyBorrowing = _records.any(
        (r) => r.member.memberCode == memberCode,
      );
      if (isCurrentlyBorrowing) {
        return 'Gagal: Anggota sedang meminjam buku. Selesaikan pengembalian terlebih dahulu!';
      }

      _members.remove(member);
      notifyListeners();
      return 'Anggota "${member.name}" berhasil dihapus!';
    } catch (e) {
      return 'Anggota tidak ditemukan.';
    }
  }

  // --- FITUR BUKU ---
  void addBook(String title, String code, String genre) {
    _books.add(
      Book(
        id: DateTime.now().toString(),
        bookCode: code,
        title: title,
        genre: genre,
      ),
    );
    notifyListeners();
  }

  // --- FITUR HAPUS BUKU ---
  String deleteBook(String bookCode) {
    try {
      final book = _books.firstWhere((b) => b.bookCode == bookCode);
      if (book.isBorrowed)
        return 'Gagal: Buku sedang dipinjam, selesaikan transaksi terlebih dahulu!';

      _books.remove(book);
      notifyListeners();
      return 'Buku "${book.title}" berhasil dihapus!';
    } catch (e) {
      return 'Buku tidak ditemukan.';
    }
  }

  // --- FITUR PEMINJAMAN ---
  String processBorrow(String memberCode, String bookCode) {
    try {
      final member = _members.firstWhere((m) => m.memberCode == memberCode);
      final book = _books.firstWhere((b) => b.bookCode == bookCode);

      if (book.isBorrowed) return 'Buku sedang dipinjam!';

      book.isBorrowed = true;
      final newRecord = BorrowRecord(
        id: DateTime.now().toString(),
        member: member,
        book: book,
        borrowDate: DateTime.now(),
      );

      _records.add(newRecord);
      _borrowHistory.add(newRecord); // Masukkan ke riwayat permanen juga
      notifyListeners();
      return 'Berhasil dipinjam!';
    } catch (e) {
      return 'Kode Anggota atau Kode Buku tidak ditemukan!';
    }
  }

  // --- FITUR PENCARIAN STATUS ---
  String checkBookStatusByTitle(String title) {
    if (title.isEmpty) return '';
    try {
      final book = _books.firstWhere(
        (b) => b.title.toLowerCase().contains(title.toLowerCase()),
      );
      if (book.isBorrowed) {
        final record = _records.firstWhere(
          (r) => r.book.bookCode == book.bookCode,
        );
        return 'Buku "${book.title}" sedang dipinjam oleh ${record.member.name} sejak ${record.borrowDate.toString().substring(0, 10)}';
      }
      return 'Buku "${book.title}" (Kode: ${book.bookCode}) TERSEDIA.';
    } catch (e) {
      return 'Buku tidak ditemukan dalam katalog.';
    }
  }

  // --- FITUR PENGEMBALIAN (TANPA DENDA) ---
  String processReturn(String bookCode) {
    try {
      final book = _books.firstWhere((b) => b.bookCode == bookCode);
      if (!book.isBorrowed) return 'Buku ini sedang tidak dipinjam.';

      final record = _records.firstWhere((r) => r.book.bookCode == bookCode);

      book.isBorrowed = false;
      _records.remove(record); // Hapus dari daftar sedang pinjam
      // Tidak perlu menghapus dari _borrowHistory agar stat anggota tetap ada
      notifyListeners();

      return 'Buku berhasil dikembalikan!';
    } catch (e) {
      return 'Kode Buku tidak valid atau tidak ditemukan.';
    }
  }
}
