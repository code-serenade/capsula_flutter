class UploadMarkdownTaskResponse {
  const UploadMarkdownTaskResponse({required this.taskId});

  final String taskId;

  factory UploadMarkdownTaskResponse.fromJson(Map<String, dynamic> json) {
    return UploadMarkdownTaskResponse(
      taskId: json['task_id']?.toString() ?? '',
    );
  }
}

class MarkdownTaskResult {
  const MarkdownTaskResult({
    required this.sourceId,
    required this.sourceType,
    required this.sourceName,
    required this.parsedData,
    required this.createdAt,
    required this.recordsInserted,
  });

  final int sourceId;
  final String sourceType;
  final String sourceName;
  final dynamic parsedData;
  final DateTime createdAt;
  final int recordsInserted;

  factory MarkdownTaskResult.fromJson(Map<String, dynamic> json) {
    return MarkdownTaskResult(
      sourceId: (json['source_id'] as num).toInt(),
      sourceType: json['source_type']?.toString() ?? '',
      sourceName: json['source_name']?.toString() ?? '',
      parsedData: json['parsed_data'],
      createdAt: DateTime.parse(json['created_at'] as String),
      recordsInserted: (json['records_inserted'] as num?)?.toInt() ?? 0,
    );
  }
}

class MarkdownTaskStatusResponse {
  const MarkdownTaskStatusResponse({
    required this.taskId,
    required this.status,
    this.result,
    this.error,
  });

  final String taskId;
  final String status;
  final MarkdownTaskResult? result;
  final String? error;

  factory MarkdownTaskStatusResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    return MarkdownTaskStatusResponse(
      taskId: json['task_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      result: result is Map<String, dynamic>
          ? MarkdownTaskResult.fromJson(result)
          : null,
      error: json['error']?.toString(),
    );
  }
}
