import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ukl_mobile_uiux/controllers/profile_controller.dart';
import 'package:ukl_mobile_uiux/views/admin/AdminEditProfile_view.dart';
import 'package:ukl_mobile_uiux/widgets/admin_bottom_navbar.dart';
import 'package:ukl_mobile_uiux/views/login_role_view.dart';
import 'package:ukl_mobile_uiux/views/login_view.dart';

class ProfileView extends StatefulWidget {
  final String token;
  const ProfileView({super.key, required this.token});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _profileController.getProfile(widget.token);
      }
    });
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleView()),
      (route) => false,
    );

    Future.microtask(() {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginView(isAdmin: true)),
      );
    });
  }
  Future<void> _refreshProfile() async {
    if (mounted) {
      await _profileController.getProfile(widget.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileController>.value(
      value: _profileController,
      child: Scaffold(
        backgroundColor: const Color(0xffF4F8FA),
        body: Consumer<ProfileController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0066FF)),
                ),
              );
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.gpp_bad_rounded,
                        color: Colors.redAccent,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Gagal Memuat Profil",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff004080),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refreshProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0066FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Coba Lagi",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => _handleLogout(context),
                        child: const Text(
                          "Kembali ke Awal",
                          style: TextStyle(color: Color(0xff0066FF)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final admin = controller.profile;

            return Stack(
              children: [
                Positioned(
                  top: 150,
                  left: -40,
                  child: _buildBgCircle(const Color(0xff0066FF).withOpacity(0.1), 110),
                ),
                Positioned(
                  top: -30,
                  right: 40,
                  child: _buildBgCircle(const Color(0xff0066FF).withOpacity(0.1), 130),
                ),
                Positioned(
                  top: 240,
                  right: -50,
                  child: _buildBgCircle(const Color(0xff0066FF).withOpacity(0.15), 140),
                ),
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _refreshProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
                      child: Column(
                        children: [
                          Text(
                            admin?.name ?? "Nama Admin",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff004080),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 75,
                                  backgroundColor: Colors.blue.shade50,
                                  child: const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Color(0xff004080),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xff3B97FF),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.edit, size: 18, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xff3B97FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "Admin",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blueGrey.shade50, width: 1.5),
                            ),
                            child: Column(
                              children: [
                                _buildRow("Nama", admin?.name ?? "-"),
                                _buildDivider(),
                                _buildRow("No.Telepon", admin?.phone ?? "-"),
                                _buildDivider(),
                                _buildRow("ID", "#${admin?.id ?? "-"}"),
                                _buildDivider(),
                                _buildRow(
                                  "Bergabung",
                                  admin?.createdAt != null
                                      ? DateFormat('d MMM yyyy').format(
                                          DateTime.tryParse(admin!.createdAt!) ?? DateTime.now(),
                                        )
                                      : "-",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          OutlinedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider<ProfileController>.value(
                                    value: _profileController,
                                    child: EditProfileView(token: widget.token),
                                  ),
                                ),
                              );
                              
                              _refreshProfile();
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              side: BorderSide(color: Colors.blueGrey.shade100, width: 1.5),
                              backgroundColor: const Color(0xffF8FAFC),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_square, color: Color(0xff004080), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Edit Profil",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff004080),
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          ElevatedButton(
                            onPressed: () => _handleLogout(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 54),
                              backgroundColor: const Color(0xffD90404),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Keluar dari Akun",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: CustomBottomNavbar(
          token: widget.token,
          currentIndex: 4,
        ),
      ),
    );
  }

  Widget _buildBgCircle(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff0B2240),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff1A5699),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}