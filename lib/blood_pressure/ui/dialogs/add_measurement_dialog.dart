import 'package:flutter/material.dart';
import 'package:tonometr/core/initialization/data/dependencies_ext.dart';
import 'package:tonometr/core/ui_kit/show_top_snackbar.dart';
import 'package:tonometr/core/ui_kit/text_fields/app_text_field.dart';
import 'package:tonometr/database/db.dart';
import 'package:tonometr/core/services/event_bus.dart';
import 'package:tonometr/core/utils/datetime_utils.dart';

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
  DateTime _selectedDateTime = DateTime.now();

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

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
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
        createdAt: _selectedDateTime,
      );
      await repo.addMeasurement(measurement);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        EventBus().emit(DataChangedEvent('measurements'));
        showTopSnackBar(
          context: context,
          message: 'Данные сохранены',
          type: TopSnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showTopSnackBar(
          context: context,
          message: 'Ошибка сохранения: $e',
          type: TopSnackBarType.error,
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
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
              InkWell(
                onTap: _selectDateTime,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              formatDateTime(_selectedDateTime),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).hintColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _systolicController,
                      focusNode: _systolicFocus,
                      label: 'Систолическое',
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
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
                      controller: _diastolicController,
                      focusNode: _diastolicFocus,
                      label: 'Диастолическое',
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
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppTextField(
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
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                width: double.infinity,
                textAlign: TextAlign.start,
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
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMeasurement,
                        child:
                            _isSaving
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Сохранить'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
