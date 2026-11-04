// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unions.dart';

// **************************************************************************
// JsonSchemaBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field, library_private_types_in_public_api, hippo_analysis_plugin/prefer_dot_shorthands
/// Sealed union selected by the `type` property.
///
/// Variants:
/// - [StreamLine$Phase]
/// - [StreamLine$Keepalive]
/// - [StreamLine$Result]
sealed class _$StreamLine implements JsonEncodable {
  const _$StreamLine();

  static const schemaId = 'StreamLine';

  static const JsonSchema schema = JsonSchema.oneOf(
    <JsonSchema>[
      JsonSchema.ref('#/components/schemas/PhaseLine'),
      JsonSchema.ref('#/components/schemas/KeepaliveLine'),
      JsonSchema.ref('#/components/schemas/ResultLine'),
    ],
    id: schemaId,
    discriminator: JsonDiscriminator(
      propertyName: 'type',
      mapping: <String, String>{
        'phase': 'PhaseLine',
        'keepalive': 'KeepaliveLine',
        'result': 'ResultLine',
      },
    ),
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  /// JSON property whose value selects the variant.
  static const discriminatorProperty = 'type';

  @override
  Map<String, Object?> toJson();
  static StreamLine decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static StreamLine fromJson(Map<String, Object?> json) {
    return switch (json["type"]) {
      "phase" => StreamLine$Phase(PhaseLine.fromJson(json)),
      "keepalive" => StreamLine$Keepalive(KeepaliveLine.fromJson(json)),
      "result" => StreamLine$Result(ResultLine.fromJson(json)),
      final value => throw FormatException(
        "Unknown StreamLine \"type\" discriminator value: $value",
        json,
      ),
    };
  }
}

/// [StreamLine] variant for `type` `"phase"`.
final class StreamLine$Phase extends StreamLine {
  const StreamLine$Phase(this.value);

  final PhaseLine value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}

/// [StreamLine] variant for `type` `"keepalive"`.
final class StreamLine$Keepalive extends StreamLine {
  const StreamLine$Keepalive(this.value);

  final KeepaliveLine value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}

/// [StreamLine] variant for `type` `"result"`.
final class StreamLine$Result extends StreamLine {
  const StreamLine$Result(this.value);

  final ResultLine value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}

/// Sealed union selected by the `type` property.
///
/// Variants:
/// - [TolerantStreamLine$Phase]
/// - [TolerantStreamLine$Keepalive]
/// - [TolerantStreamLine$Unknown]
sealed class _$TolerantStreamLine implements JsonEncodable {
  const _$TolerantStreamLine();

  static const schemaId = 'TolerantStreamLine';

  static const JsonSchema schema = JsonSchema.oneOf(
    <JsonSchema>[
      JsonSchema.ref('#/components/schemas/PhaseLine'),
      JsonSchema.ref('#/components/schemas/KeepaliveLine'),
    ],
    id: schemaId,
    discriminator: JsonDiscriminator(
      propertyName: 'type',
      mapping: <String, String>{'phase': 'PhaseLine', 'keepalive': 'KeepaliveLine'},
    ),
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  /// JSON property whose value selects the variant.
  static const discriminatorProperty = 'type';

  @override
  Map<String, Object?> toJson();
  static TolerantStreamLine decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static TolerantStreamLine fromJson(Map<String, Object?> json) {
    return switch (json["type"]) {
      "phase" => TolerantStreamLine$Phase(PhaseLine.fromJson(json)),
      "keepalive" => TolerantStreamLine$Keepalive(KeepaliveLine.fromJson(json)),
      _ => TolerantStreamLine$Unknown(json),
    };
  }
}

/// [TolerantStreamLine] variant for `type` `"phase"`.
final class TolerantStreamLine$Phase extends TolerantStreamLine {
  const TolerantStreamLine$Phase(this.value);

  final PhaseLine value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}

/// [TolerantStreamLine] variant for `type` `"keepalive"`.
final class TolerantStreamLine$Keepalive extends TolerantStreamLine {
  const TolerantStreamLine$Keepalive(this.value);

  final KeepaliveLine value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}

/// [TolerantStreamLine] variant for a `type` value unknown at generation
/// time. Keeps the raw JSON object so it round-trips unchanged.
final class TolerantStreamLine$Unknown extends TolerantStreamLine {
  const TolerantStreamLine$Unknown(this.json);

  final Map<String, Object?> json;

  /// The unrecognized `type` value.
  Object? get discriminatorValue => json["type"];

  @override
  Map<String, Object?> toJson() => json;
}

/// Sealed union selected by the `configured` property.
///
/// Variants:
/// - [Role$RolePresent]
/// - [Role$RoleAbsent]
sealed class _$Role implements JsonEncodable {
  const _$Role();

  static const schemaId = 'Role';

  static const JsonSchema schema = JsonSchema.oneOf(
    <JsonSchema>[
      JsonSchema.ref('#/components/schemas/RolePresent'),
      JsonSchema.ref('#/components/schemas/RoleAbsent'),
    ],
    id: schemaId,
    discriminator: JsonDiscriminator(
      propertyName: 'configured',
      mapping: <String, String>{
        'True': '#/components/schemas/RolePresent',
        'False': '#/components/schemas/RoleAbsent',
      },
    ),
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  /// JSON property whose value selects the variant.
  static const discriminatorProperty = 'configured';

  @override
  Map<String, Object?> toJson();
  static Role decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static Role fromJson(Map<String, Object?> json) {
    return switch (json["configured"]) {
      true => Role$RolePresent(RolePresent.fromJson(json)),
      false => Role$RoleAbsent(RoleAbsent.fromJson(json)),
      final value => throw FormatException(
        "Unknown Role \"configured\" discriminator value: $value",
        json,
      ),
    };
  }
}

/// [Role] variant for `configured` `true`.
final class Role$RolePresent extends Role {
  const Role$RolePresent(this.value);

  final RolePresent value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}

/// [Role] variant for `configured` `false`.
final class Role$RoleAbsent extends Role {
  const Role$RoleAbsent(this.value);

  final RoleAbsent value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}

final class _$Envelope implements JsonEncodable {
  const _$Envelope({
    required this.line,
    required this.lines,
    required this.previous,
    required this.role,
    required this.roles,
    required this.keepalive,
    required this.note,
    this.detail,
  });

  static const schemaId = 'Envelope';

  static const JsonSchema schema = JsonSchema.object(
    id: schemaId,
    properties: <String, JsonSchema>{
      'line': JsonSchema.ref('#/components/schemas/StreamLine'),
      'lines': JsonSchema.array(items: JsonSchema.ref('#/components/schemas/StreamLine')),
      'previous': JsonSchema.anyOf(<JsonSchema>[
        JsonSchema.ref('#/components/schemas/StreamLine'),
        JsonSchema.nullType(),
      ]),
      'role': JsonSchema.oneOf(<JsonSchema>[
        JsonSchema.ref('#/components/schemas/RolePresent'),
        JsonSchema.ref('#/components/schemas/RoleAbsent'),
      ], discriminator: JsonDiscriminator(propertyName: 'configured')),
      'roles': JsonSchema.array(
        items: JsonSchema.oneOf(<JsonSchema>[
          JsonSchema.ref('#/components/schemas/RolePresent'),
          JsonSchema.ref('#/components/schemas/RoleAbsent'),
        ], discriminator: JsonDiscriminator(propertyName: 'configured')),
      ),
      'keepalive': JsonSchema.anyOf(<JsonSchema>[
        JsonSchema.ref('#/components/schemas/KeepaliveLine'),
        JsonSchema.nullType(),
      ]),
      'note': JsonSchema.anyOf(<JsonSchema>[JsonSchema.string(), JsonSchema.nullType()]),
      'detail': JsonSchema.anyOf(<JsonSchema>[
        JsonSchema.ref('#/components/schemas/PhaseLine'),
        JsonSchema.ref('#/components/schemas/KeepaliveLine'),
      ]),
    },
    required: <String>['line', 'lines', 'previous', 'role', 'roles', 'keepalive', 'note'],
  );

  static const schemaRef = JsonSchema.componentRef(schemaId);

  final StreamLine line;

  final List<StreamLine> lines;

  final StreamLine? previous;

  final EnvelopeRole role;

  final List<EnvelopeRolesItem> roles;

  final KeepaliveLine? keepalive;

  final String? note;

  final Object? detail;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      "line": line.toJson(),
      "lines": lines.map((item) => item.toJson()).toList(),
      "previous": previous?.toJson(),
      "role": role.toJson(),
      "roles": roles.map((item) => item.toJson()).toList(),
      "keepalive": keepalive?.toJson(),
      "note": note,
      "detail": detail,
    };
  }

  static Envelope decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static Envelope fromJson(Map<String, Object?> json) {
    return Envelope(
      line: StreamLine.decode(json["line"]),
      lines: (json["lines"]! as List).map((item) => StreamLine.decode(item)).toList(),
      previous: json["previous"] == null ? null : StreamLine.decode(json["previous"]),
      role: EnvelopeRole.decode(json["role"]),
      roles: (json["roles"]! as List).map((item) => EnvelopeRolesItem.decode(item)).toList(),
      keepalive: json["keepalive"] == null ? null : KeepaliveLine.decode(json["keepalive"]),
      note: json["note"] as String?,
      detail: json["detail"],
    );
  }
}

/// Sealed union generated for an inline `oneOf` selected by the `configured` property.
///
/// Variants:
/// - [EnvelopeRole$RolePresent]
/// - [EnvelopeRole$RoleAbsent]
sealed class EnvelopeRole implements JsonEncodable {
  const EnvelopeRole();

  static const JsonSchema schema = JsonSchema.oneOf(<JsonSchema>[
    JsonSchema.ref('#/components/schemas/RolePresent'),
    JsonSchema.ref('#/components/schemas/RoleAbsent'),
  ], discriminator: JsonDiscriminator(propertyName: 'configured'));

  /// JSON property whose value selects the variant.
  static const discriminatorProperty = 'configured';

  @override
  Map<String, Object?> toJson();
  static EnvelopeRole decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static EnvelopeRole fromJson(Map<String, Object?> json) {
    return switch (json["configured"]) {
      true => EnvelopeRole$RolePresent(RolePresent.fromJson(json)),
      false => EnvelopeRole$RoleAbsent(RoleAbsent.fromJson(json)),
      final value => throw FormatException(
        "Unknown EnvelopeRole \"configured\" discriminator value: $value",
        json,
      ),
    };
  }
}

/// [EnvelopeRole] variant for `configured` `true`.
final class EnvelopeRole$RolePresent extends EnvelopeRole {
  const EnvelopeRole$RolePresent(this.value);

  final RolePresent value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}

/// [EnvelopeRole] variant for `configured` `false`.
final class EnvelopeRole$RoleAbsent extends EnvelopeRole {
  const EnvelopeRole$RoleAbsent(this.value);

  final RoleAbsent value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}

/// Sealed union generated for an inline `oneOf` selected by the `configured` property.
///
/// Variants:
/// - [EnvelopeRolesItem$RolePresent]
/// - [EnvelopeRolesItem$RoleAbsent]
sealed class EnvelopeRolesItem implements JsonEncodable {
  const EnvelopeRolesItem();

  static const JsonSchema schema = JsonSchema.oneOf(<JsonSchema>[
    JsonSchema.ref('#/components/schemas/RolePresent'),
    JsonSchema.ref('#/components/schemas/RoleAbsent'),
  ], discriminator: JsonDiscriminator(propertyName: 'configured'));

  /// JSON property whose value selects the variant.
  static const discriminatorProperty = 'configured';

  @override
  Map<String, Object?> toJson();
  static EnvelopeRolesItem decode(Object? value) {
    return fromJson(value as Map<String, Object?>);
  }

  static EnvelopeRolesItem fromJson(Map<String, Object?> json) {
    return switch (json["configured"]) {
      true => EnvelopeRolesItem$RolePresent(RolePresent.fromJson(json)),
      false => EnvelopeRolesItem$RoleAbsent(RoleAbsent.fromJson(json)),
      final value => throw FormatException(
        "Unknown EnvelopeRolesItem \"configured\" discriminator value: $value",
        json,
      ),
    };
  }
}

/// [EnvelopeRolesItem] variant for `configured` `true`.
final class EnvelopeRolesItem$RolePresent extends EnvelopeRolesItem {
  const EnvelopeRolesItem$RolePresent(this.value);

  final RolePresent value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}

/// [EnvelopeRolesItem] variant for `configured` `false`.
final class EnvelopeRolesItem$RoleAbsent extends EnvelopeRolesItem {
  const EnvelopeRolesItem$RoleAbsent(this.value);

  final RoleAbsent value;

  @override
  Map<String, Object?> toJson() => value.toJson();
}
