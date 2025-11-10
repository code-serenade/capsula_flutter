import 'package:flutter/material.dart';

import '../../models/health_asset.dart';
import '../../models/health_data_model.dart';

typedef HealthAssetSubmit = Future<void> Function(HealthAssetDraft draft);

/// 数据导入对话框
class DataImportDialog extends StatefulWidget {
  const DataImportDialog({
    super.key,
    this.method,
    this.onSubmit,
  });

  final DataCollectionMethod? method;
  final HealthAssetSubmit? onSubmit;

  /// 显示对话框的静态方法
  static Future<void> show(
    BuildContext context, {
    DataCollectionMethod? method,
    HealthAssetSubmit? onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DataImportDialog(
        method: method,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<DataImportDialog> createState() => _DataImportDialogState();
}

class _DataImportDialogState extends State<DataImportDialog> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late DataSource _selectedSource;
  HealthDataType _selectedType = HealthDataType.other;
  DateTime _recordedAt = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.method?.source ?? DataSource.manual;
    _titleController.text = widget.method?.title ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.method != null ? '${widget.method!.title} - 数据导入' : '数据导入'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '数据名称',
                  hintText: '例如：2023年6月血压测量',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请填写数据名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTypeSelector(theme),
              const SizedBox(height: 16),
              _buildRecordedAtPicker(context),
              const SizedBox(height: 16),
              _buildSourceField(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '数据内容',
                  hintText: '输入具体的测量值、描述或备注',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: '备注说明'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: '标签 (用逗号分隔)',
                  hintText: '血压, 晚上, 手动',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('保存'),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return DropdownButtonFormField<HealthDataType>(
      value: _selectedType,
      decoration: const InputDecoration(labelText: '数据类型'),
      items: HealthDataType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedType = value);
        }
      },
    );
  }

  Widget _buildRecordedAtPicker(BuildContext context) {
    final dateLabel = '${_recordedAt.year}-${_recordedAt.month.toString().padLeft(2, '0')}-${_recordedAt.day.toString().padLeft(2, '0')}';
    final timeLabel = '${_recordedAt.hour.toString().padLeft(2, '0')}:${_recordedAt.minute.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () => _pickDate(context),
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text('日期 $dateLabel'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextButton.icon(
            onPressed: () => _pickTime(context),
            icon: const Icon(Icons.schedule, size: 16),
            label: Text('时间 $timeLabel'),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceField() {
    return DropdownButtonFormField<DataSource>(
      value: _selectedSource,
      decoration: const InputDecoration(labelText: '数据来源'),
      items: DataSource.values.map((source) {
        return DropdownMenuItem(
          value: source,
          child: Text(source.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedSource = value);
        }
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _recordedAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _recordedAt.hour,
          _recordedAt.minute,
        );
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_recordedAt),
    );
    if (picked != null) {
      setState(() {
        _recordedAt = DateTime(
          _recordedAt.year,
          _recordedAt.month,
          _recordedAt.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final draft = HealthAssetDraft(
      title: _titleController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      content: _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
      dataSource: _selectedSource,
      dataType: _selectedType,
      tags: _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
      metadata: {
        'recordedAt': _recordedAt.toIso8601String(),
        if (widget.method != null) 'method': widget.method!.id,
      },
    );

    if (widget.onSubmit == null) {
      Navigator.pop(context, draft);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.onSubmit!(draft);
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
