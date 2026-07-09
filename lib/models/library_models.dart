class Member {
  final String id;
  final String memberCode;
  final String name;
  final String jenjang; // <-- Ini yang sebelumnya hilang/belum tersimpan

  Member({
    required this.id,
    required this.memberCode,
    required this.name,
    required this.jenjang,
  });
}

class Book {
  final String id;
  final String bookCode;
  final String title;
  final String genre;
  bool isBorrowed;

  Book({
    required this.id,
    required this.bookCode,
    required this.title,
    required this.genre,
    this.isBorrowed = false,
  });
}

class BorrowRecord {
  final String id;
  final Member member;
  final Book book;
  final DateTime borrowDate;

  BorrowRecord({
    required this.id,
    required this.member,
    required this.book,
    required this.borrowDate,
  });
}
