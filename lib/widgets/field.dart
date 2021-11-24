// import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/toast.dart';
import 'package:flutter/services.dart';
import 'package:fil/common/utils.dart';

class Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType type;
  final Widget extra;
  final List<TextInputFormatter> inputFormatters;
  final TextInputAction inputAction;
  final bool enabled;
  final bool autofocus;
  final Widget append;
  final String placeholder;
  final FocusNode focusNode;
  final bool selectable;
  final int maxLength;
  final int maxLines;
  Field(
      {this.label = '',
      this.controller,
      this.type = TextInputType.text,
      this.extra,
      this.inputAction,
      this.enabled = true,
      this.focusNode,
      this.autofocus = false,
      this.append,
      this.placeholder = '',
      this.selectable = false,
      this.maxLength = null,
      this.maxLines = null,
      this.inputFormatters = const []});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                  visible: label != '',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        label,
                        size: 14,
                        weight: FontWeight.w500,
                      ),
                      append ?? SizedBox()
                    ],
                  )),
              SizedBox(
                height: label != '' ? 13 : 0,
              ),
              Container(
                // height: 45,
                constraints: BoxConstraints(minHeight: 45),
                padding: EdgeInsets.fromLTRB(15, 4, 0, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: TextField(
                      autofocus: autofocus,
                      enabled: enabled,
                      controller: controller,
                      keyboardType: type ?? TextInputType.multiline,
                      maxLines: maxLines,
                      maxLength: maxLength,
                      focusNode: focusNode,
                      inputFormatters: inputFormatters,
                      textInputAction: inputAction ?? TextInputAction.done,
                      decoration: InputDecoration(
                          counterText: '',
                          hintText: placeholder,
                          hintStyle: TextStyle(color: Color(0xffcccccc), fontSize: 13),
                          border: InputBorder.none,
                      ),
                    )),
                    extra ??
                        Container(
                          padding: EdgeInsets.only(right: 15),
                        )
                  ],
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white),
              )
            ],
          )),
      onTap: () {
        if (selectable) {
          copyText(controller.text);
          showCustomToast('copySucc'.tr);
        }
      },
    );
  }
}
