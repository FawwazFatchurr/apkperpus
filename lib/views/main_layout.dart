import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'member_view.dart';
import 'book_view.dart';
import 'borrow_view.dart';
import 'dashboard_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  Widget _currentView = const DashboardView();
  String _appBarTitle = 'Dashboard Admin';

  void _onMenuTap(Widget view, String title) {
    setState(() {
      _currentView = view;
      _appBarTitle = title;
    });
    Navigator.pop(context); // Tutup sidebar setelah diklik
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle)),
      drawer: Drawer(
        backgroundColor: AppTheme.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.local_library, size: 48, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Admin Perpustakaan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard, color: AppTheme.textDark),
              title: const Text('Dashboard'),
              onTap: () => _onMenuTap(const DashboardView(), 'Dashboard Admin'),
            ),
            ListTile(
              leading: const Icon(Icons.sync_alt, color: AppTheme.textDark),
              title: const Text('Transaksi'),
              onTap: () =>
                  _onMenuTap(const BorrowView(), 'Transaksi Peminjaman'),
            ),
            ListTile(
              leading: const Icon(Icons.people_alt, color: AppTheme.textDark),
              title: const Text('Kelola Anggota'),
              onTap: () => _onMenuTap(const MemberView(), 'Data Anggota'),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: AppTheme.textDark),
              title: const Text('Katalog & Kode Buku'),
              onTap: () => _onMenuTap(const BookView(), 'Katalog Buku'),
            ),
          ],
        ),
      ),
      body: _currentView,
    );
  }
}
