import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SVC Service',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVC Service'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.deepPurple,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Clientes'),
            Tab(icon: Icon(Icons.build), text: 'Serviços'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ClientRegistrationForm(), ServiceRegistrationForm()],
      ),
    );
  }
}

class ClientRegistrationForm extends StatefulWidget {
  const ClientRegistrationForm({super.key});

  @override
  State<ClientRegistrationForm> createState() => _ClientRegistrationFormState();
}

class _ClientRegistrationFormState extends State<ClientRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  List<Map<String, dynamic>> _clientes = [];

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    final clientes = await DatabaseHelper.instance.getClientes();
    setState(() {
      _clientes = clientes;
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF3EFFF),
      foregroundColor: Colors.deepPurple,
      elevation: 2,
      shadowColor: Colors.black12,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      splashFactory: NoSplash.splashFactory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Nome'),
                    validator:
                        (value) => value!.isEmpty ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration('Telefone'),
                    keyboardType: TextInputType.phone,
                    validator:
                        (value) => value!.isEmpty ? 'Informe o telefone' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration('Endereço'),
                    validator:
                        (value) => value!.isEmpty ? 'Informe o endereço' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await DatabaseHelper.instance.insertCliente({
                          'nome': _nameController.text,
                          'telefone': _phoneController.text,
                          'endereco': _addressController.text,
                        });
                        _nameController.clear();
                        _phoneController.clear();
                        _addressController.clear();
                        _loadClientes();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cliente salvo no banco!'),
                          ),
                        );
                      }
                    },
                    style: _buttonStyle(),
                    child: const Text('Cadastrar Cliente'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Clientes cadastrados:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _clientes.length,
              itemBuilder: (context, index) {
                final c = _clientes[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(c['nome']),
                  subtitle: Text('${c['telefone']} - ${c['endereco']}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

class ServiceRegistrationForm extends StatefulWidget {
  const ServiceRegistrationForm({super.key});

  @override
  State<ServiceRegistrationForm> createState() =>
      _ServiceRegistrationFormState();
}

class _ServiceRegistrationFormState extends State<ServiceRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaInicioController = TextEditingController();
  final _horaFimController = TextEditingController();

  int? _selectedClientId;
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _vinculos = [];

  @override
  void initState() {
    super.initState();
    _loadClientes();
    _loadVinculos();
  }

  Future<void> _loadClientes() async {
    final clientes = await DatabaseHelper.instance.getClientes();
    setState(() {
      _clientes = clientes;
    });
  }

  Future<void> _loadVinculos() async {
    final vinculos = await DatabaseHelper.instance.getVinculosCompletos();
    setState(() {
      _vinculos = vinculos;
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF3EFFF),
      foregroundColor: Colors.deepPurple,
      elevation: 2,
      shadowColor: Colors.black12,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      splashFactory: NoSplash.splashFactory,
    );
  }

  double _calcularValorTotal(String inicio, String fim, double preco) {
    try {
      final inicioParts = inicio.split(':').map(int.parse).toList();
      final fimParts = fim.split(':').map(int.parse).toList();
      final durInicio = Duration(
        hours: inicioParts[0],
        minutes: inicioParts[1],
      );
      final durFim = Duration(hours: fimParts[0], minutes: fimParts[1]);
      final horas = (durFim - durInicio).inMinutes / 60.0;
      return horas * preco;
    } catch (_) {
      return 0.0;
    }
  }

  TextInputFormatter horaFormatter() {
    return FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}:?\d{0,2}$'));
  }

  TextInputFormatter dataFormatter() {
    return FilteringTextInputFormatter.allow(
      RegExp(r'^\d{0,2}/?\d{0,2}/?\d{0,4}$'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    decoration: _inputDecoration('Selecionar Cliente'),
                    value: _selectedClientId,
                    items:
                        _clientes.map((c) {
                          return DropdownMenuItem<int>(
                            value: c['id'],
                            child: Text('${c['nome']} - ${c['telefone']}'),
                          );
                        }).toList(),
                    onChanged:
                        (value) => setState(() => _selectedClientId = value),
                    validator:
                        (value) =>
                            value == null ? 'Selecione um cliente' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Nome do Serviço'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Informe o nome do serviço' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration('Descrição'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Informe a descrição' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: _inputDecoration('Preço por hora'),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Informe o preço';
                      if (double.tryParse(value) == null)
                        return 'Valor inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dataController,
                    decoration: _inputDecoration('Data do serviço'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [dataFormatter()],
                    validator:
                        (value) =>
                            value!.isEmpty ||
                                    !RegExp(
                                      r'^\d{2}/\d{2}/\d{4}$',
                                    ).hasMatch(value)
                                ? 'Formato: dd/MM/yyyy'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _horaInicioController,
                    decoration: _inputDecoration('Hora início'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [horaFormatter()],
                    validator:
                        (value) =>
                            value!.isEmpty ||
                                    !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)
                                ? 'Formato: HH:mm'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _horaFimController,
                    decoration: _inputDecoration('Hora fim'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [horaFormatter()],
                    validator:
                        (value) =>
                            value!.isEmpty ||
                                    !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)
                                ? 'Formato: HH:mm'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final servicoId = await DatabaseHelper.instance
                            .insertServico({
                              'nome': _nameController.text,
                              'descricao': _descriptionController.text,
                              'preco':
                                  double.tryParse(_priceController.text) ?? 0.0,
                            });

                        await DatabaseHelper.instance.insertVinculoDetalhado(
                          clienteId: _selectedClientId!,
                          servicoId: servicoId,
                          data: _dataController.text,
                          horaInicio: _horaInicioController.text,
                          horaFim: _horaFimController.text,
                        );

                        _nameController.clear();
                        _descriptionController.clear();
                        _priceController.clear();
                        _dataController.clear();
                        _horaInicioController.clear();
                        _horaFimController.clear();
                        await _loadVinculos();

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Serviço vinculado ao cliente!'),
                            ),
                          );
                        }
                      }
                    },
                    style: _buttonStyle(),
                    child: const Text('Cadastrar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Histórico de Serviços Vinculados:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _vinculos.length,
              itemBuilder: (context, index) {
                final v = _vinculos[index];
                final preco = v['preco'] ?? 0.0;
                final total = _calcularValorTotal(
                  v['hora_inicio'],
                  v['hora_fim'],
                  preco,
                );
                return ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(v['cliente'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Serviço: ${v['servico']}'),
                      Text('Descrição: ${v['descricao']}'),
                      Text(
                        'Data: ${v['data']} | Início: ${v['hora_inicio']} | Fim: ${v['hora_fim']}',
                      ),
                      Text('Valor total: R\$ ${total.toStringAsFixed(2)}'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _dataController.dispose();
    _horaInicioController.dispose();
    _horaFimController.dispose();
    super.dispose();
  }
}
