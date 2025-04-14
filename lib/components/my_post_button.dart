import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class PostButton extends StatelessWidget {
  final void Function()? onTap;
  final bool isLoading;

  const PostButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(left: 10),
        child: Center(
          child: isLoading
              ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          )
              : Icon(
            Icons.done,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
