import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_manager.dart';
import 'package:frontend/screens/outfits/widget_outfit_feed_small.dart';
import 'package:frontend/screens/outfits/widget_outfit_feed_big.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with TickerProviderStateMixin {
  final ApiManager _apiManager = ApiManager();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _outfitsStreamed = [];
  StreamSubscription<Map<String, dynamic>>? _subscription;

  bool _modoCuadricula = true;
  bool _isSearching = false;
  String _busqueda = '';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(_onTabChanged);
    _reiniciarStream();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _reiniciarStream();
    }
  }

  void _reiniciarStream() {
    _subscription?.cancel();
    _outfitsStreamed.clear();
    setState(() {});
    final tipo = _tabController.index == 0 ? 'seguidos' : 'global';
    _subscription = _apiManager.getFeedOutfitsStream(type: tipo).listen((outfit) {
      setState(() => _outfitsStreamed.add(outfit));
    }, onError: (e) {
      debugPrint('Error en el stream: $e');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outfitsFiltrados = _outfitsStreamed.where((outfit) {
      final titulo = (outfit['titulo'] ?? '').toString().toLowerCase();
      return titulo.contains(_busqueda.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _busqueda = value),
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Buscar outfits...',
                  border: InputBorder.none,
                ),
              )
            : Image.asset('assets/logo_reverie_text.png', height: 30),
        leading: IconButton(
          icon: Icon(
            _modoCuadricula ? Icons.auto_awesome_mosaic : Icons.crop_portrait,
            color: const Color(0xFFD4AF37),
          ),
          onPressed: () => setState(() => _modoCuadricula = !_modoCuadricula),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: const Color(0xFFD4AF37)),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _busqueda = '';
                }
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Seguidores'),
            Tab(text: 'Global'),
          ],
        ),
      ),
      body: _isSearching && outfitsFiltrados.isEmpty
          ? const Center(child: Text('No hay resultados'))
          : _modoCuadricula
              ? WidgetOutfitFeedSmall(outfits: outfitsFiltrados)
              : WidgetOutfitFeedBig(outfits: outfitsFiltrados),
    );
  }
}
