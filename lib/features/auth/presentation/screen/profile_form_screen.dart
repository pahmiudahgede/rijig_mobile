import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/features/auth/model/auth_model.dart';
import 'package:rijig_mobile/features/auth/presentation/viewmodel/auth_viewmodel.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeOfBirthController = TextEditingController();

  String _selectedGender = '';
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _placeOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });

      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      // ignore: use_build_context_synchronously
      context.read<AuthViewModel>().setDateOfBirth(formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi Data Diri'),
        centerTitle: true,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authViewModel.state == AuthState.profileUpdated) {
              router.go('/xpin-input?isLogin=false');
            } else if (authViewModel.state == AuthState.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authViewModel.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),

                          Text(
                            'Lengkapi Data Diri',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Silakan lengkapi data diri Anda untuk melanjutkan',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 32),

                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama lengkap harus diisi';
                              }
                              if (value.length < 2) {
                                return 'Nama terlalu pendek';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              authViewModel.setName(value);
                            },
                          ),

                          const SizedBox(height: 16),

                          DropdownButtonFormField<String>(
                            value:
                                _selectedGender.isEmpty
                                    ? null
                                    : _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Jenis Kelamin',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'laki-laki',
                                child: Text('Laki-laki'),
                              ),
                              DropdownMenuItem(
                                value: 'perempuan',
                                child: Text('Perempuan'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jenis kelamin harus dipilih';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value ?? '';
                              });
                              authViewModel.setGender(value ?? '');
                            },
                          ),

                          const SizedBox(height: 16),

                          InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Tanggal Lahir',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                _selectedDate == null
                                    ? 'Pilih tanggal lahir'
                                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                style: TextStyle(
                                  color:
                                      _selectedDate == null
                                          ? Colors.grey[600]
                                          : Colors.black,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _placeOfBirthController,
                            decoration: const InputDecoration(
                              labelText: 'Tempat Lahir',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_city),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tempat lahir harus diisi';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              authViewModel.setPlaceOfBirth(value);
                            },
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed:
                        authViewModel.isLoading ||
                                !authViewModel.isProfileValid()
                            ? null
                            : () async {
                              if (_formKey.currentState!.validate()) {
                                await authViewModel.updateProfile();
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        authViewModel.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Simpan Data',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
