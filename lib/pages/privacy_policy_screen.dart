import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Kebijakan Privasi',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kebijakan Privasi Aplikasi Nesa',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD2691E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terakhir diperbarui: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              'Pendahuluan',
              'Selamat datang di Nesa. Kami menghargai privasi Anda dan berkomitmen untuk melindungi data pribadi Anda. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi Anda saat menggunakan aplikasi kami.',
            ),

            _buildSection(
              '1. Informasi yang Kami Kumpulkan',
              'Kami mengumpulkan informasi berikut:\n\n'
              '• Informasi Akun: Nama, email, nomor telepon, dan alamat pengiriman\n'
              '• Informasi Pesanan: Riwayat pesanan, preferensi makanan, dan detail transaksi\n'
              '• Informasi Lokasi: Lokasi Anda untuk menampilkan resto terdekat dan estimasi pengiriman\n'
              '• Informasi Perangkat: Model perangkat, sistem operasi, dan identifikasi unik perangkat\n'
              '• Data Penggunaan: Bagaimana Anda berinteraksi dengan aplikasi kami',
            ),

            _buildSection(
              '2. Bagaimana Kami Menggunakan Informasi Anda',
              'Kami menggunakan informasi Anda untuk:\n\n'
              '• Memproses dan mengirimkan pesanan Anda\n'
              '• Berkomunikasi tentang status pesanan\n'
              '• Memberikan layanan pelanggan\n'
              '• Meningkatkan pengalaman pengguna\n'
              '• Mengirimkan promosi dan penawaran khusus (dengan persetujuan Anda)\n'
              '• Mencegah penipuan dan meningkatkan keamanan\n'
              '• Mematuhi kewajiban hukum',
            ),

            _buildSection(
              '3. Berbagi Informasi',
              'Kami dapat membagikan informasi Anda dengan:\n\n'
              '• Mitra Resto: Untuk memproses pesanan Anda\n'
              '• Penyedia Layanan: Yang membantu operasi aplikasi (pembayaran, pengiriman, analitik)\n'
              '• Otoritas Hukum: Jika diwajibkan oleh hukum atau untuk melindungi hak kami\n\n'
              'Kami TIDAK menjual data pribadi Anda kepada pihak ketiga.',
            ),

            _buildSection(
              '4. Keamanan Data',
              'Kami menggunakan langkah-langkah keamanan teknis dan organisasi yang sesuai untuk melindungi data Anda, termasuk:\n\n'
              '• Enkripsi data saat transit dan saat disimpan\n'
              '• Akses terbatas ke data pribadi\n'
              '• Pemantauan keamanan secara berkala\n'
              '• Pelatihan karyawan tentang privasi data',
            ),

            _buildSection(
              '5. Hak Anda',
              'Anda memiliki hak untuk:\n\n'
              '• Mengakses data pribadi Anda\n'
              '• Memperbaiki data yang tidak akurat\n'
              '• Menghapus data Anda\n'
              '• Menolak pemrosesan data tertentu\n'
              '• Memindahkan data Anda ke layanan lain\n'
              '• Menarik persetujuan kapan saja\n\n'
              'Untuk menggunakan hak-hak ini, hubungi kami di privacy@nesa.com',
            ),

            _buildSection(
              '6. Cookies dan Teknologi Pelacakan',
              'Kami menggunakan cookies dan teknologi serupa untuk:\n\n'
              '• Mengingat preferensi Anda\n'
              '• Memahami bagaimana Anda menggunakan aplikasi\n'
              '• Meningkatkan kinerja aplikasi\n'
              '• Menyediakan konten yang dipersonalisasi\n\n'
              'Anda dapat mengelola preferensi cookies di pengaturan perangkat Anda.',
            ),

            _buildSection(
              '7. Penyimpanan Data',
              'Kami menyimpan data Anda selama diperlukan untuk menyediakan layanan kami atau sebagaimana diwajibkan oleh hukum. Setelah tidak diperlukan lagi, data Anda akan dihapus atau dianonimkan dengan aman.',
            ),

            _buildSection(
              '8. Privasi Anak',
              'Aplikasi kami tidak ditujukan untuk anak-anak di bawah 13 tahun. Kami tidak secara sengaja mengumpulkan informasi pribadi dari anak-anak. Jika Anda percaya kami telah mengumpulkan informasi dari anak, hubungi kami segera.',
            ),

            _buildSection(
              '9. Perubahan Kebijakan',
              'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan signifikan melalui aplikasi atau email. Penggunaan berkelanjutan Anda terhadap aplikasi setelah perubahan berarti Anda menerima kebijakan yang diperbarui.',
            ),

            _buildSection(
              '10. Hubungi Kami',
              'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, silakan hubungi kami:\n\n'
              'Email: privacy@nesa.com\n'
              'Telepon: +62 XXX XXX XXXX\n'
              'Alamat: [Alamat Kantor Anda]',
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD2691E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD2691E).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFFD2691E),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Privasi Anda adalah prioritas kami. Kami berkomitmen untuk melindungi data Anda.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}