import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/enums/enums.dart';
import 'package:frontend/services/api_manager.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const EditarPerfilScreen({super.key, required this.usuario});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final ApiManager _apiManager = ApiManager();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _edadController;
  GeneroPrefEnum? _generoPref;
  File? _nuevaFoto;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.usuario['username']);
    _edadController = TextEditingController(text: widget.usuario['edad'].toString());
    _generoPref = GeneroPrefEnum.values.firstWhere((e) => e.name == widget.usuario['genero_pref']);
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      if (_nuevaFoto == null && widget.usuario['foto_perfil'] != null) {
        try {
          final base64Str = widget.usuario['foto_perfil'].split(',').last;
          final bytes = base64Decode(base64Str);
          final tempFile = File('${Directory.systemTemp.path}/temp_perfil.png');
          await tempFile.writeAsBytes(bytes);
          _nuevaFoto = tempFile;
        } catch (_) {
          _nuevaFoto = null;
        }
      }

      await _apiManager.editarPerfilUsuario(
        username: _usernameController.text,
        edad: int.parse(_edadController.text),
        generoPref: _generoPref!,
        fotoPerfil: _nuevaFoto,
      );

      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _nuevaFoto = File(picked.path));
  }

  void _mostrarDialogoBorrado(BuildContext context) {
    final TextEditingController _confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar borrado"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Escribe 'confirmar' para eliminar tu cuenta. Esta acción es irreversible."),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: "confirmar"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_confirmController.text.toLowerCase() == 'confirmar') {
                await _apiManager.eliminarCuenta();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/auth', (_) => false);
                }
              }
            },
            style: ElevatedButton.styleFrom(),
            child: const Text("Eliminar cuenta"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagen = _nuevaFoto != null
        ? FileImage(_nuevaFoto!)
        : widget.usuario['foto_perfil'] != null
            ? MemoryImage(base64Decode(widget.usuario['foto_perfil']))
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
        'Editar Perfil',
        style: GoogleFonts.dancingScript(
          fontSize: 30,
          color: Color(0xFFD4AF37),
          fontWeight: FontWeight.w600,
        ),
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: imagen is ImageProvider ? imagen : null,
                            child: imagen == null ? const Icon(Icons.person, size: 50) : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: _seleccionarImagen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: "Nombre de usuario"),
                      validator: (v) => v == null || v.isEmpty ? "Campo requerido" : null,
                    ),
                    TextFormField(
                      controller: _edadController,
                      decoration: const InputDecoration(labelText: "Edad"),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || int.tryParse(v) == null ? "Edad inválida" : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<GeneroPrefEnum>(
                      value: _generoPref,
                      decoration: const InputDecoration(labelText: "Tipo de ropa"),
                      items: GeneroPrefEnum.values.map((g) {
                        return DropdownMenuItem(
                          value: g,
                          child: Text(g.value),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _generoPref = val),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Guardar cambios"),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    "¿Quieres eliminar tu cuenta?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _mostrarDialogoBorrado(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Borrar cuenta"),
                  ),
                ],
              ),
            ],
          ),

        ),
      ),
    );
  }
}
