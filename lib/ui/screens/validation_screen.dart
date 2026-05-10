import 'package:flutter/material.dart';
import 'package:twist_and_solve/application/validate_cube.dart';

/// U2 — Validation Feedback Screen.
///
/// Displays the result of [ValidateCube.execute]: a success banner or a list
/// of validation errors.
class ValidationScreen extends StatelessWidget {
  final CubeValidationResult result;

  const ValidationScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validation Result')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: result.isValid ? const _ValidResult() : _InvalidResult(result),
      ),
    );
  }
}

class _ValidResult extends StatelessWidget {
  const _ValidResult();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 72),
        const SizedBox(height: 16),
        Text(
          'Valid cube!',
          key: const ValueKey('validation_title'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'This cube state is structurally valid and may be solved.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _InvalidResult extends StatelessWidget {
  final CubeValidationResult result;
  const _InvalidResult(this.result);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.cancel, color: Colors.red, size: 36),
          const SizedBox(width: 12),
          Text(
            'Invalid cube',
            key: const ValueKey('validation_title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ]),
        const SizedBox(height: 16),
        Text('Issues found:', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: result.errors.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      result.errors[i],
                      key: ValueKey('error_$i'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
