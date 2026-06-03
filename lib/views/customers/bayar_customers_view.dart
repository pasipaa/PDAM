import 'package:flutter/material.dart';
import 'package:ukl_mobile_uiux/controllers/customers/customers_controller.dart';
import 'package:ukl_mobile_uiux/models/customers/customer_tagihan_models.dart';
import 'package:ukl_mobile_uiux/views/customers/detail_baar_view.dart';
import 'package:ukl_mobile_uiux/widgets/cust_bottom_navbar.dart';

class BayarCustView extends StatefulWidget {
  final String token; 

  const BayarCustView({super.key, required this.token}); 

  @override
  State<BayarCustView> createState() => _BayarCustViewState();
}

class _BayarCustViewState extends State<BayarCustView> {
  final CustomerController _controller = CustomerController();
  late Future<List<CustomerBill>> _billFuture;

  @override
  void initState() {
    super.initState();
    _billFuture = _controller.getMyBills(widget.token);
  }

  String _getIndonesianMonth(int monthNumber) {
    const months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    if (monthNumber < 1 || monthNumber > 12) return "Bulan";
    return months[monthNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FB),
      appBar: AppBar(
        title: const Text(
          "Bayar Tagihan", 
          style: TextStyle(
            color: Color(0xff1E293B), 
            fontWeight: FontWeight.bold, 
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, 
        automaticallyImplyLeading: false, 
      ),
      body: FutureBuilder<List<CustomerBill>>(
        future: _billFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("ERROR DARI API/MODEL:\n${snapshot.error}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              )
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "Pesan A: DATA DARI API KOSONG!\n\nTagihan tidak ada. Cek apakah Admin menambahkan tagihan ke ID Customer yang BENAR dengan akun yang sedang login ini?", 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          final data = snapshot.data!;
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _billFuture = _controller.getMyBills(widget.token);
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildRowData("Periode", "${_getIndonesianMonth(item.month)} ${item.year}"),
                      const SizedBox(height: 10),
                      _buildRowData("Pemakaian", "${item.usageValue}m³"),
                      const SizedBox(height: 10),
                      _buildRowData("Harga", "Rp ${item.totalPrice}", isPrice: true),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            Map<String, dynamic> billData = {
                              "id": item.id,
                              "periode": "${_getIndonesianMonth(item.month)} ${item.year}",
                              "no_meteran": item.measurementNumber,
                              "pemakaian": item.usageValue,
                              "harga": item.totalPrice,
                            };

                            final bool? isUploaded = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailBayarView(
                                  bill: billData, 
                                  token: widget.token, 
                                  dynamicStatus: item.status,
                                ),
                              ),
                            );

                            if (isUploaded == true) {
                              setState(() {
                                _billFuture = _controller.getMyBills(widget.token);
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0A59D1), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Bayar Sekarang", 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: CustomCustomerBottomNavbar(
        token: widget.token, 
        currentIndex: 2, 
      ),
    );
  }

  Widget _buildRowData(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: const TextStyle(
            color: Color(0xff71717A),
            fontSize: 13, 
            fontWeight: FontWeight.w500
          )
        ),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 14, 
            color: isPrice ? const Color(0xff0A59D1) : const Color(0xff18181B)
          ),
        ),
      ],
    );
  }
}