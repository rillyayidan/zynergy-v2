import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino library
import 'package:flutter_svg/svg.dart';
import '../core/config/assets/app_vectors.dart';
import '../core/config/theme/app_colors.dart';
import '../core/config/strings/app_text.dart';
import '../api/api_service.dart';
import 'detail_article_screen.dart';

class ArtikelScreen extends StatefulWidget {
  const ArtikelScreen({super.key});

  @override
  _ArtikelScreenState createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<ArtikelScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _generalArticles = [];
  List<Map<String, dynamic>> _filteredArticles = [];
  String _searchQuery = '';
  String _filterOption = 'Terbaru'; // Default filter option
  final TextEditingController _searchController = TextEditingController(); // Tambahkan controller
  final FocusNode _focusNode = FocusNode(); // Tambahkan FocusNode

  @override
  void initState() {
    super.initState();
    _fetchArticles();
    _focusNode.addListener(() {
      setState(() {}); // Untuk memperbarui UI ketika fokus berubah
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Jangan lupa untuk membuang controller
    _focusNode.dispose(); // Jangan lupa untuk membuang FocusNode
    super.dispose();
  }

  Future<void> _fetchArticles() async {
    try {
      final generalArticles = await _apiService.getGeneralArticles();
      setState(() {
        _generalArticles = generalArticles;
        _filteredArticles = _sortArticles(_generalArticles, _filterOption);
      });
    } catch (e) {
      print('Error fetching articles: $e');
    }
  }

  void _filterArticles(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredArticles = _sortArticles(_generalArticles, _filterOption);
      } else {
        _filteredArticles = _sortArticles(_generalArticles.where((article) {
          return article['title'].toLowerCase().contains(query.toLowerCase());
        }).toList(), _filterOption);
      }
    });
  }

  List<Map<String, dynamic>> _sortArticles(List<Map<String, dynamic>> articles, String filterOption) {
    if (filterOption == 'Terbaru') {
      // Urutkan berdasarkan created_at terbaru
      articles.sort((a, b) => b['created_at'].compareTo(a['created_at']));
    } else if (filterOption == 'Terlama') {
      // Urutkan berdasarkan created_at terlama
      articles.sort((a, b) => a['created_at'].compareTo(b['created_at']));
    }
    return articles;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String selectedFilterOption = _filterOption; // Variabel sementara untuk menyimpan pilihan

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white, // Atur background color menjadi putih
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Atur border radius menjadi 8
              ),
              title: Center(
                child: Text(
                  'Urutkan Berdasarkan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilterOption = 'Terbaru';
                        });
                      },
                      child: Text(
                        'Terbaru',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    leading: Transform.scale(
                      scale: 1.5,
                      child: CupertinoRadio(
                        value: 'Terbaru',
                        groupValue: selectedFilterOption,
                        onChanged: (value) {
                          setState(() {
                            selectedFilterOption = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ),
                  ListTile(
                    title: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilterOption = 'Terlama';
                        });
                      },
                      child: Text(
                        'Terlama',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    leading: Transform.scale(
                      scale: 1.5,
                      child: CupertinoRadio(
                        value: 'Terlama',
                        groupValue: selectedFilterOption,
                        onChanged: (value) {
                          setState(() {
                            selectedFilterOption = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Simpan pilihan filter ke state utama
                    setState(() {
                      _filterOption = selectedFilterOption;
                      _applyFilter();
                    });
                  },
                  child: Text(
                    'Terapkan',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyFilter() {
    setState(() {
      _filteredArticles = _sortArticles(_generalArticles, _filterOption);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hapus fokus dari TextField ketika menekan area di luar inputan
        _focusNode.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.7, -1), // near the top right
                radius: 0.4,
                colors: [
                  Color(0xFF4AF5CE), // Teal gradient start
                  AppColors.primary, // Teal-blue gradient end
                ],
                stops: <double>[0.0, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _searchController, // Tambahkan controller di sini
                          focusNode: _focusNode, // Tambahkan FocusNode di sini
                          onChanged: _filterArticles, // Panggil fungsi filter saat pengguna mengetik
                          decoration: InputDecoration(
                            hintText: 'Cari',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear(); // Hapus teks menggunakan controller
                                _filterArticles(''); // Bersihkan query pencarian
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Article Count and Filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Menampilkan ${_filteredArticles.length} Artikel',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showFilterDialog, // Panggil fungsi untuk menampilkan modal dialog
                            icon: SvgPicture.asset(AppVectors.iconFilter),
                            label: const Text(
                              'Filter',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 28),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            'Semua Artikel',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ..._filteredArticles.map((article) {
                          return _buildArticleCard(
                            imagePath: article['image_url'],
                            title: article['title'],
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailArticleScreen(article: article),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard({
    required String imagePath,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        elevation: (0.0),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          height: 130,
          child: Row(
            children: [
              Container(
                width: 110,
                height: 110,
                margin: EdgeInsets.only(left: 10.0, right: 4.0, bottom: 8.0, top: 8.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: Offset(0, 0)
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 130,
                          height: 34,
                          child: ElevatedButton(
                            onPressed: onPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary, // Menggunakan AppColors.primary
                              foregroundColor: Colors.white,
                              elevation: (0.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              ButtonBerandaText.selengkapnya,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}