import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UnsupportedFileView extends StatelessWidget {
  const UnsupportedFileView({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.warning_2, size: 36),
          const SizedBox(height: 12),
          const Text(
            '暂不支持预览该文件类型',
            style: TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            path,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
