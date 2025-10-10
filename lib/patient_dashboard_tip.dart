import 'navigation_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Add this import

void main() {
  runApp(const PregnancyTip());
}

class PregnancyTip extends StatelessWidget {
  const PregnancyTip({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Mother - Learn',
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF9F7F9),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFF9C27B0),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)),
        ),
      ),
      home: const LearnScreen(),
    );
  }
}

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final int _currentIndex = 3; // Learn is active
  List<dynamic> _articles = [];
  List<dynamic> _filteredArticles = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  final List<String> _categories = [
    'All',
    'Pregnancy',
    'Health',
    'Nutrition',
    'Baby',
    'Parenting'
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
        Uri.parse('https://newsapi.org/v2/everything?q=pregnancy%20OR%20parenting%20OR%20baby%20OR%20motherhood&apiKey=5ab8635d12744f488a9cc7f24f7e4d70'),
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

  void _showArticleDetails(dynamic article) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111611),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Article Description
                  Text(
                    article['description'] ?? 'No description',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF638763),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Article Content
                  if (article['content'] != null)
                    Text(
                      article['content'].toString().replaceAll('[+\\d chars]', ''),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A5A5A),
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      if (article['source']['name'] != null)
                        Text(
                          'Source: ${article['source']['name']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Read More Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Open article in browser using url_launcher
                        final url = article['url'];
                        if (url != null && url.toString().isNotEmpty && url.toString() != 'null') {
                          _launchURL(url.toString());
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Article URL is not available'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Read Full Article',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xFF638763),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to launch URL
  Future<void> _launchURL(String url) async {
    print('Attempting to launch URL: $url');
    try {
      // Validate URL format
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        throw 'Invalid URL format: URL must start with http:// or https://';
      }

      final Uri uri = Uri.parse(url);
      print('Parsed URI: $uri');

      // Check if URI is valid
      if (!uri.hasScheme || !uri.hasAuthority) {
        throw 'Invalid URI: Missing scheme or authority';
      }

      // Try to launch directly without canLaunchUrl check
      final result = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // This opens in Chrome/browser
      );
      print('Launch result: $result');
      if (!result) {
        throw 'launchUrl returned false';
      }
    } catch (e) {
      // If direct launch fails, show error message
      print('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open article. Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
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

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    NavigationHandler.navigateToScreen(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.assignment_outlined, 'Log', 1),
            _buildNavItem(Icons.calendar_today, 'Consultation', 2),
            _buildNavItem(Icons.school_outlined, 'Learn', 3),
            _buildNavItem(Icons.chat_outlined, 'Chat', 4),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5E8FF), Color(0xFFF9F7F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Decorative elements
          Positioned(
            top: -50,
            left: -30,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: const Color(0xFFD1C4E9).withOpacity(0.4),
                ),
              ),
            ),
          ),
          
          Positioned(
            top: 100,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE1BEE7).withOpacity(0.3),
              ),
            ),
          ),
          
          Positioned(
            right: -60,
            bottom: -90,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: const Color(0xFFC5CAE9).withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with back button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 8,
                    right: 16,
                    bottom: 8,
                  ),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          NavigationHandler.navigateToScreen(context, 0);
                        },
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF111611)),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Learn',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF111611),
                            fontSize: 18,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
                
                // Search Bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: double.infinity,
                                  padding: const EdgeInsets.only(left: 16),
                                  decoration: const ShapeDecoration(
                                    color: Color(0xFFEFF4EF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.search, color: Color(0xFF638763)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: double.infinity,
                                    padding: const EdgeInsets.only(top: 8, left: 8, right: 16, bottom: 8),
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFFEFF4EF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _searchController,
                                            decoration: const InputDecoration(
                                              hintText: 'Search articles',
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(color: Color(0xFF638763)),
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
                                              setState(() {});
                                            },
                                            icon: const Icon(Icons.close, color: Color(0xFF638763)),
                                          ),
                                      ],
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
                
                // Categories
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: Color(0xFFDBE5DB),
                            ),
                          ),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(_categories.length, (index) {
                              return GestureDetector(
                                onTap: () {
                                  _filterArticles(index);
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(top: 16, bottom: 13, left: 8, right: 8),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 3,
                                        color: _selectedCategory == index 
                                            ? const Color(0xFFE91E63) 
                                            : const Color(0xFFE5E8EA),
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _categories[index],
                                        style: TextStyle(
                                          color: _selectedCategory == index 
                                              ? const Color(0xFF111611) 
                                              : const Color(0xFF638763),
                                          fontSize: 14,
                                          fontFamily: 'Lexend',
                                          fontWeight: FontWeight.w700,
                                          height: 1.50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Articles List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                          ),
                        )
                      : _errorMessage.isNotEmpty
                          ? Center(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Color(0xFF638763),
                                  fontSize: 16,
                                  fontFamily: 'Lexend',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : _filteredArticles.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No articles found in this category',
                                    style: TextStyle(
                                      color: Color(0xFF638763),
                                      fontSize: 16,
                                      fontFamily: 'Lexend',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _filteredArticles.length,
                                  itemBuilder: (context, index) {
                                    final article = _filteredArticles[index];
                                    return GestureDetector(
                                      onTap: () {
                                        _showArticleDetails(article);
                                      },
                                      child: _buildArticleCard(
                                        category: _categories[_selectedCategory],
                                        title: article['title'] ?? 'No title',
                                        description: article['description'] ?? 'No description',
                                        imageUrl: article['urlToImage'],
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArticleCard({
    required String category,
    required String title,
    required String description,
    required String? imageUrl,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: 228,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF638763),
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111611),
                      fontSize: 16,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF638763),
                      fontSize: 14,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: NetworkImage("https://placehold.co/130x130?text=No+Image"),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFE91E63) : const Color(0xFF9575CD),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
