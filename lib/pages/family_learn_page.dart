import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../navigation/family_navigation_handler.dart';

class FamilyLearnScreen extends StatefulWidget {
  const FamilyLearnScreen({super.key});

  @override
  State<FamilyLearnScreen> createState() => _FamilyLearnScreenState();
}

class _FamilyLearnScreenState extends State<FamilyLearnScreen> {
  List<dynamic> _articles = [];
  List<dynamic> _filteredArticles = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _linkedPatientName = "Sarah";
  int _currentIndex = 4; // Learn tab is active
  
  final List<String> _categories = [
    'All',
    'Pregnancy',
    'Health',
    'Nutrition',
    'Baby Care',
    'Parenting',
    'Emergency',
    'Wellness'
  ];

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('https://newsapi.org/v2/everything?q=pregnancy%20OR%20parenting%20OR%20baby%20OR%20motherhood%20OR%20maternal%20health&apiKey=5ab8635d12744f488a9cc7f24f7e4d70'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            _articles = data['articles'];
            _filteredArticles = _articles;
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load articles: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load articles. Please try again later.';
        _isLoading = false;
      });
    }
  }

  void _filterArticles(int categoryIndex) {
    setState(() {
      _selectedCategory = categoryIndex;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchQuery.trim().toLowerCase();
    setState(() {
      _filteredArticles = _articles.where((article) {
        final title = article['title']?.toString().toLowerCase() ?? '';
        final description = article['description']?.toString().toLowerCase() ?? '';
        final content = article['content']?.toString().toLowerCase() ?? '';

        // Category filter
        final matchesCategory = _selectedCategory == 0
            ? true
            : (title.contains(_categories[_selectedCategory].toLowerCase()) ||
                description.contains(_categories[_selectedCategory].toLowerCase()) ||
                content.contains(_categories[_selectedCategory].toLowerCase()));

        // Search query filter
        final matchesQuery = query.isEmpty
            ? true
            : (title.contains(query) || description.contains(query) || content.contains(query));

        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  // FIXED: Added the custom app bar with working profile navigation
  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE91E63).withOpacity(0.9),
            const Color(0xFF2196F3).withOpacity(0.9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            child: Center(
              child: Text(
                'Safe Mother',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          // FIXED: Added GestureDetector for profile navigation
          GestureDetector(
            onTap: () => FamilyNavigationHandler.navigateToProfile(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: const Icon(
                Icons.person_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC), // Light pink
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 'Home', _currentIndex == 0),
            _buildNavItem(Icons.assignment_outlined, 'View Log', _currentIndex == 1),
            _buildNavItem(Icons.calendar_today_outlined, 'Appointments', _currentIndex == 2),
            _buildNavItem(Icons.contact_phone_outlined, 'Contacts', _currentIndex == 3),
            _buildNavItem(Icons.menu_book_outlined, 'Learn', _currentIndex == 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    final index = _getIndexForLabel(label);
    return GestureDetector(
      onTap: () => FamilyNavigationHandler.navigateToScreen(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFF8BBD0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFFE91E63).withOpacity(0.6),
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isActive ? const Color(0xFFE91E63) : const Color(0xFFE91E63).withOpacity(0.6),
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  int _getIndexForLabel(String label) {
    switch (label) {
      case 'Home':
        return 0;
      case 'View Log':
        return 1;
      case 'Appointments':
        return 2;
      case 'Contacts':
        return 3;
      case 'Learn':
        return 4;
      default:
        return -1;
    }
  }

  Widget _buildCategoryChip(int index) {
    final isSelected = _selectedCategory == index;
    return GestureDetector(
      onTap: () => _filterArticles(index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFFF8BBD0)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE91E63).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          _categories[index],
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFFE91E63),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(dynamic article, int index) {
    final imageUrl = article['urlToImage'];
    final title = article['title'] ?? 'No title available';
    final description = article['description'] ?? 'No description available';
    final source = article['source']['name'] ?? 'Unknown source';
    final publishedAt = article['publishedAt'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E5F5), // Light purple
            Color(0xFFFCE4EC), // Light pink
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Header with Image
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Source and Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    source,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE91E63),
                    ),
                  ),
                ),
                const Spacer(),
                if (publishedAt.isNotEmpty)
                  Text(
                    _formatDate(publishedAt),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF757575),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C2C2C),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF757575),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Read More Button
            SizedBox(
              width: double.infinity,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
                ),
                child: TextButton(
                  onPressed: () => _showArticleDetails(article),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article, color: Color(0xFFE91E63), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Read Article',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE91E63),
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
    );
  }

  void _showArticleDetails(dynamic article) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF3E5F5),
                  Color(0xFFFCE4EC),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Article Image
                  if (article['urlToImage'] != null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(article['urlToImage']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  
                  // Article Title
                  Text(
                    article['title'] ?? 'No title',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Article Description
                  Text(
                    article['description'] ?? 'No description',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Article Content
                  if (article['content'] != null)
                    Text(
                      article['content'].toString().replaceAll('[+\\d chars]', ''),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF5A5A5A),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Published Date and Source
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (article['publishedAt'] != null)
                        Text(
                          'Published: ${_formatDate(article['publishedAt'])}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      if (article['source']['name'] != null)
                        Text(
                          'Source: ${article['source']['name']}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF757575),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailActionButton(
                          'Read Full Article',
                          Icons.launch,
                          const Color(0xFFE91E63),
                          () => _launchURL(article['url']),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDetailActionButton(
                          'Close',
                          Icons.close,
                          const Color(0xFF757575),
                          () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open article: $url'),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFCE4EC), // Light pink
              Color(0xFFE3F2FD), // Light blue
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: Column(
          children: [
            // FIXED: Using the custom app bar with working profile navigation
            _buildCustomAppBar(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF3E5F5), // Light purple
                            Color(0xFFFCE4EC), // Light pink
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book,
                              color: Color(0xFF2196F3),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pregnancy & Parenting Guide",
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2C2C2C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Latest articles and resources for ${_linkedPatientName}\'s pregnancy journey',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Color(0xFFE91E63)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search pregnancy articles...',
                                border: InputBorder.none,
                                hintStyle: GoogleFonts.inter(
                                  color: const Color(0xFF757575),
                                ),
                              ),
                              onChanged: (val) {
                                _searchQuery = val;
                                _applyFilters();
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _searchQuery = '';
                                _applyFilters();
                              },
                              icon: Icon(Icons.close, color: Color(0xFFE91E63)),
                            ),
                        ],
                      ),
                    ),

                    // Categories
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return _buildCategoryChip(index);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_isLoading) ...[
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFFE91E63),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading articles...',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF3E5F5),
                              Color(0xFFFCE4EC),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: const Color(0xFFE91E63).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Unable to Load Articles',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91E63).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
                              ),
                              child: TextButton(
                                onPressed: _fetchArticles,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                ),
                                child: Text(
                                  'Try Again',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFE91E63),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_filteredArticles.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF3E5F5),
                              Color(0xFFFCE4EC),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: const Color(0xFFE91E63).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Articles Found',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or category filter',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ..._filteredArticles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final article = entry.value;
                        return _buildArticleCard(article, index);
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}