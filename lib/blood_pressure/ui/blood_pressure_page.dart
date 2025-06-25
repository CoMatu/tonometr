import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class BloodPressurePage extends StatelessWidget {
  const BloodPressurePage({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _systolicController = TextEditingController();
    final _diastolicController = TextEditingController();
    final _pulseController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Давление')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _systolicController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Систолическое давление',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите систолическое давление';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diastolicController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Диастолическое давление',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите диастолическое давление';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pulseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Пульс'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пульс';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: обработка сохранения данных
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Данные сохранены')),
                      );
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
