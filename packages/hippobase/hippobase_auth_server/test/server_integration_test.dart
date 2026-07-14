import 'server/admin_routes.dart';
import 'server/legacy_compatibility.dart';
import 'server/pglite.dart';
import 'server/recovery.dart';
import 'server/route_surface.dart';
import 'server/user_routes.dart';

void main() {
  registerRouteSurfaceTests();
  registerUserRouteTests();
  registerAdminRouteTests();
  registerLegacyCompatibilityTests();
  registerRecoveryTests();
  registerPgliteTests();
}
