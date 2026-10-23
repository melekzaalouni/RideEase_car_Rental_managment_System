# RideEase — Flutter app + backend (one package)

```
backend/           your Spring Boot project, patch ALREADY applied
rideease_mobile/   the Flutter app (lib, android, ios, web, windows, macos, linux, test)
```

## 1. Start the backend
1. Start SQL Server (database `rideease`, settings in `backend/src/main/resources/application.properties`).
2. Roles table must contain ids 1 = ADMIN, 2 = CUSTOMER, 3 = EMPLOYEE.
3. `cd backend` then `./mvnw spring-boot:run` (Windows: `mvnw.cmd spring-boot:run`).
4. Check http://localhost:8080/swagger-ui/index.html opens.

Backend changes vs. your original repo (see `rideease_mobile/backend_patch/rideease_backend.patch`):
customerId returned at login, `securityService` bean, `/api/admin/statistics`,
enable/disable/roles endpoints, roles in user JSON, vehicle plate check on edit, CORS (needed for web).

## 2. Run the app
```
cd rideease_mobile
flutter pub get
flutter run                                                      # Android emulator (uses 10.0.2.2:8080)
flutter run -d windows                                           # desktop (uses localhost:8080)
flutter run -d chrome                                            # web (localhost:8080)
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8080   # real phone, same Wi-Fi
```
The backend address lives in ONE place: `lib/core/config.dart`.

Android has INTERNET permission, cleartext HTTP (dev only), label "RideEase", minSdk >= 23.
Platform folders come from the current Flutter stable templates; if your Flutter is older run `flutter upgrade`.
Logo, app icons (Android, iOS, web, macOS, Windows) and the default vehicle pictures were generated for RideEase (`assets/images/`). `.metadata` and `.idea/` are not included (optional, Flutter recreates them).

## Photos & colours (new)
- **Colours**: one place, `lib/core/theme.dart` (`AppColors`): burnt orange / amber on warm neutrals.
- **Logo**: `assets/images/logo.png`, shown on the login/register screens; also used for every app icon.
- **Vehicle photos**: each vehicle shows its uploaded photo, otherwise the default picture of its category
  (`assets/images/vehicles/{economy,compact,suv,luxury}.jpg`). In *Add / Edit vehicle* an ADMIN or EMPLOYEE can
  add or change the photo; when editing, leaving the photo alone keeps the current one, and "Use default" removes it.
- **Profile photo**: Profile tab, tap the avatar. Gallery (+ camera on phones). Stored per user, shown on the profile
  and in the home header.
- **Backend** (already applied in `backend/`, diff in `backend_patch/rideease_photos.patch`):
  `POST/DELETE/GET /api/vehicles/{id}/photo` (GET is public, POST/DELETE ADMIN+EMPLOYEE),
  `POST/DELETE/GET /api/profile/photo` (current user). Files are saved in `backend/uploads/` (`app.upload-dir`),
  only JPEG/PNG/WEBP up to 5 MB are accepted. New nullable columns `vehicle.photo_file` and `users.photo_file`
  are created automatically by `ddl-auto=update`.
- After pulling this: `flutter pub get` (adds `image_picker`), then restart the backend.
