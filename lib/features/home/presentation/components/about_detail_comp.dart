import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/globaldata/about/about_vmod.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:rijig_mobile/widget/skeletonize.dart';

class AboutDetailScreenComp extends StatefulWidget {
  final String data;
  const AboutDetailScreenComp({super.key, required this.data});

  @override
  State<AboutDetailScreenComp> createState() => _AboutDetailScreenCompState();
}

class _AboutDetailScreenCompState extends State<AboutDetailScreenComp> {
  @override
  void initState() {
    super.initState();
    context.read<AboutDetailViewModel>().getDetail(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    final String? baseurl = dotenv.env['BASE_URL'];
    return Scaffold(
      appBar: CustomAppBar(judul: "About Detail"),
      body: Consumer<AboutDetailViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                return SkeletonCard();
              },
            );
          }
          if (vm.errorMessage != null) return Text(vm.errorMessage!);
          return ListView.builder(
            itemCount: vm.details.length,
            itemBuilder: (context, index) {
              final detail = vm.details[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network("$baseurl${detail.imageDetail}"),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(detail.description),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
