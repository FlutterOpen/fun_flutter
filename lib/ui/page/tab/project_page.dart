import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    hide DropdownButton, DropdownMenuItem, DropdownButtonHideUnderline;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wan_android/flutter/dropdown.dart';
import 'package:wan_android/model/tree.dart';

import 'package:wan_android/ui/widget/page_state_switch.dart';
import 'package:wan_android/view_model/project_model.dart';

import '../article_list_by_category_page.dart';

class ProjectPage extends StatefulWidget {
  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ProjectCategoryModel model = ProjectCategoryModel();
  ValueNotifier<int> valueNotifier = ValueNotifier(0);
  TabController tabController;

  @override
  void initState() {
    model.initData();
    super.initState();
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider<ProjectCategoryModel>.value(
        value: model,
        child: Consumer<ProjectCategoryModel>(builder: (context, model, child) {
          if (model.busy) {
            return Center(child: CircularProgressIndicator());
          }
          if (model.error) {
            return PageStateError(onPressed: model.initData);
          }

          List<Tree> treeList = model.list;
          var primaryColor = Theme.of(context).primaryColor;

          return ValueListenableProvider<int>.value(
            value: valueNotifier,
            child: DefaultTabController(
              length: model.list.length,
              initialIndex: valueNotifier.value,
              child: Builder(
                builder: (context) {
                  if (tabController == null) {
                    tabController = DefaultTabController.of(context);
                    tabController.addListener(() {
                      valueNotifier.value = tabController.index;
                    });
                  }
                  return Scaffold(
                    appBar: AppBar(
                      title: Stack(
                        children: [
                          CategoryDropdownWidget(treeList: treeList),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            color: primaryColor.withOpacity(1),
                            child: TabBar(
                                isScrollable: true,
                                tabs: List.generate(
                                    treeList.length,
                                    (index) => Tab(
                                          text: treeList[index].name,
                                        ))),
                          )
                        ],
                      ),
                    ),
                    body: TabBarView(
                      children: List.generate(treeList.length,
                          (index) => TreeListWidget(treeList[index])),
                    ),
                  );
                },
              ),
            ),
          );
        }));
  }
}

class CategoryDropdownWidget extends StatelessWidget {
  final List<Tree> treeList;

  CategoryDropdownWidget({this.treeList});

  @override
  Widget build(BuildContext context) {
    int currentIndex = Provider.of<int>(context);
    return Align(
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Theme.of(context).primaryColor,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            elevation: 0,
            value: currentIndex,
            style: Theme.of(context).primaryTextTheme.subhead,
            items: List.generate(treeList.length, (index) {
              var theme = Theme.of(context);
              return DropdownMenuItem(
                value: index,
                child: Text(
                  treeList[index].name,
                  style: currentIndex == index
                      ? theme.primaryTextTheme.subhead
                          .apply(color: theme.accentColor)
                      : theme.primaryTextTheme.subhead,
                ),
              );
            }),
            onChanged: (value) {
              DefaultTabController.of(context).animateTo(value);
            },
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
          ),
        ),
      ),
      alignment: Alignment(1.1, -1),
    );
  }
}
