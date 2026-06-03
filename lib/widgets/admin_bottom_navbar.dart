import 'package:flutter/material.dart';
import 'package:ukl_mobile_uiux/views/admin/customer_view.dart';
import 'package:ukl_mobile_uiux/views/admin/dashboard_admin_view.dart';
import 'package:ukl_mobile_uiux/views/admin/layanan_admin_view.dart';
import 'package:ukl_mobile_uiux/views/admin/profile_view.dart';
import 'package:ukl_mobile_uiux/views/admin/tagihan_view.dart';

class CustomBottomNavbar extends StatelessWidget {
  final String token;
  final int currentIndex;

  const CustomBottomNavbar({
    super.key,
    required this.token,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        child: SizedBox(
          height: 85,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            selectedItemColor: const Color(0xff063A69),
            unselectedItemColor: const Color(0xff4A627A).withOpacity(0.8),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              height: 1.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.5,
            ),
            onTap: (index) {
              if (index == currentIndex) return;

              Widget targetView;
              switch (index) {
                case 0:
                  targetView = DashboardAdminView(token: token, onMenuTap: (index) {  },);
                  break;
                case 1:
                  targetView = LayananAdminView(token: token); 
                  break;
                case 2:
                  targetView = CustomerView(token: token);
                  break;
                case 3:
                  targetView = TagihanView(token: token);
                  break;
                case 4:
                  targetView = ProfileView(token: token);
                  break;
                default:
                  return;
              }

              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => targetView,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.home_filled, size: 28),
                ),
                label: "Beranda",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.settings, size: 28),
                ),
                label: "Layanan",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.people_alt, size: 28),
                ),
                label: "Customer",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.receipt_long, size: 28),
                ),
                label: "Tagihan",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.person, size: 28),
                ),
                label: "Profil",
              ),
            ],
          ),
        ),
      ),
    );
  }
}