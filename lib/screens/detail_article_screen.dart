import 'package:flutter/material.dart';
import 'package:zynergy/core/config/theme/app_colors.dart';

class DetailArticleScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  DetailArticleScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            title: Text(
              "Kembali",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.chevron_left_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            automaticallyImplyLeading: false,
            titleSpacing: -10,
            floating: true, // Memungkinkan AppBar untuk muncul kembali saat scroll ke atas
            snap: true, // Membuat AppBar muncul dengan cepat saat scroll ke atas
            pinned: false, // AppBar tidak akan tetap terpasang di atas
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white, // Warna background content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      height: 200.0,
                      width: 330.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: DecorationImage(
                          image: NetworkImage(article['image_url']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      article['title'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      article['content'],
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}