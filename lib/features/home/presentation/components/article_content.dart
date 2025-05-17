import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/globaldata/article/article_model.dart';
import 'package:rijig_mobile/widget/appbar.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleModel data;

  const ArticleDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String? baseUrl = dotenv.env["BASE_URL"];

    return Scaffold(
      appBar: CustomAppBar(judul: "detail artikel"),
      body: SingleChildScrollView(
        padding: PaddingCustom().paddingAll(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.heading, style: Tulisan.heading()),
            Gap(8),
            Text(
              "Oleh ${data.author} • ${data.publishedAt}",
              style: TextStyle(
                fontSize: 13.sp,
                fontStyle: FontStyle.italic,
                color: greyAbsolutColor,
              ),
            ),
            Gap(30),
            if (data.coverImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "$baseUrl${data.coverImage}",
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                ),
              ),
            Gap(10),
            Divider(thickness: 1.3, color: blackNavyColor),
            Gap(60),
            Text(data.content, style: Tulisan.customText()),
          ],
        ),
      ),
    );
  }
}
