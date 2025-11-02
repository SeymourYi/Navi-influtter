import 'package:Navi/page/Home/articlelist.dart';
import 'package:Navi/page/Home/friendarticlelist.dart';
import 'package:flutter/material.dart';

class things extends StatefulWidget {
  final Function(double)? onScrollChanged; // 添加滚动变化回调

  const things({super.key, this.onScrollChanged});

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
            labelColor: Colors.black, // 选中标签字体颜色改为黑色
            unselectedLabelColor: Colors.grey, // 未选中标签保持灰色
            indicatorColor: Color(0xFF6201E7), // 主题色
            indicatorWeight: 3, // 指示线粗细
            tabs: const [Tab(text: "为你推荐"), Tab(text: "正在关注")],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 为你推荐标签页
              Articlelist(onScrollChanged: widget.onScrollChanged),
              // 正在关注标签页
              FriendArticlelist(onScrollChanged: widget.onScrollChanged),
            ],
          ),
        ),
      ],
    );
  }
}
