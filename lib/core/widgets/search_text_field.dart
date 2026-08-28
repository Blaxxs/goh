import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final IconData prefixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final double? width;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final bool autofocus;

  const SearchTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.prefixIcon = Icons.search_rounded,
    this.contentPadding,
    this.width,
    this.style,
    this.strutStyle,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final fieldStyle = style ??
        const TextStyle(
          fontFamily: 'NanumGothic',
          fontFamilyFallback: [
            'Malgun Gothic',
            'Apple SD Gothic Neo',
            'Noto Sans KR',
            'sans-serif',
          ],
        );

    final fieldStrutStyle = strutStyle ??
        const StrutStyle(
          fontFamily: 'NanumGothic',
          fontFamilyFallback: [
            'Malgun Gothic',
            'Apple SD Gothic Neo',
            'Noto Sans KR',
            'sans-serif',
          ],
          height: 1.25,
          forceStrutHeight: true,
        );

    final body = TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onSubmitted != null && controller != null
          ? () => onSubmitted!(controller!.text)
          : null,
      textInputAction: textInputAction ?? TextInputAction.search,
      keyboardType: keyboardType ?? TextInputType.text,
      style: fieldStyle,
      strutStyle: fieldStrutStyle,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, size: 20),
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );

    if (width == null) {
      return body;
    }

    return SizedBox(width: width, child: body);
  }
}
