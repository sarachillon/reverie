import 'package:flutter/material.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_widget.dart';
import 'package:frontend/screens/armarioVirtual/articulo_propio_resumen.dart';
import 'package:frontend/screens/armarioVirtual/pantalla_ver_todos.dart';
import 'package:frontend/screens/armarioVirtual/subir_foto_screen.dart';
import 'package:frontend/services/api_manager.dart';

class ArmarioScreen extends StatefulWidget {
  final int? userId;
  final VoidCallback? onContenidoActualizado;

  const ArmarioScreen({
    Key? key,
    this.userId,
    this.onContenidoActualizado,
  }): super(key: key);

  @override
  State<ArmarioScreen> createState() => ArmarioScreenState();
}

class ArmarioScreenState extends State<ArmarioScreen> {
  final ApiManager _apiManager = ApiManager();
  final List<dynamic> _articulos = [];

  @override
  void initState() {
    super.initState();
    cargarArticulosPropios();
  }

  @override
  void didUpdateWidget(covariant ArmarioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    cargarArticulosPropios();
  }

Future<void> cargarArticulosPropios() async {
  setState(() => _articulos.clear());
  try {
    final filtros = widget.userId != null ? {'usuario_id': widget.userId} : null;
    final stream = _apiManager.getArticulosPropiosStream(filtros: filtros);
    await for (final articulo in stream) {
      if (!mounted) return;
      if (articulo is Map && articulo.containsKey('categoria')) {
        setState(() => _articulos.add(articulo));
      }
    }
  } catch (e) {
    print("Error al cargar artículos propios: $e");
  }
}


  void _recargarArticulos() {
    setState(() {
      cargarArticulosPropios();
    });
  }


  Widget _buildCategoriaHorizontal(String categoria) {
    final articulosCategoria = _articulos
        .where((a) => (a['categoria'] ?? '').toString().toUpperCase() == categoria)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                categoria[0] + categoria.substring(1).toLowerCase(),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  // 1) Lanza VerTodos con el callback
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaVerTodos(
                        categoria: categoria,
                        onContenidoActualizado: widget.onContenidoActualizado,
                        usuario_id: widget.userId,
                      ),
                    ),
                  );
                  // 2) Recarga tu lista interna
                  await cargarArticulosPropios();
                  // 3) Notifica al padre (PerfilScreen)
                  widget.onContenidoActualizado?.call();
                },

                child: Row(
                  children: const [
                    Text("Ver todos", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: articulosCategoria.isEmpty
                ? ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: [
                      if (widget.userId != null)
                        GestureDetector(
                          onTap: () async {
                            final resultado = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(builder: (_) => const SubirFotoScreen()),
                            );
                            if (resultado == true) {
                              widget.onContenidoActualizado?.call();
                            }
                          },

                          child: Container(
                            width: 150,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 30, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'Añadir ${categoria.toLowerCase()}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 120,
                          width: 150,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Text(
                            'No hay ${categoria.toLowerCase()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                    ],
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: articulosCategoria.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final articulo = articulosCategoria[index];
                      return SizedBox(
                        width: 150,
                        child: GestureDetector(
                          child: ArticuloPropioWidget(
                            nombre: articulo['nombre'] ?? '',
                            articulo: articulo,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: cargarArticulosPropios,
        child: _articulos.isEmpty
            ? const Center(child: Text('No se encontraron artículos.'))
            : ListView(
                children: [
                  _buildCategoriaHorizontal('ROPA'),
                  _buildCategoriaHorizontal('CALZADO'),
                  _buildCategoriaHorizontal('ACCESORIOS'),
                  const SizedBox(height: 80),
                ],
              ),
      ),
    );
  }
}
