import 'package:flutter/material.dart';

/// Dropdown com tema neon para o Disciplinum
class NeonDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final String? hintText;
  final Widget? icon;
  final bool isExpanded;
  final FormFieldValidator<T>? validator;
  final bool enabled;
  final Widget? prefixIcon;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double borderRadius;
  final double borderWidth;

  const NeonDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.icon,
    this.isExpanded = true,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius = 12.0,
    this.borderWidth = 1.0,
  });

  @override
  State<NeonDropdown<T>> createState() => _NeonDropdownState<T>();
}

class _NeonDropdownState<T> extends State<NeonDropdown<T>> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cores neon
    final primaryColor = widget.borderColor ?? const Color(0xFF6366F1);
    final focusedColor = widget.focusedBorderColor ?? const Color(0xFF8B5CF6);
    final fillColor = widget.fillColor ?? 
        (isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: _isFocused ? [
                BoxShadow(
                  color: focusedColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ] : null,
            ),
            child: DropdownButtonFormField<T>(
              initialValue: widget.value,
              items: widget.items,
              onChanged: widget.enabled ? widget.onChanged : null,
              validator: widget.validator,
              focusNode: _focusNode,
              isExpanded: widget.isExpanded,
              icon: widget.icon,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 16,
                ),
                prefixIcon: widget.prefixIcon,
                contentPadding: widget.contentPadding ?? 
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: widget.borderWidth,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: primaryColor.withValues(alpha: 0.3),
                    width: widget.borderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: focusedColor,
                    width: widget.borderWidth + 0.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: primaryColor.withValues(alpha: 0.1),
                    width: widget.borderWidth,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
