import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukl_mobile_uiux/controllers/customers/customers_controller.dart';
import 'package:ukl_mobile_uiux/views/login_view.dart';
import 'package:ukl_mobile_uiux/widgets/cust_bottom_navbar.dart';
import 'package:ukl_mobile_uiux/views/login_role_view.dart';
import 'package:ukl_mobile_uiux/views/customers/CustEditProfile_view.dart';

class ProfilCustView extends StatefulWidget {
  final String token;

  const ProfilCustView({super.key, required this.token});

  @override
  State<ProfilCustView> createState() => _ProfilCustViewState();
}

class _ProfilCustViewState extends State<ProfilCustView> {
  // FIX: inisialisasi langsung saat deklarasi — tidak perlu late, tidak ada risiko LateInitializationError
  final CustomerController _controller = CustomerController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.getMyProfile(widget.token);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    if (mounted) {
      await _controller.getMyProfile(widget.token);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleView()),
      (route) => false,
    );

    Future.microtask(() {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginView(isAdmin: false)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // FIX: ChangeNotifierProvider.value pakai _controller yang sudah dibuat di initState
    // Jangan pakai create: (_) => CustomerController() di dalam build — itu bikin
    // controller baru setiap rebuild dan initState tidak bisa akses provider-nya
    return ChangeNotifierProvider<CustomerController>.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: const Color(0xffF4F8FB),
        body: Consumer<CustomerController>(
          builder: (context, controller, child) {
            // 1. STATE LOADING
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff3B82F6)),
                ),
              );
            }

            // 2. STATE ERROR ATAU DATA NULL
            if (controller.errorMessage != null || controller.profile == null) {
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
                          color: Color(0xff063A69),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage ?? "Gagal mengambil data akun.",
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
                          backgroundColor: const Color(0xff3B82F6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
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
                    ],
                  ),
                ),
              );
            }

            // 3. STATE BERHASIL MEMUAT DATA
            final profil = controller.profile!;

            return Stack(
              children: [
                Positioned(
                  top: 180,
                  left: -40,
                  child: _buildBgCircle(
                      const Color(0xff60A5FA).withOpacity(0.3), 140,
                      isEllipse: true),
                ),
                Positioned(
                  top: 140,
                  right: 50,
                  child: _buildBgCircle(
                      const Color(0xff60A5FA).withOpacity(0.3), 100),
                ),
                Positioned(
                  top: 260,
                  right: -55,
                  child:
                      _buildBgCircle(const Color(0xff3B82F6), 120),
                ),
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _refreshProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            profil.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff063A69),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const CircleAvatar(
                                  radius: 75,
                                  backgroundColor: Colors.blueGrey,
                                  backgroundImage: AssetImage(
                                      'assets/images/stitch_profile.png'),
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xff3B82F6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xff3B82F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Customer",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.grey.shade100, width: 1.5),
                            ),
                            child: Column(
                              children: [
                                _buildProfileRow("Username", profil.username,
                                    isBlueText: true),
                                _buildDivider(),
                                _buildProfileRow("No.Telepon", profil.phone,
                                    isBlueText: true),
                                _buildDivider(),
                                _buildProfileRow("Alamat", profil.address),
                                _buildDivider(),
                                _buildProfileRow(
                                    "No. Pelanggan (NIK)", profil.customerNumber),
                              ],
                            ),
                          ),
                          const SizedBox(height: 35),

                          // BUTTON EDIT PROFIL
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider<CustomerController>.value(
                                      value: controller,
                                      child: CustEditProfileView(
                                        token: widget.token,
                                        controller: controller,
                                      ),
                                    ),
                                  ),
                                );
                                _refreshProfile();
                              },
                              icon: const Icon(Icons.edit_square,
                                  color: Color(0xff063A69), size: 18),
                              label: const Text(
                                "Edit Profil",
                                style: TextStyle(
                                  color: Color(0xff063A69),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.grey.shade200, width: 1.2),
                                backgroundColor: const Color(0xffF8FAFC),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // BUTTON LOGOUT
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    title: const Text("Keluar dari Akun?",
                                        style: TextStyle(fontWeight: FontWeight.bold)),
                                    content: const Text(
                                        "Kamu akan keluar dari akun ini. Yakin ingin melanjutkan?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: const Text("Batal",
                                            style: TextStyle(color: Colors.grey)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xffD90429),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8)),
                                          elevation: 0,
                                        ),
                                        child: const Text("Keluar",
                                            style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) _logout();
                              },
                              icon: const Icon(Icons.logout_rounded,
                                  color: Colors.white, size: 18),
                              label: const Text(
                                "Keluar dari Akun",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffD90429),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: CustomCustomerBottomNavbar(
          token: widget.token,
          currentIndex: 3,
        ),
      ),
    );
  }

  Widget _buildBgCircle(Color color, double size, {bool isEllipse = false}) {
    return Container(
      width: isEllipse ? size - 60 : size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: isEllipse
            ? const BorderRadius.all(Radius.elliptical(40, 70))
            : null,
        shape: isEllipse ? BoxShape.rectangle : BoxShape.circle,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xffF1F5F9));
  }

  Widget _buildProfileRow(String label, String value,
      {bool isBlueText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff1E293B),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isBlueText
                    ? const Color(0xff0A59D1)
                    : const Color(0xff063A69),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}