import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomToggleButton extends StatefulWidget {
  final String option1;
  final String option2;
  final ValueChanged<String>? onChanged;
  final String? initialSelection;

  const CustomToggleButton({
    super.key,
    required this.option1,
    required this.option2,
    this.onChanged,
    this.initialSelection,
  });

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialSelection ?? widget.option1;
  }

  @override
  void didUpdateWidget(covariant CustomToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelection != null &&
        widget.initialSelection != _selectedOption) {
      _selectedOption = widget.initialSelection;
    }
  }

  void _selectOption(String option) {
    if (_selectedOption == option) return;
    setState(() {
      _selectedOption = option;
    });
    widget.onChanged?.call(option);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.azureBorder, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAzure.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildOption(widget.option1),
          SizedBox(width: 4.w),
          _buildOption(widget.option2),
        ],
      ),
    );
  }

  Widget _buildOption(String option) {
    final bool isSelected = _selectedOption == option;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectOption(option),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryAzure.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            option,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.softSlate,
            ),
          ),
        ),
      ),
    );
  }
}
