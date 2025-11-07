import 'package:flutter/material.dart';

/// A form-compatible field that looks like a search trigger rather than a text input.
///
/// This widget is designed to solve the affordance mismatch problem where a
/// TextFormField with readOnly=true looks editable but opens a search view instead.
///
/// Visual Design:
/// - Uses SearchBar-like styling with prominent search icon
/// - Clearly tappable with trailing arrow/action icon
/// - Distinct from regular TextFormFields to signal different behavior
/// - Supports form validation and error states
///
/// States:
/// - Empty: Shows hint text with search icon and arrow
/// - Filled: Shows selected value with checkmark and clear button
/// - Error: Shows error message below (form validation)
/// - Disabled: Grayed out, not tappable
class SearchAnchorField extends FormField<String> {
  SearchAnchorField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.onTap,
    this.onClear,
    super.validator,
    super.initialValue,
    super.enabled = true,
    this.showClearButton = true,
  }) : super(
          builder: (FormFieldState<String> state) {
            final theme = Theme.of(state.context);
            final colorScheme = theme.colorScheme;
            final hasValue = state.value?.isNotEmpty ?? false;
            final hasError = state.hasError;

            // Determine visual state
            final backgroundColor = enabled
                ? (hasError
                    ? colorScheme.errorContainer.withOpacity(0.3)
                    : colorScheme.surfaceContainerHigh)
                : colorScheme.surfaceContainerHighest.withOpacity(0.38);

            final borderColor = hasError
                ? colorScheme.error
                : Colors.transparent;

            final leadingIcon = hasValue ? Icons.check_circle : Icons.search;
            final leadingIconColor = hasValue
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label (consistent with TextFormField)
                if (labelText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      labelText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: hasError
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // The search anchor itself
                Material(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: enabled ? () => onTap(state) : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor,
                          width: hasError ? 1.5 : 0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Leading icon (search or checkmark)
                          Icon(
                            leadingIcon,
                            size: 24,
                            color: enabled
                                ? leadingIconColor
                                : colorScheme.onSurface.withOpacity(0.38),
                          ),
                          const SizedBox(width: 12),

                          // Text content
                          Expanded(
                            child: Text(
                              hasValue ? state.value! : hintText,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: enabled
                                    ? (hasValue
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurfaceVariant)
                                    : colorScheme.onSurface.withOpacity(0.38),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Trailing action icon
                          if (enabled)
                            hasValue && showClearButton
                                ? IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 20,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    onPressed: () {
                                      state.didChange(null);
                                      onClear?.call();
                                    },
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                    tooltip: 'Clear',
                                  )
                                : Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Error message (consistent with TextFormField)
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      state.errorText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),

                // Helper text (optional, for future use)
                // This maintains visual consistency with TextFormField's helper text
              ],
            );
          },
        );

  final String labelText;
  final String hintText;
  final VoidCallback Function(FormFieldState<String> state) onTap;
  final VoidCallback? onClear;
  final bool showClearButton;
}
