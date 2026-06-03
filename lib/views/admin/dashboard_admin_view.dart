import 'package:flutter/material.dart';
import 'package:ukl_mobile_uiux/controllers/dashboard_controller.dart';
import 'package:ukl_mobile_uiux/models/profile_models.dart';
import 'package:ukl_mobile_uiux/views/admin/customer_view.dart';
import 'package:ukl_mobile_uiux/views/admin/layanan_admin_view.dart';
import 'package:ukl_mobile_uiux/views/admin/tagihan_view.dart';
import 'package:ukl_mobile_uiux/widgets/admin_bottom_navbar.dart';

class DashboardAdminView extends StatefulWidget {
  final String token;

  const DashboardAdminView({
    super.key,
    required this.token, required Null Function(dynamic int) onMenuTap, 
  });

  @override
  State<DashboardAdminView> createState() => _DashboardAdminViewState();
}

class _DashboardAdminViewState extends State<DashboardAdminView> {
  final DashboardController _adminController = DashboardController();

  ProfileModel? _adminProfile;
  int _totalCustomers = 0;
  int _unverifiedPayments = 0;
  int _activeServices = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _adminController.getMyProfile(widget.token),
        _adminController.getTotalCustomers(widget.token),
        _adminController.getUnverifiedPaymentsCount(widget.token),
        _adminController.getActiveServicesCount(widget.token),
      ]);

      setState(() {
        _adminProfile = results[0] as ProfileModel?;
        _totalCustomers = results[1] as int;
        _unverifiedPayments = results[2] as int;
        _activeServices = results[3] as int;
      });
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xffF4F8FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final adminName = _adminProfile?.name ?? _adminProfile?.username ?? "Admin";

    return Scaffold(
      backgroundColor: const Color(0xffF4F8FA),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 140,
              left: -40,
              child: Container(
                width: 90,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0xff0052CC),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(50)),
                ),
              ),
            ),
            Positioned(
              top: 200,
              right: -30,
              child: Container(
                width: 80,
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xff0052CC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    bottomLeft: Radius.circular(70),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage("assets/profile.jpg"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Halo, $adminName",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xff0A2540),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications,
                          color: Color(0xff0052CC),
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    "Admin Dashboard",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0A2540),
                    ),
                  ),
                  const Text(
                    "Welcome back, Admin. System is running stable.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Pelanggan",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _totalCustomers.toString(),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0066FF),
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.people_alt_rounded,
                          size: 75,
                          color: Colors.blueGrey.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildIndicatorCard(
                          title: "Belum Di Verifikasi",
                          value: _unverifiedPayments.toString(),
                          valueColor: Colors.red,
                          icon: Icons.assignment_late,
                          iconBgColor: Colors.red.shade50,
                          iconColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildIndicatorCard(
                          title: "Layanan Aktif",
                          value: _activeServices.toString(),
                          valueColor: Colors.black87,
                          icon: Icons.water_drop,
                          iconBgColor: Colors.blue.shade50,
                          iconColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    "Fitur Layanan Cepat",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff0A2540),
                    ),
                  ),
                  const SizedBox(height: 15),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.35,
                    children: [
                      _buildActionCard(
                        icon: Icons.group_add_rounded,
                        title: "Tambah Customer",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CustomerView(token: widget.token)),
                        ).then((_) => _loadDashboardData()),
                      ),
                      _buildActionCard(
                        icon: Icons.add_box_rounded,
                        title: "Tambah Layanan",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LayananAdminView(token: widget.token)),
                        ).then((_) => _loadDashboardData()),
                      ),
                      _buildActionCard(
                        icon: Icons.settings_suggest_rounded,
                        title: "Kelola Layanan",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LayananAdminView(token: widget.token)),
                        ).then((_) => _loadDashboardData()),
                      ),
                      _buildActionCard(
                        icon: Icons.assignment_turned_in_rounded,
                        title: "Verifikasi Tagihan",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TagihanView(token: widget.token)),
                        ).then((_) => _loadDashboardData()),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        token: widget.token,
        currentIndex: 0,
      ),
    );
  }

  Widget _buildIndicatorCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff0A2540),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}