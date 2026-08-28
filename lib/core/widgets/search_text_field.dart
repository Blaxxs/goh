import 'package:flutter/cupertino.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    final body = CupertinoTextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onSubmitted != null && controller != null
          ? () => onSubmitted!(controller!.text)
          : null,
      textInputAction: textInputAction ?? TextInputAction.search,
      keyboardType: keyboardType ?? TextInputType.text,
      style: fieldStyle.copyWith(
        color: isDark ? CupertinoColors.white : CupertinoColors.black,
      ),
      strutStyle: fieldStrutStyle,
      placeholder: hintText,
      placeholderStyle: TextStyle(
        color:
            isDark ? CupertinoColors.systemGrey2 : CupertinoColors.systemGrey,
        fontFamily: 'NanumGothic',
        fontFamilyFallback: [
          'Malgun Gothic',
          'Apple SD Gothic Neo',
          'Noto Sans KR',
          'sans-serif',
        ],
      ),
      padding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12, right: 6),
        child: Icon(
          prefixIcon,
          size: 18,
          color:
              isDark ? CupertinoColors.systemGrey2 : CupertinoColors.systemGrey,
        ),
      ),
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.systemFill.resolveFrom(context)
            : CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? CupertinoColors.systemGrey4.resolveFrom(context)
              : CupertinoColors.systemGrey5.resolveFrom(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? CupertinoColors.black.withAlpha(26)
                : CupertinoColors.systemGrey.withAlpha(16),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    if (width == null) {
      return body;
    }

    return SizedBox(width: width, child: body);
  }
}
