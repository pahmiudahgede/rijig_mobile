// lib/features/home/presentation/widgets/request_list_view.dart
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/home/model/c_request_list_dummymodel.dart';
import 'package:rijig_mobile/features/home/presentation/screen/collector/widgets/request_card.dart';
import 'package:rijig_mobile/features/home/presentation/screen/collector/widgets/request_detail_dialog.dart';

class RequestListView extends StatefulWidget {
  final RequestType requestType;

  const RequestListView({super.key, required this.requestType});

  @override
  State<RequestListView> createState() => _RequestListViewState();
}

class _RequestListViewState extends State<RequestListView> {
  List<RequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _requests =
          widget.requestType == RequestType.all
              ? RequestDataService.getAllRequests()
              : [RequestDataService.getMyRequest()];
      _isLoading = false;
    });
  }

  void _onRequestTap(RequestModel request) {
    showDialog(
      context: context,
      builder:
          (context) => RequestDetailDialog(
            request: request,
            onConfirm: () => _onRequestConfirm(request),
          ),
    );
  }

  void _onRequestConfirm(RequestModel request) {
    // Navigator.pop(context);
    router.push("/cmapview");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Iconsax.tick_circle, color: whiteColor),
            const SizedBox(width: 8),
            Text('Pickup dari ${request.name} dikonfirmasi'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_requests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = _requests[index];
          return RequestCard(
            request: request,
            onTap: () => _onRequestTap(request),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.box, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            widget.requestType == RequestType.all
                ? 'Belum ada request'
                : 'Belum ada request untukmu',
            style: Tulisan.subheading(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull untuk refresh',
            style: Tulisan.body(color: Colors.grey.shade500, fontsize: 14),
          ),
        ],
      ),
    );
  }
}
