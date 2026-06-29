import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


Future<DateTime?> showIosDateTimePicker(
  BuildContext context, {
  DateTime? initialDateTime,
}) async {
  var temp = initialDateTime ?? DateTime.now();


  await showCupertinoModalPopup<void>(
    context: context,
    builder: (_) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        height: 350,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'cancel'.tr(),
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      'done'.tr(),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, temp);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    bodyLarge: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                    bodyMedium: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                      height: 1.1,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: temp,
                  backgroundColor: isDark
                      ? const Color(0xFF1C1C1E)
                      : Colors.white,
                  itemExtent: 45,
                  onDateTimeChanged: (v) => temp = v,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  return null; // Should not reach here normally if handled by Navigator.pop
}
