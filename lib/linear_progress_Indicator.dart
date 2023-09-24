import 'package:flutter/material.dart';
import 'package:flutter/src/material/progress_indicator.dart' as PI;

class ControllerLinearProgressIndicator {
  late _LinearProgressIndicatorState? _indicatorProgressState;

  ControllerLinearProgressIndicator();
  updateProgress(double uploadProgressPercentage) {
    _indicatorProgressState!._updateProgress(uploadProgressPercentage);
  }

  void _attach(_LinearProgressIndicatorState _indicatorProgressState) {
    //assert(this._indicatorProgressState != null);
    this._indicatorProgressState = _indicatorProgressState;
  }

  void _detach() {
    _indicatorProgressState = null;
  }
}

class LinearProgressIndicator extends StatefulWidget {
  double? width = 100;

  final ControllerLinearProgressIndicator? controllerLinearProgressIndicator;

  LinearProgressIndicator(
      {this.width, this.controllerLinearProgressIndicator, super.key});

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
          child: PI.LinearProgressIndicator(
            minHeight: 5,
            value: percentageProgress,
          ),
        ));
  }
}
