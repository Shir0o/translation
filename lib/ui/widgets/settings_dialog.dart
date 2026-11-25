import 'package:flutter/material.dart';

import '../../models/ai_settings.dart';
import '../theme/app_palette.dart';

class SettingsDialog extends StatefulWidget {
  final AISettings initialSettings;
  final ValueChanged<AISettings> onSave;

  const SettingsDialog({
    super.key,
    required this.initialSettings,
    required this.onSave,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late AIProvider _provider;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;

  @override
  void initState() {
    super.initState();
    _provider = widget.initialSettings.provider;
    _apiKeyController = TextEditingController(
      text: widget.initialSettings.apiKey,
    );
    _modelController = TextEditingController(
      text: widget.initialSettings.model,
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _onProviderChanged(AIProvider? provider) {
    if (provider == null) return;
    setState(() {
      _provider = provider;
      _modelController.text = provider.defaultModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Dialog(
      backgroundColor: palette.surface,
      // Keeps the dialog inside 320x568 phone windows instead of being
      // clipped by the default 40px inset padding.
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          // Scrolls instead of overflowing when the platform text scale is
          // 1.6x on a 320x568 screen.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '⚙️ AI Tutor Configuration',
                        style: TextStyle(
                          color: palette.textStrong,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close settings',
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Provider
                Text(
                  'PROVIDER',
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: palette.surfaceInset,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: palette.borderStrong),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AIProvider>(
                      value: _provider,
                      dropdownColor: palette.surface,
                      isExpanded: true,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: palette.textPrimary, fontSize: 13),
                      items: AIProvider.values.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p.displayName),
                        );
                      }).toList(),
                      onChanged: _onProviderChanged,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // API Key
                Text(
                  'API KEY',
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _apiKeyController,
                  obscureText: true,
                  style: TextStyle(color: palette.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Paste your API key...',
                    hintStyle: TextStyle(color: palette.textMuted),
                    filled: true,
                    fillColor: palette.surfaceInset,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: palette.borderStrong),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: palette.borderStrong),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: palette.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stored locally on your Mac. Never sent anywhere except directly to the selected API provider.',
                  style: TextStyle(color: palette.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 16),

                // Model Name
                Text(
                  'MODEL NAME',
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _modelController,
                  style: TextStyle(color: palette.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: palette.surfaceInset,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: palette.borderStrong),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: palette.borderStrong),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: palette.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: palette.textMuted,
                      ),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        final updated = AISettings(
                          provider: _provider,
                          apiKey: _apiKeyController.text.trim(),
                          model: _modelController.text.trim(),
                        );
                        widget.onSave(updated);
                        Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.primaryStrong,
                        foregroundColor: palette.textOnAccent,
                        minimumSize: const Size(48, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Save Settings'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
