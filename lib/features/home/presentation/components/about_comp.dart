import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/globaldata/about/about_vmod.dart';
import 'package:rijig_mobile/widget/skeletonize.dart';

class AboutComponent extends StatefulWidget {
  const AboutComponent({super.key});

  @override
  AboutComponentState createState() => AboutComponentState();
}

class AboutComponentState extends State<AboutComponent> {
  int _current = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AboutViewModel>(context, listen: false).getAboutList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? baseUrl = dotenv.env["BASE_URL"];

    return Consumer<AboutViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (context, index) {
              return SkeletonCard();
            },
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(child: Text(viewModel.errorMessage!));
        }

        if (viewModel.aboutList == null || viewModel.aboutList!.isEmpty) {
          return Center(child: Text("No data available"));
        }

        List<Map<String, dynamic>> imageSliders =
            viewModel.aboutList!.map((about) {
              return {
                "iconPath": "$baseUrl${about.coverImage}",
                "route": about.id,
                "title": about.title,
              };
            }).toList();

        return Column(
          children: [
            CarouselSlider(
              items:
                  imageSliders.map((imageData) {
                    return InkWell(
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageData["iconPath"]),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                color: blackNavyColor.withValues(alpha: 0.5),
                                child: Text(
                                  imageData["title"],
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        debugPrint("Tapped on ${imageData['route']}");
                        router.push("/aboutdetail", extra: imageData["route"]);
                      },
                    );
                  }).toList(),
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 8),
                enlargeCenterPage: true,
                height: 150,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  imageSliders.asMap().entries.map((entry) {
                    return GestureDetector(
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.blue
                                  : Colors.blue)
                              .withValues(
                                alpha: _current == entry.key ? 0.9 : 0.2,
                              ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        );
      },
    );
  }
}
