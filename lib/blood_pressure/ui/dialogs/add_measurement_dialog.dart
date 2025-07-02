import 'package:flutter/material.dart';
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/core/ui_kit/text_fields/app_text_field.dart';
import 'package:tonometr/database/db.dart';

class AddMeasurementDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const AddMeasurementDialog({super.key, required this.onSaved});

  @override
  State<AddMeasurementDialog> createState() => _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends State<AddMeasurementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();
  final _noteController = TextEditingController();
  final _systolicFocus = FocusNode();
  final _diastolicFocus = FocusNode();
  final _pulseFocus = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _systolicController.addListener(_handleSystolicInput);
    _diastolicController.addListener(_handleDiastolicInput);
    _pulseController.addListener(_handlePulseInput);
  }

  void _handleSystolicInput() {
    if (_systolicController.text.length == 3) {
      _diastolicFocus.requestFocus();
    }
  }

  void _handleDiastolicInput() {
    if (_diastolicController.text.length == 2) {
      _pulseFocus.requestFocus();
    }
  }

  void _handlePulseInput() {
    if (_pulseController.text.length == 2) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _noteController.dispose();
    _systolicFocus.dispose();
    _diastolicFocus.dispose();
    _pulseFocus.dispose();
    super.dispose();
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final systolic = int.parse(_systolicController.text);
      final diastolic = int.parse(_diastolicController.text);
      final pulse = int.parse(_pulseController.text);
      final note = _noteController.text.isEmpty ? null : _noteController.text;
      final repo = context.dependencies.bloodPressureRepository;
      final measurement = Measurement(
        id: 0, // will be ignored due to autoIncrement
        systolic: systolic,
        diastolic: diastolic,
        pulse: pulse,
        note: note,
        createdAt: DateTime.now(),
      );
      await repo.addMeasurement(measurement);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Данные сохранены')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Новое измерение',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _systolicController,
              focusNode: _systolicFocus,
              label: 'Систолическое давление',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите систолическое давление';
                }
                final systolic = int.tryParse(value);
                if (systolic == null || systolic <= 0) {
                  return 'Введите корректное значение';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _diastolicController,
              focusNode: _diastolicFocus,
              label: 'Диастолическое давление',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите диастолическое давление';
                }
                final diastolic = int.tryParse(value);
                if (diastolic == null || diastolic <= 0) {
                  return 'Введите корректное значение';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _pulseController,
              focusNode: _pulseFocus,
              label: 'Пульс',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите пульс';
                }
                final pulse = int.tryParse(value);
                if (pulse == null || pulse <= 0) {
                  return 'Введите корректное значение';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _noteController,
              label: 'Заметка (необязательно)',
              maxLines: 2,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveMeasurement,
                    child:
                        _isSaving
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Сохранить'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
