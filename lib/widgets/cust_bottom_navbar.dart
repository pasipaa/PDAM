import 'package:flutter/material.dart';
import 'package:ukl_mobile_uiux/views/customers/bayar_customers_view.dart';
import 'package:ukl_mobile_uiux/views/customers/dashboard_customers_view.dart';
import 'package:ukl_mobile_uiux/views/customers/profil_customer_view.dart';
import 'package:ukl_mobile_uiux/views/customers/tagihan_customers_view.dart';

class CustomCustomerBottomNavbar extends StatelessWidget {
  final String token;
  final int currentIndex;

  const CustomCustomerBottomNavbar({
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: SizedBox(
          height: 85,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            selectedItemColor: const Color(0xff063A69),
            unselectedItemColor: const Color(0xff4A627A).withOpacity(0.7),
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
                  targetView = DashboardCustomerView(token: token);
                  break;
                case 1:
                  targetView = TagihanCustView(token: token);
                  break;
                case 2:
                  targetView = BayarCustView(token: token);
                  break;
                case 3:
                  targetView = ProfilCustView(token: token);
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
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_outlined, size: 26),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home, size: 26),
                ),
                label: "Beranda",
              ),
              
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.receipt_outlined, size: 26),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.receipt, size: 26),
                ),
                label: "Tagihan",
              ),

              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.credit_card_outlined, size: 26),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.credit_card, size: 26),
                ),
                label: "Bayar",
              ),
              
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline_rounded, size: 26),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person, size: 26),
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