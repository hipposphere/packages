import 'package:hippo_cli_core/hippo_cli_core.dart';

const hippoCliArtifactRepository = 'hipposphere/native-artifacts';
const hippoCliArtifactReleaseBaseUrl =
    'https://github.com/$hippoCliArtifactRepository/releases/download';

final class HippoCliReleaseTarget {
  const HippoCliReleaseTarget({
    required this.os,
    required this.arch,
    required this.archiveExtension,
    required this.executableName,
  });

  final String os;
  final String arch;
  final String archiveExtension;
  final String executableName;

  String archiveName(String version) {
    return 'hippo-cli-$version-$os-$arch.$archiveExtension';
  }

  Uri publicUri(String version, {String baseUrl = hippoCliArtifactReleaseBaseUrl}) {
    final normalizedBaseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$normalizedBaseUrl/${hippoCliReleaseTag(version)}/${archiveName(version)}');
  }

  Map<String, String> toMap(String version, {String baseUrl = hippoCliArtifactReleaseBaseUrl}) => {
    'os': os,
    'arch': arch,
    'archive': archiveName(version),
    'url': publicUri(version, baseUrl: baseUrl).toString(),
  };
}

String hippoCliReleaseTag(String version) => 'hippo_cli-native-v$version';

const hippoCliReleaseTargets = <HippoCliReleaseTarget>[
  HippoCliReleaseTarget(
    os: 'linux',
    arch: 'x64',
    archiveExtension: 'tar.gz',
    executableName: 'hippo',
  ),
  HippoCliReleaseTarget(
    os: 'linux',
    arch: 'arm64',
    archiveExtension: 'tar.gz',
    executableName: 'hippo',
  ),
  HippoCliReleaseTarget(
    os: 'macos',
    arch: 'arm64',
    archiveExtension: 'tar.gz',
    executableName: 'hippo',
  ),
  HippoCliReleaseTarget(
    os: 'windows',
    arch: 'x64',
    archiveExtension: 'zip',
    executableName: 'hippo.exe',
  ),
];

HippoCliReleaseTarget hippoCliReleaseTarget(String os, String arch) {
  for (final target in hippoCliReleaseTargets) {
    if (target.os == os && target.arch == arch) {
      return target;
    }
  }
  throw HippoException(
    'Unsupported Hippo CLI release target.',
    expected:
        'Expected one of: ${hippoCliReleaseTargets.map((target) => '${target.os}-${target.arch}').join(', ')}.',
    exitCode: HippoExitCode.usage,
  );
}
