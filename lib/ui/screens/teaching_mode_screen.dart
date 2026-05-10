import 'package:flutter/material.dart';
import 'package:twist_and_solve/application/solve_cube.dart'
    show TeachingBreakdown, TeachingStage, Move;
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/ui/widgets/cube_layout.dart';
import 'package:twist_and_solve/ui/widgets/move_label.dart';

/// U4 — Teaching Mode Screen.
///
/// Steps through the [TeachingBreakdown] stage by stage, showing the cube with
/// highlights, a description, and a pattern hint for each phase.
class TeachingModeScreen extends StatefulWidget {
  final Cube initial;
  final TeachingBreakdown breakdown;

  const TeachingModeScreen({
    super.key,
    required this.initial,
    required this.breakdown,
  });

  @override
  State<TeachingModeScreen> createState() => _TeachingModeScreenState();
}

class _TeachingModeScreenState extends State<TeachingModeScreen> {
  int _stageIndex = 0;
  bool _showingResult = false;

  /// Cube state at the start of each stage (length = stages.length + 1).
  late final List<Cube> _stageCubes;

  @override
  void initState() {
    super.initState();
    _stageCubes = [widget.initial];
    for (final stage in widget.breakdown.stages) {
      _stageCubes.add(stage.expectedState);
    }
  }

  List<TeachingStage> get _stages => widget.breakdown.stages;
  TeachingStage get _stage => _stages[_stageIndex];
  int get _totalStages => _stages.length;

  Cube get _displayCube =>
      _showingResult ? _stageCubes[_stageIndex + 1] : _stageCubes[_stageIndex];

  void _prevStage() {
    if (_stageIndex > 0) {
      setState(() {
        _stageIndex--;
        _showingResult = false;
      });
    }
  }

  void _nextStage() {
    if (_stageIndex < _totalStages - 1) {
      setState(() {
        _stageIndex++;
        _showingResult = false;
      });
    }
  }

  void _showMe() => setState(() => _showingResult = true);

  void _explainAgain() => setState(() => _showingResult = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teaching Mode'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: SizedBox(
                width: 56,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_stageIndex + 1}/$_totalStages',
                    key: const ValueKey('stage_counter'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stage.stageName,
                    key: const ValueKey('stage_name'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _stage.description,
                    key: const ValueKey('stage_description'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  _PatternHintCard(hint: _stage.patternHint),
                  const SizedBox(height: 16),
                  Center(
                    child: CubeLayout(
                      cube: _displayCube,
                      highlights: _stage.highlights,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StageMoveList(moves: _stage.moves),
                ],
              ),
            ),
          ),
          _TeachingControls(
            onPrev: _stageIndex > 0 ? _prevStage : null,
            onNext: _stageIndex < _totalStages - 1 ? _nextStage : null,
            onShowMe: _stage.moves.isNotEmpty && !_showingResult ? _showMe : null,
            onExplainAgain: _explainAgain,
          ),
        ],
      ),
    );
  }
}

class _PatternHintCard extends StatelessWidget {
  final String hint;
  const _PatternHintCard({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint,
                key: const ValueKey('stage_pattern_hint'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageMoveList extends StatelessWidget {
  final List<Move> moves;
  const _StageMoveList({required this.moves});

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) {
      return Text(
        'No moves needed for this stage.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final m in moves)
          Chip(
            label: Text(moveLabel(m)),
            labelStyle: const TextStyle(fontSize: 13),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

class _TeachingControls extends StatelessWidget {
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onShowMe;
  final VoidCallback onExplainAgain;

  const _TeachingControls({
    required this.onPrev,
    required this.onNext,
    required this.onShowMe,
    required this.onExplainAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  key: const ValueKey('btn_show_me'),
                  onPressed: onShowMe,
                  child: const Text('Show Me'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('btn_explain_again'),
                  onPressed: onExplainAgain,
                  child: const Text('Explain Again'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: const ValueKey('btn_prev_stage'),
                  onPressed: onPrev,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Prev Stage'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  key: const ValueKey('btn_next_stage'),
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Next Stage'),
                  iconAlignment: IconAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
