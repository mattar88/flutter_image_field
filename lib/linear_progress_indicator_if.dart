import 'package:flutter/material.dart';

class ControllerLinearProgressIndicatorIF {
  late _LinearProgressIndicatorIFState? _indicatorProgressState;

  ControllerLinearProgressIndicatorIF();
  updateProgress(double uploadProgressPercentage) {
    _indicatorProgressState!._updateProgress(uploadProgressPercentage);
  }

  void _attach(_LinearProgressIndicatorIFState indicatorProgressState) {
    _indicatorProgressState = indicatorProgressState;
  }

  void _detach() {
    _indicatorProgressState = null;
  }
}

class LinearProgressIndicatorIF extends StatefulWidget {
  final double width;

  final ControllerLinearProgressIndicatorIF? controllerLinearProgressIndicator;

  const LinearProgressIndicatorIF(
      {required this.width, this.controllerLinearProgressIndicator, super.key});

  @override
  State<LinearProgressIndicatorIF> createState() =>
      _LinearProgressIndicatorIFState();
}

class _LinearProgressIndicatorIFState extends State<LinearProgressIndicatorIF> {
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
          child: LinearProgressIndicator(
            minHeight: 5,
            value: percentageProgress,
          ),
        ));
  }
}
