import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_server_engine/hippobase_auth_server_engine.dart';

HippobaseAuthRequestMetadata hippobaseAuthRequestMetadata<TServices>(
  RequestContext<TServices> context,
) {
  final forwarded = context.req.header('x-forwarded-for');
  return HippobaseAuthRequestMetadata(
    origin: context.req.header('origin'),
    ipAddress: forwarded?.split(',').first.trim() ?? context.req.header('x-real-ip'),
    userAgent: context.req.header('user-agent'),
  );
}
