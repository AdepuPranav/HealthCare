import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen> {
  final List<String> _categories = [
    'All',
    'Nutrition',
    'Exercise',
    'Mental Health',
    'Sleep',
    'Preventive Care',
  ];

  final translator = GoogleTranslator();

  // Available languages
  final Map<String, String> _languages = {
    'English': 'en',
    'Hindi': 'hi',
    'Telugu': 'te',
    'Tamil': 'ta',
  };

  String _selectedLanguage = 'English';
  String _selectedCategory = 'All';

  // Translated category names
  Map<String, Map<String, String>> _translatedCategories = {};

  // Track if translations are loading
  bool _isLoading = false;

  // Sample health tips data with original English content
  final List<HealthTip> _originalHealthTips = [
    HealthTip(
      title: 'Stay Hydrated',
      description: 'Drink at least 8 glasses of water daily to maintain proper bodily functions and energy levels.',
      category: 'Nutrition',
      iconData: Icons.water_drop,
      color: Colors.blue,
    ),
    HealthTip(
      title: 'Balanced Diet',
      description: 'Include a variety of fruits, vegetables, whole grains, and lean proteins in your daily meals.',
      category: 'Nutrition',
      iconData: Icons.restaurant,
      color: Colors.green,
    ),
    HealthTip(
      title: '30 Minutes of Exercise',
      description: 'Aim for at least 30 minutes of moderate physical activity most days of the week.',
      category: 'Exercise',
      iconData: Icons.fitness_center,
      color: Colors.orange,
    ),
    HealthTip(
      title: 'Practice Mindfulness',
      description: 'Take 10 minutes each day for meditation or deep breathing to reduce stress and improve mental clarity.',
      category: 'Mental Health',
      iconData: Icons.self_improvement,
      color: Colors.purple,
    ),
    HealthTip(
      title: 'Sleep Schedule',
      description: 'Maintain a consistent sleep schedule with 7-9 hours of quality sleep per night.',
      category: 'Sleep',
      iconData: Icons.bedtime,
      color: Colors.indigo,
    ),
    HealthTip(
      title: 'Regular Check-ups',
      description: 'Schedule annual physical examinations to catch potential health issues early.',
      category: 'Preventive Care',
      iconData: Icons.medical_services,
      color: Colors.red,
    ),
    HealthTip(
      title: 'Limit Screen Time',
      description: 'Take breaks from screens every 20-30 minutes to reduce eye strain and improve focus.',
      category: 'Mental Health',
      iconData: Icons.phonelink_erase,
      color: Colors.teal,
    ),
    HealthTip(
      title: 'Strength Training',
      description: 'Include strength training exercises at least twice a week to maintain muscle mass and bone density.',
      category: 'Exercise',
      iconData: Icons.fitness_center,
      color: Colors.deepOrange,
    ),
    HealthTip(
      title: 'Healthy Snacking',
      description: 'Choose nuts, fruits, or yogurt instead of processed snacks to maintain energy and nutrition.',
      category: 'Nutrition',
      iconData: Icons.apple,
      color: Colors.green,
    ),
    HealthTip(
      title: 'Wind Down Routine',
      description: 'Establish a relaxing pre-sleep routine to improve sleep quality and reduce insomnia.',
      category: 'Sleep',
      iconData: Icons.nightlight,
      color: Colors.indigo,
    ),
    HealthTip(
      title: 'Vaccination Schedule',
      description: 'Stay up-to-date with recommended vaccines for your age and health conditions.',
      category: 'Preventive Care',
      iconData: Icons.vaccines,
      color: Colors.red,
    ),
    HealthTip(
      title: 'Social Connections',
      description: 'Maintain social relationships as they contribute significantly to mental health and well-being.',
      category: 'Mental Health',
      iconData: Icons.people,
      color: Colors.purple,
    ),
  ];

  // Translated health tips data
  List<HealthTip> _healthTips = [];

  @override
  void initState() {
    super.initState();
    _healthTips = List.from(_originalHealthTips);
    _translateCategories();
  }

  // Translate all category names
  Future<void> _translateCategories() async {
    for (String language in _languages.keys) {
      String langCode = _languages[language]!;
      if (langCode == 'en') {
        // No need to translate English
        continue;
      }

      Map<String, String> translatedMap = {};
      for (String category in _categories) {
        final translation = await translator.translate(category, from: 'en', to: langCode);
        translatedMap[category] = translation.text;
      }

      setState(() {
        _translatedCategories[language] = translatedMap;
      });
    }
  }

  // Translate content based on selected language
  Future<void> _translateContent() async {
    if (_selectedLanguage == 'English') {
      setState(() {
        _healthTips = List.from(_originalHealthTips);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String langCode = _languages[_selectedLanguage]!;
    List<HealthTip> translatedTips = [];

    for (HealthTip tip in _originalHealthTips) {
      final translatedTitle = await translator.translate(tip.title, from: 'en', to: langCode);
      final translatedDesc = await translator.translate(tip.description, from: 'en', to: langCode);

      translatedTips.add(
          HealthTip(
            title: translatedTitle.text,
            description: translatedDesc.text,
            category: tip.category, // Category is used for filtering, keep original
            iconData: tip.iconData,
            color: tip.color,
          )
      );
    }

    setState(() {
      _healthTips = translatedTips;
      _isLoading = false;
    });
  }

  // Get translated category name
  String _getTranslatedCategory(String category) {
    if (_selectedLanguage == 'English' || !_translatedCategories.containsKey(_selectedLanguage)) {
      return category;
    }

    return _translatedCategories[_selectedLanguage]?[category] ?? category;
  }

  // Change the language and translate content
  void _changeLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    _translateContent();
  }

  List<HealthTip> get filteredTips {
    if (_selectedCategory == 'All') {
      return _healthTips;
    } else {
      return _healthTips.where((tip) => tip.category == _selectedCategory).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tips'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          // Language selection button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _buildLanguageDropdown(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildCategorySelector(),
          Expanded(
            child: _buildTipsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.translate),
          const SizedBox(width: 4),
          Text(_selectedLanguage, style: const TextStyle(fontSize: 14)),
        ],
      ),
      onSelected: _changeLanguage,
      itemBuilder: (BuildContext context) {
        return _languages.keys.map((String language) {
          return PopupMenuItem<String>(
            value: language,
            child: Text(language),
          );
        }).toList();
      },
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _getTranslatedCategory(category),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipsList() {
    return filteredTips.isEmpty
        ? Center(
      child: Text(
        _selectedLanguage == 'English'
            ? 'No tips available for this category'
            : _translatedCategories[_selectedLanguage]?['No tips available for this category'] ?? 'No tips available for this category',
        style: const TextStyle(fontSize: 16),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTips.length,
      itemBuilder: (context, index) {
        final tip = filteredTips[index];
        return _buildTipCard(tip);
      },
    );
  }

  Widget _buildTipCard(HealthTip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tip.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            tip.iconData,
            color: tip.color,
            size: 24,
          ),
        ),
        title: Text(
          tip.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          _getTranslatedCategory(tip.category),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  tip.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${tip.title} saved to favorites!')),
                        );
                      },
                      icon: const Icon(Icons.favorite_border, size: 20),
                      label: Text(_selectedLanguage == 'English' ? 'Save' :
                      _translatedCategories[_selectedLanguage]?['Save'] ?? 'Save'),
                      style: TextButton.styleFrom(
                        foregroundColor: tip.color,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sharing ${tip.title}...')),
                        );
                      },
                      icon: const Icon(Icons.share, size: 20),
                      label: Text(_selectedLanguage == 'English' ? 'Share' :
                      _translatedCategories[_selectedLanguage]?['Share'] ?? 'Share'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HealthTip {
  final String title;
  final String description;
  final String category;
  final IconData iconData;
  final Color color;

  HealthTip({
    required this.title,
    required this.description,
    required this.category,
    required this.iconData,
    required this.color,
  });
}