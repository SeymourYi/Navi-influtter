import 'package:Navi/page/Home/articlelist.dart';
import 'package:flutter/material.dart';

class things extends StatefulWidget {
  const things({super.key});

  @override
  State<things> createState() => _thingsState();
}

class _thingsState extends State<things> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [Tab(text: "为你推荐"), Tab(text: "正在关注")],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              // 为你推荐标签页
              Articlelist(),
              // 正在关注标签页
              Articlelist(),
            ],
          ),
        ),
      ],
    );
  }
}
