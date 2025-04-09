import 'package:flutter/material.dart';

class TagList extends StatefulWidget {
  final List<String> tags;
  final String? selectedTag;
  final Function(String) onTagSelected;

  const TagList({
    Key? key,
    required this.tags,
    this.selectedTag,
    required this.onTagSelected,
  }) : super(key: key);

  @override
  State<TagList> createState() => _TagListState();
}

class _TagListState extends State<TagList> {
  late List<String> _filteredTags;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTags = List.from(widget.tags);

    _searchController.addListener(() {
      _filterTags(_searchController.text);
    });
  }

  void _filterTags(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTags = List.from(widget.tags);
      } else {
        _filteredTags =
            widget.tags
                .where((tag) => tag.toLowerCase().contains(query.toLowerCase()))
                .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '选择标签',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索标签',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // 标签列表
          Expanded(
            child:
                _filteredTags.isEmpty
                    ? const Center(
                      child: Text(
                        '没有找到匹配的标签',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.separated(
                      itemCount: _filteredTags.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tag = _filteredTags[index];
                        final isSelected = widget.selectedTag == tag;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          title: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          trailing:
                              isSelected
                                  ? const Icon(Icons.check, color: Colors.blue)
                                  : null,
                          onTap: () {
                            widget.onTagSelected(tag);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
