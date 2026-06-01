import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscureText = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      onChanged: (val) {
        // Jika sedang error dan user mengetik, hilangkan status error warna merah
        if (_hasError) {
          setState(() => _hasError = false);
        }
      },
      validator: (value) {
        if (widget.validator != null) {
          final res = widget.validator!(value);
          // Update status error berdasarkan hasil validator
          setState(() => _hasError = res != null);
          return res;
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: _hasError ? const Color(0xffFA4D5E) : const Color(0xFF5D6A85),
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        filled: true,
        fillColor: _hasError ? const Color(0xFFFFD7DD) : const Color(0xFFF5F5F5),
        
        errorStyle: const TextStyle(
          color: Color(0xffFA4D5E),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),

        // Suffix Icon untuk Password Toggle
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: _hasError ? const Color(0xffFA4D5E) : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
            
        // Prefix Icon (Jika ada)
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,

        // Border Styling (Desain Rounded Kapsul)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xFF1A6CFF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xffFA4D5E), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xffFA4D5E), width: 1.5),
        ),
      ),
    );
  }
}