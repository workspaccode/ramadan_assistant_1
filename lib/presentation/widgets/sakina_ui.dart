import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';

/// Shared visual language from report/ui/new. The app name remains Tawabti.
class SakinaColors {
  static Color hero(BuildContext context) => HSLColor.fromColor(
    context.primaryColor,
  ).withLightness(context.isDark ? 0.16 : 0.20).toColor();
  static Color mint(BuildContext context) => context.ramadanTheme.background2;
  static Color gold(BuildContext context) => context.ramadanTheme.accent;
  static Color tintForeground(
    BuildContext context,
    Color preferred,
    Color tint,
  ) {
    final background = Color.alphaBlend(tint, context.ramadanTheme.cardSurface);
    final foregroundLuminance = preferred.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    final light = foregroundLuminance > backgroundLuminance
        ? foregroundLuminance
        : backgroundLuminance;
    final dark = foregroundLuminance < backgroundLuminance
        ? foregroundLuminance
        : backgroundLuminance;
    return (light + .05) / (dark + .05) >= 4.5
        ? preferred
        : context.ramadanTheme.textPrimary;
  }
}

class SakinaCard extends StatelessWidget {
  const SakinaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    // Material (not DecoratedBox) so ListTile ink and splashes stay visible.
    child: Material(
      color: color ?? context.ramadanTheme.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.ramadanTheme.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    ),
  );
}

class SakinaBadge extends StatelessWidget {
  const SakinaBadge(this.label, {super.key, this.gold = false, this.icon});
  final String label;
  final bool gold;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tint = gold
        ? SakinaColors.gold(
            context,
          ).withValues(alpha: context.isDark ? .16 : .30)
        : SakinaColors.mint(context);
    final foreground = SakinaColors.tintForeground(
      context,
      gold ? context.ramadanTheme.secondary : context.primaryColor,
      tint,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: gold
            ? SakinaColors.gold(
                context,
              ).withValues(alpha: context.isDark ? .16 : .30)
            : SakinaColors.mint(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class SakinaSectionTitle extends StatelessWidget {
  const SakinaSectionTitle(this.title, {super.key, this.icon, this.trailing});
  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (icon != null) ...[
        Icon(icon, color: context.primaryColor, size: 22),
        const SizedBox(width: 8),
      ],
      Expanded(child: Text(title, style: context.textTheme.titleLarge)),
      ?trailing,
    ],
  );
}

/// The root owns tab state; secondary routes can return to any root tab.
class AppTabNavigation {
  static final index = ValueNotifier<int>(0);
  static void select(BuildContext context, int tab) {
    index.value = tab;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class SakinaSettingsSection extends StatelessWidget {
  const SakinaSettingsSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
  });
  final Widget? header;
  final Widget? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: SakinaCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: DefaultTextStyle(
                style: context.textTheme.titleSmall!.copyWith(
                  color: context.ramadanTheme.textSecondary,
                ),
                child: header!,
              ),
            ),
          ],
          for (var index = 0; index < children.length; index++) ...[
            Material(color: Colors.transparent, child: children[index]),
            if (index < children.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: context.ramadanTheme.borderColor,
              ),
          ],
          ?footer,
        ],
      ),
    ),
  );
}

class SakinaSettingsTile extends StatelessWidget {
  const SakinaSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.additionalInfo,
    this.leading,
    this.trailing,
    this.onTap,
  });
  final Widget title;
  final Widget? subtitle;
  final Widget? additionalInfo;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: context.textTheme.bodyMedium!,
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    DefaultTextStyle(
                      style: context.textTheme.bodySmall!,
                      child: subtitle!,
                    ),
                  ],
                  if (additionalInfo != null) ...[
                    const SizedBox(height: 8),
                    DefaultTextStyle(
                      style: context.textTheme.bodySmall!,
                      child: additionalInfo!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    ),
  );
}

class AppShellScope extends InheritedWidget {
  const AppShellScope({super.key, required super.child, this.activeTab = 0});
  final int activeTab;
  static bool contains(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>() != null;
  static bool isActive(BuildContext context, int tab) {
    final shell = context.dependOnInheritedWidgetOfExactType<AppShellScope>();
    return shell == null || shell.activeTab == tab;
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) =>
      activeTab != oldWidget.activeTab;
}

class SakinaBottomBar extends StatelessWidget {
  const SakinaBottomBar({super.key, this.selectedIndex = 0, this.onSelected});
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (AppShellScope.contains(context) && onSelected == null) {
      return const SizedBox.shrink();
    }
    final labels = [
      context.loc.ui_home,
      'tab_prayers'.tr(),
      'tab_adhkar'.tr(),
      'tab_tasbih'.tr(),
    ];
    final icons = [
      Icons.home_outlined,
      Icons.access_time_rounded,
      Icons.auto_stories_outlined,
      Icons.touch_app_outlined,
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.ramadanTheme.cardSurface,
        border: Border(
          top: BorderSide(color: context.ramadanTheme.borderColor),
        ),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 80,
          backgroundColor: context.ramadanTheme.cardSurface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: SakinaColors.mint(context),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => context.textTheme.labelSmall?.copyWith(
              color: states.contains(WidgetState.selected)
                  ? context.primaryColor
                  : context.ramadanTheme.textSecondary,
              fontSize: 11,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              size: 23,
              color: states.contains(WidgetState.selected)
                  ? context.primaryColor
                  : context.ramadanTheme.textPrimary,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected:
              onSelected ?? (index) => AppTabNavigation.select(context, index),
          destinations: List.generate(
            labels.length,
            (i) =>
                NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
          ),
        ),
      ),
    );
  }
}
