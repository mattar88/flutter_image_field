import 'package:flutter/material.dart';
import 'package:flutter/src/material/progress_indicator.dart' as pi;

class ControllerLinearProgressIndicator {
  late _LinearProgressIndicatorState? _indicatorProgressState;

  ControllerLinearProgressIndicator();
  updateProgress(double uploadProgressPercentage) {
    _indicatorProgressState!._updateProgress(uploadProgressPercentage);
  }

  void _attach(_LinearProgressIndicatorState indicatorProgressState) {
    _indicatorProgressState = indicatorProgressState;
  }

  void _detach() {
    _indicatorProgressState = null;
  }
}

class LinearProgressIndicator extends StatefulWidget {
  final double width;

  final ControllerLinearProgressIndicator? controllerLinearProgressIndicator;

  const LinearProgressIndicator(
      {required this.width, this.controllerLinearProgressIndicator, super.key});

  @override
  State<LinearProgressIndicator> createState() =>
      _LinearProgressIndicatorState();
}

class _LinearProgressIndicatorState extends State<LinearProgressIndicator> {
  double percentageProgress = 0;

  _updateProgress(double uploadProgressPercentage) {
    setState(() {
      percentageProgress = uploadProgressPercentage;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controllerLinearProgressIndicator?._attach(this);
  }

  @override
  void deactivate() {
    widget.controllerLinearProgressIndicator?._detach();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
        label: 'uploadProgressBar',
        child: SizedBox(
          width: widget.width,
          child: pi.LinearProgressIndicator(
            minHeight: 5,
            value: percentageProgress,
          ),
        ));
  }
}
