import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rijig_mobile/core/guide.dart';

class FormFieldOne extends StatefulWidget {
  const FormFieldOne({
    super.key,
    this.fontSize,
    this.fontSizeField,
    this.controllers,
    this.hintText = '',
    this.enabled = true,
    required this.isRequired,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.prefix,
    this.errorText,
    this.errorTextWidget,
    this.suffixIcon,
    this.inputColor,
    this.textColor,
    this.isObsecure = false,
    this.isHasHint = true,
    this.isPrice = false,
    this.placeholder,
    this.onChangeText,
    required this.onTap,
    this.isHandOver = false,
    this.focusNode,
    this.borderColor,
    this.onEditingComplete,
    this.hintTextStyle,
    this.hintTextBoxFieldStyle,
    this.typeFormat,
    this.onChanged,
    this.scrollPadding = const EdgeInsets.all(0),
    this.onFieldSubmitted,
    this.validator,
    this.readOnly = false,
    this.controllerTextStyle,
    this.maxLength,
    this.onFocus = false,
  });

  final void Function(String)? onChanged;
  final TextEditingController? controllers;
  final double? fontSize;
  final double? fontSizeField;
  final String hintText;
  final String? placeholder;
  final bool enabled;
  final bool readOnly;
  final bool isRequired;
  final bool isObsecure;
  final bool isHasHint;
  final bool isPrice;
  final bool isHandOver;
  final int maxLines;
  final int minLines;
  final String? typeFormat;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final EdgeInsets scrollPadding;
  final Widget? prefixIcon;
  final Widget? prefix;
  final String? errorText;
  final Widget? suffixIcon;
  final Widget? errorTextWidget;
  final Color? inputColor;
  final Color? borderColor;
  final Color? textColor;
  final Function? onChangeText;
  final Function onTap;
  final Function? onEditingComplete;
  final TextStyle? hintTextStyle;
  final TextStyle? hintTextBoxFieldStyle;
  final TextStyle? controllerTextStyle;
  final Function(String)? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final bool onFocus;

  @override
  State<FormFieldOne> createState() => _FormFieldOneState();
}

class _FormFieldOneState extends State<FormFieldOne> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode =
        widget.isRequired ? (widget.focusNode ?? FocusNode()) : FocusNode();
  }

  @override
  void dispose() {
    if (widget.controllers != null) {
      widget.controllers?.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.isHasHint)
          widget.isHasHint == true &&
                  widget.isRequired == true &&
                  widget.hintText != ''
              ? Container(
                margin: const EdgeInsets.fromLTRB(0, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.dmSans(
                            fontSize: widget.fontSize ?? 14.sp,
                            color: blackNavyColor,
                          ),
                          children: [
                            TextSpan(
                              text: widget.hintText,
                              style: widget.hintTextStyle,
                            ),
                            TextSpan(
                              text: '\t*',
                              style: GoogleFonts.dmSans(color: redColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : widget.isHasHint && widget.hintText != ''
              ? Container(
                padding: PaddingCustom().paddingOnly(
                  left: 0,
                  top: 12,
                  bottom: 4,
                ),
                alignment: Alignment.centerLeft,
                child: Text(widget.hintText, style: widget.hintTextStyle),
              )
              : const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.all(0.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            readOnly: widget.readOnly,
            scrollPadding: widget.scrollPadding,
            minLines: widget.minLines,
            textInputAction: widget.textInputAction,
            focusNode: _focusNode,
            onFieldSubmitted: widget.onFieldSubmitted,
            controller: widget.controllers,
            onChanged: widget.onChanged,
            maxLength: widget.maxLength,
            onTap: () {
              widget.onTap();
            },
            onEditingComplete:
                widget.onEditingComplete != null
                    ? () {
                      widget.onEditingComplete!();
                    }
                    : null,
            enabled: widget.enabled,
            obscureText: widget.isObsecure,
            style:
                widget.controllerTextStyle ??
                GoogleFonts.dmSans(
                  fontSize: widget.fontSizeField ?? 12.sp,
                  fontWeight: regular,
                  color:
                      widget.textColor ??
                      (widget.enabled ? Colors.black : Colors.black54),
                ),
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            decoration: InputDecoration(
              isDense: true,
              fillColor: widget.inputColor ?? whiteColor,
              filled: true,
              hintText: widget.placeholder ?? 'Masukan ${widget.hintText}',
              hintStyle:
                  widget.hintTextBoxFieldStyle ??
                  GoogleFonts.dmSans(
                    fontSize: widget.fontSize ?? 14.sp,
                    fontWeight: regular,
                    color:
                        widget.textColor ??
                        (widget.enabled ? Colors.black54 : Colors.black38),
                  ),
              prefixIcon: widget.prefixIcon,
              prefix: widget.prefix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: blackNavyColor, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: widget.borderColor ?? blackNavyColor,
                  width: 0.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: blackNavyColor, width: 0.5),
              ),
              focusedBorder:
                  widget.isRequired
                      ? OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor, width: 0.5),
                      )
                      : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: blackNavyColor,
                          width: 0.5,
                        ),
                      ),
              suffixIcon: widget.suffixIcon,
            ),
            validator:
                widget.validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
          ),
        ),
      ],
    );
  }
}
