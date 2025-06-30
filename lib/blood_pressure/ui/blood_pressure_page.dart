import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class BloodPressurePage extends StatelessWidget {
  const BloodPressurePage({super.key});

  static const fieldWidth = 300.0;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final pulseController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Давление')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: fieldWidth,
                child: TextFormField(
                  controller: systolicController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
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
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: fieldWidth,
                child: TextFormField(
                  controller: diastolicController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
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
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: fieldWidth,
                child: TextFormField(
                  controller: pulseController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: 'Пульс'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите пульс';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // TODO: обработка сохранения данных
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Данные сохранены',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Сохранить',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
