import 'package:flutter/material.dart';
import 'package:juskar/screens/home_page.dart';
import 'package:juskar/screens/create_order_page.dart';
import 'package:juskar/screens/categories_page.dart';
import 'package:juskar/screens/analytics_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const CreateOrderPage(),
    const CategoriesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF7C7BFF),
              unselectedItemColor: const Color(0xFFB0B0B0),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle, size: 32),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.link),
                  label: 'Categorías',
                ),
              ],
            ),
          ),
          floatingActionButton: currentIndex == 1 ? null : Container(
            margin: const EdgeInsets.only(top: 30),
            child: FloatingActionButton(
              heroTag: "main_fab",
              onPressed: () {
                setState(() {
                  currentIndex = 1;
                });
              },
              backgroundColor: const Color(0xFF7C7BFF),
              elevation: 8,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: const Color.fromRGBO(42, 42, 42, 0.9),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Analítica',
                  icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AnalyticsPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
