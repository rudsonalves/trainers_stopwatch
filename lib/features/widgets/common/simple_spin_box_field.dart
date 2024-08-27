// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';

import 'package:flutter/material.dart';

class SimpleSpinBoxField extends StatefulWidget {
  final int? value;
  final Widget? label;
  final TextStyle? style;
  final String? hintText;
  final TextEditingController controller;
  final int flex;
  final int minValue;
  final int maxValue;
  final int increment;
  final InputDecoration? decoration;

  const SimpleSpinBoxField({
    super.key,
    this.value,
    this.label,
    this.style,
    this.hintText,
    required this.controller,
    this.flex = 1,
    this.minValue = 0,
    this.maxValue = 10,
    this.increment = 1,
    this.decoration,
  });

  @override
  State<SimpleSpinBoxField> createState() => _SimpleSpinBoxFieldState();
}

class _SimpleSpinBoxFieldState extends State<SimpleSpinBoxField> {
  late int value;
  Timer? _incrementTimer;
  Timer? _decrementTimer;
  bool _isLongPressActive = false;

  @override
  void initState() {
    super.initState();

    value = widget.value ?? 0;
    widget.controller.text = value.toString().padLeft(2, '0');
  }

  void _longIncrement() {
    _incrementTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (value < widget.maxValue) {
          _increment();
        } else {
          _incrementTimer?.cancel();
        }
      },
    );
  }

  void _longDecrement() {
    _decrementTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (value > widget.minValue) {
          _decrement();
        } else {
          _decrementTimer?.cancel();
        }
      },
    );
  }

  void _stopIncrement() {
    _incrementTimer?.cancel();
  }

  void _stopDecrement() {
    _decrementTimer?.cancel();
  }

  void _increment() {
    if (value < widget.maxValue) {
      value += widget.increment;
      widget.controller.text = value.toString().padLeft(2, '0');
    }
  }

  void _decrement() {
    if (value > widget.minValue) {
      value -= widget.increment;
      widget.controller.text = value.toString().padLeft(2, '0');
    }
  }

  void _onLongPressIncrement() {
    _isLongPressActive = true;
    _longIncrement();
  }

  void _onLongPressDecrement() {
    _isLongPressActive = true;
    _longDecrement();
  }

  void _onLongPressEndIncrement(LongPressEndDetails details) {
    _isLongPressActive = false;
    _stopIncrement();
  }

  void _onLongPressEndDecrement(LongPressEndDetails details) {
    _isLongPressActive = false;
    _stopDecrement();
  }

  void _onTapDecrement() {
    if (!_isLongPressActive) {
      _decrement();
    }
  }

  void _onTapIncrement() {
    if (!_isLongPressActive) {
      _increment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          if (widget.label != null) widget.label!,
          SizedBox(
            width: 60,
            child: Ink(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onLongPress: _onLongPressDecrement,
                onLongPressEnd: _onLongPressEndDecrement,
                child: InkWell(
                  onTap: _onTapDecrement,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              readOnly: true,
              textAlign: TextAlign.center,
              style: widget.style,
              controller: widget.controller,
              decoration: widget.decoration,
            ),
          ),
          SizedBox(
            width: 60,
            child: Ink(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onLongPress: _onLongPressIncrement,
                onLongPressEnd: _onLongPressEndIncrement,
                child: InkWell(
                  onTap: _onTapIncrement,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
