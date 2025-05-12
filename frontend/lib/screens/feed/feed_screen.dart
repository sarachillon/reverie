import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:frontend/screens/outfits/outfit_widget.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final ApiManager _apiManager = ApiManager();

  List<Map<String, dynamic>> _outfits = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _fetchOutfits();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchOutfits();
    }
  }

  Future<void> _fetchOutfits() async {
    setState(() => _isLoading = true);
    try {
      final newOutfits = await _apiManager.getFeedOutfits(page: _page, pageSize: _pageSize);
      setState(() {
        _page++;
        _outfits.addAll(newOutfits.cast<Map<String, dynamic>>());
        if (newOutfits.length < _pageSize) _hasMore = false;
      });
    } catch (e) {
      debugPrint("Error al cargar outfits del feed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<ImageProvider<Object>> decodeBase64OrMock(String? base64) async {
    try {
      if (base64 != null && base64.isNotEmpty) {
        final bytes = base64Decode(base64);
        return MemoryImage(bytes);
      }
    } catch (_) {}
    return const AssetImage('assets/mock/ropa_mock.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < _outfits.length) {
                    final outfit = _outfits[index];
                    return OutfitWidget(
                      outfit: outfit,
                      decodeBase64OrMock: decodeBase64OrMock,
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
                childCount: _hasMore ? _outfits.length + 1 : _outfits.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
