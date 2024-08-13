import 'package:flutter/material.dart';

class TagEditPage extends StatefulWidget {
  @override
  _TagEditPageState createState() => _TagEditPageState();
}

class _TagEditPageState extends State<TagEditPage> {
  final List<String> _allTags = [
    '청소', '말동무', '산책', '요리', '쇼핑', '병원 동행',
    '집안일', '교통 도움', '기술 지원', '독서', '운동', '학습 지원'
  ];
  List<String> _filteredTags = [];
  List<String> _selectedTags = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTags = _allTags;
  }

  void _filterTags(String query) {
    setState(() {
      _filteredTags = _allTags
          .where((tag) => tag.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else if (_selectedTags.length < 5) {
        _selectedTags.add(tag);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('최대 5개의 태그만 선택할 수 있습니다.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('태그 수정'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '태그 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterTags,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _filteredTags.length,
              itemBuilder: (context, index) {
                final tag = _filteredTags[index];
                final isSelected = _selectedTags.contains(tag);
                return ElevatedButton(
                  child: Text(tag),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: isSelected ? Colors.white : Colors.black, backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                  ),
                  onPressed: () => _toggleTag(tag),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              child: Text('저장'),
              onPressed: () {
                // TODO: 선택된 태그를 저장하고 대시보드로 돌아가기
                Navigator.pop(context, _selectedTags);
              },
            ),
          ),
        ],
      ),
    );
  }
}
