import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InfoRekeningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade600,
              Colors.green.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SIMBAH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Bank Sampah Pagar Idum',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Info Rekening Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Info Rekening',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          color: Colors.white.withOpacity(0.9),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'No. Rekening',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '123456789',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Saldo Anda',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rp 350.000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Bank Sampah',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Content Area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.green.shade600,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Cara Penarikan Saldo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        
                        // Steps
                        _buildStepItem(
                          1,
                          'Datang ke Bank Sampah Pagar Idum dengan membawa KTP',
                          Colors.green.shade600,
                        ),
                        _buildStepItem(
                          2,
                          'Isi formulir penarikan saldo',
                          Colors.blue.shade600,
                        ),
                        _buildStepItem(
                          3,
                          'Tunggu konfirmasi dari petugas',
                          Colors.orange.shade600,
                        ),
                        _buildStepItem(
                          4,
                          'Saldo akan diberikan dalam bentuk tunai',
                          Colors.purple.shade600,
                        ),

                        SizedBox(height: 24),

                        // Catatan
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                color: Colors.amber.shade700,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Catatan:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber.shade800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Penarikan saldo minimal Rp 50.000 dan maksimal Rp 1.000.000 per hari.',
                                      style: TextStyle(
                                        color: Colors.amber.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
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
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(int number, String text, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}