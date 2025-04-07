import 'package:Navi/components/articleimage.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LitArticle extends StatefulWidget {
  const LitArticle({super.key, required this.articleData});
  final Map<String, dynamic> articleData;
  @override
  State<LitArticle> createState() => _LitArticleState();
}

class _LitArticleState extends State<LitArticle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ), // Moved margin to Container
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left avatar - clickable area
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              ProfilePage(
                                username:
                                    widget
                                        .articleData['beShareCreaterUserName'],
                              ),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, right: 6),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.articleData['beShareUserPic'],
                    ),
                  ),
                ),
              ),

              // Right content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "${widget.articleData['beShareNickName']}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Inter-Regular",
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "@${widget.articleData['beShareCreaterUserName']}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Inter",
                            color: Color.fromRGBO(104, 118, 132, 1.00),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          "·",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter-Regular",
                            color: Color.fromRGBO(104, 118, 132, 1.00),
                          ),
                        ),
                        Text(
                          "${widget.articleData['beShareUptonowTime']}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Inter-Regular",
                            color: Color.fromRGBO(111, 107, 204, 1.00),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${widget.articleData['beShareCategoryName']}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(111, 107, 204, 1.00),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    // Content text
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 6),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          "${widget.articleData['beShareContent']}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            height: 1.2,
                            fontFamily: "Inter",
                          ),
                        ),
                      ),
                    ),

                    // Article image
                    widget.articleData['beShareCoverImg'] != ""
                        ? ArticleImage(
                          imageUrls: [
                            "${widget.articleData['beShareCoverImg']}",
                          ],
                        )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
