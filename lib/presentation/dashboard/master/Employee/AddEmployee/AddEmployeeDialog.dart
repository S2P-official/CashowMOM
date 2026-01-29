import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddEmployeeDialog extends StatefulWidget {
  final int tenantId;

  const AddEmployeeDialog({super.key, required this.tenantId});

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _selectedRole = 'grading';
  bool _obscure = true;
  bool _isLoading = false; // ✅ FIXED

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _designationCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Employee'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_firstNameCtrl, 'First Name'),
              _field(_lastNameCtrl, 'Last Name'),
              _field(_designationCtrl, 'Designation'),
              _field(_emailCtrl, 'Email', TextInputType.emailAddress),
              _field(_phoneCtrl, 'Phone', TextInputType.phone),
              _roleDropdown(),
              _passwordField(_passwordCtrl, 'Password'),
              _passwordField(
                _confirmPasswordCtrl,
                'Confirm Password',
                confirm: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, [
    TextInputType type = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v == null || v.isEmpty ? '$label required' : null,
      ),
    );
  }

  Widget _passwordField(
    TextEditingController controller,
    String label, {
    bool confirm = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: _obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return '$label required';
          if (confirm && v != _passwordCtrl.text) {
            return 'Passwords do not match';
          }
          if (!confirm && v.length < 6) {
            return 'Minimum 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _roleDropdown() {
    final roles = [
      'master',
      'calibration',
      'roasting',      
      'shelling',
      'borma',
      'peeling',
      'grading',
      'staff',
      'calibration staff',
      'roasting staff',
      'shelling staff',
      'borma staff',
      'peeling staff',
      'grading staff',
      'other staff',
      
      
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        items: roles
            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
            .toList(),
        onChanged: (v) => setState(() => _selectedRole = v!),
        decoration: const InputDecoration(
          labelText: 'Role',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'http://192.168.29.215:8080/api/employees/tenant/${widget.tenantId}',
    );

    final payload = {
      "employee_name": "${_firstNameCtrl.text} ${_lastNameCtrl.text}",
      "designation": _designationCtrl.text,
      "email": _emailCtrl.text,
      "phone": _phoneCtrl.text,
      "password": _passwordCtrl.text,
      "role": _selectedRole,
      "tenant": {"id": widget.tenantId}
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.statusCode == 409) {
        _showError('Email or phone already exists');
      } else {
        _showError('Server error (${response.statusCode})');
      }
    } catch (_) {
      _showError('Unable to connect to server');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
