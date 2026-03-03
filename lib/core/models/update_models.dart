enum UpdateTrack {
  criticalUpdate('critical-update'),
  autoUpdate('auto-update'),
  manualUpdate('manual-update');

  const UpdateTrack(this.trackId);

  final String trackId;
}

/// Types of updates
enum UpdateType {
  auto,
  optional,
  critical;

  static UpdateType fromString(String value) {
    return UpdateType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UpdateType.optional,
    );
  }
}

/// Metadata about an available update, sourced from Firebase Remote Config
class UpdateMetadata {
  final String patchVersion;
  final UpdateType type;
  final String priority;
  final String titleAr;
  final String descriptionAr;
  final List<String> changelogAr;
  final bool forceUpdate;
  final String minRequiredVersion;
  final int sizeInMB;

  const UpdateMetadata({
    required this.patchVersion,
    required this.type,
    required this.priority,
    required this.titleAr,
    required this.descriptionAr,
    required this.changelogAr,
    required this.forceUpdate,
    required this.minRequiredVersion,
    required this.sizeInMB,
  });

  factory UpdateMetadata.fromJson(Map<String, dynamic> json) {
    return UpdateMetadata(
      patchVersion: json['patch_version'] as String? ?? '',
      type: UpdateType.fromString(json['type'] as String? ?? 'optional'),
      priority: json['priority'] as String? ?? 'low',
      titleAr: json['title_ar'] as String? ?? 'تحديث جديد',
      descriptionAr: json['description_ar'] as String? ?? '',
      changelogAr:
          (json['changelog_ar'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      forceUpdate: json['force_update'] as bool? ?? false,
      minRequiredVersion: json['min_required_version'] as String? ?? '1.0.0',
      sizeInMB: json['size_in_mb'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'patch_version': patchVersion,
    'type': type.name,
    'priority': priority,
    'title_ar': titleAr,
    'description_ar': descriptionAr,
    'changelog_ar': changelogAr,
    'force_update': forceUpdate,
    'min_required_version': minRequiredVersion,
    'size_in_mb': sizeInMB,
  };
}

/// Status of an update check
class UpdateStatus {
  final bool isUpdateAvailable;
  final UpdateMetadata? metadata;
  final String? currentVersion;
  final String? availableVersion;
  final bool isCritical;

  const UpdateStatus({
    required this.isUpdateAvailable,
    this.metadata,
    this.currentVersion,
    this.availableVersion,
    this.isCritical = false,
  });
}
