# RideEase — Location de véhicules (Backend + Application mobile)

Système de gestion d'une agence de location de véhicules : une **API REST Spring Boot** (véhicules avec photos, clients, réservations, paiements, photo de profil, authentification JWT, rôles ADMIN / EMPLOYEE / CUSTOMER) et une **application Flutter** (Android, iOS, desktop, web) qui la consomme.

```
backend/           API Spring Boot (patchs déjà appliqués)
rideease_mobile/   application Flutter
```

## Sommaire

1. [Backend — API Spring Boot](#1-backend--api-spring-boot)
2. [Frontend — Application Flutter](#2-frontend--application-flutter)
3. [Démarrage rapide](#3-démarrage-rapide)

---

## 1. Backend — API Spring Boot

### Stack technique

- **Java 17**
- **Spring Boot 3.5.5** (Web, Data JPA, Validation, Security)
- **SQL Server** (via `mssql-jdbc`) — base `rideease`
- **JWT** (`jjwt` 0.13.0) pour l'authentification stateless
- **Swagger / OpenAPI** (`springdoc-openapi` 2.8.5) pour la documentation interactive
- **Maven** (wrapper `mvnw` inclus)
- **Upload d'images** (multipart) stockées sur disque dans `uploads/`

### Structure du projet

```
src/main/java/com/RideEase_car_Rental_managment_System/
├── config/            # Sécurité, filtre JWT, config OpenAPI, encodeur de mot de passe
├── controller/         # Endpoints REST (Auth, Admin, Customer, Vehicle, Reservation, Payment, ProfilePhoto)
├── CustomExceptions/   # Exceptions métier + handler global (@ControllerAdvice)
├── DTO/                # Objets de requête/réponse
├── entity/             # Entités JPA (User, Customer, Vehicle, Reservation, Payment, Role...)
├── enumeration/        # Enums métier (statuts, rôles, catégories)
├── repository/         # Interfaces Spring Data JPA
├── security/           # Services JWT, authentification, inscription, UserDetailsService
└── service/            # Logique métier (dont FileStorageService : stockage des images)
```

### Modèle de domaine

- **User / Role** — comptes applicatifs avec rôle `ADMIN`, `EMPLOYEE` ou `CUSTOMER` ; chaque utilisateur peut avoir une photo de profil (`photo_file`)
- **Customer** — profil client, lié à un `User`
- **Vehicle** — catégories `ECONOMY`, `COMPACT`, `SUV`, `LUXURY` ; statuts `AVAILABLE`, `RENTED`, `MAINTENANCE` ; photo optionnelle (`photo_file`) : sans photo, le client mobile affiche l'image par défaut de la catégorie
- **Reservation** — statuts `PENDING`, `CONFIRMED`, `CANCELLED`, `COMPLETED`
- **Payment** — méthodes `CREDIT_CARD`, `DEBIT_CARD`, `CASH` ; statuts `PENDING`, `COMPLETED`, `FAILED`

### Endpoints principaux

#### Auth (`/api/auth`) — public
| Méthode | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/register` | Inscription d'un utilisateur |
| POST | `/api/auth/login` | Connexion, retourne un token JWT, les rôles et le `customerId` |

#### Véhicules (`/api/vehicles`)
| Méthode | Endpoint | Accès |
|---|---|---|
| GET | `/api/vehicles` | Public |
| GET | `/api/vehicles/{id}` | Public |
| POST | `/api/vehicles` | ADMIN, EMPLOYEE |
| PUT | `/api/vehicles/{id}` | ADMIN, EMPLOYEE |
| DELETE | `/api/vehicles/{id}` | ADMIN, EMPLOYEE |
| GET | `/api/vehicles/{id}/photo` | Public — renvoie l'image (404 si aucune photo) |
| POST | `/api/vehicles/{id}/photo` | ADMIN, EMPLOYEE — `multipart/form-data`, champ `file` |
| DELETE | `/api/vehicles/{id}/photo` | ADMIN, EMPLOYEE — retour à l'image par défaut |

La réponse d'un véhicule contient `photoUrl` (chemin relatif, ex. `/api/vehicles/3/photo?v=vehicle-3-ab12.jpg`) ou `null`. Modifier un véhicule (`PUT`) ne touche pas à sa photo ; supprimer le véhicule supprime aussi le fichier.

#### Clients (`/api/customers`)
| Méthode | Endpoint | Accès |
|---|---|---|
| GET | `/api/customers/{id}` | Propriétaire, ADMIN, EMPLOYEE |
| GET | `/api/customers` | ADMIN, EMPLOYEE |
| PUT | `/api/customers/{id}` | Authentifié |
| DELETE | `/api/customers/{id}` | ADMIN ou propriétaire |

#### Photo de profil (`/api/profile/photo`) — utilisateur connecté
| Méthode | Endpoint | Description |
|---|---|---|
| GET | `/api/profile/photo` | Ma photo (404 si aucune) |
| POST | `/api/profile/photo` | Envoyer / remplacer ma photo (`multipart/form-data`, champ `file`) |
| DELETE | `/api/profile/photo` | Supprimer ma photo |

L'utilisateur est identifié par le JWT : chacun ne gère que sa propre photo (ADMIN, EMPLOYEE et CUSTOMER).

#### Réservations (`/api/reservations`)
| Méthode | Endpoint | Accès |
|---|---|---|
| POST | `/api/reservations` | CUSTOMER, EMPLOYEE, ADMIN |
| GET | `/api/reservations/{id}` | CUSTOMER, EMPLOYEE, ADMIN |
| GET | `/api/reservations/customers/{customerId}` | Propriétaire, EMPLOYEE, ADMIN |
| PUT | `/api/reservations/{id}/cancel` | CUSTOMER, EMPLOYEE, ADMIN |
| GET | `/api/reservations` | ADMIN, EMPLOYEE |

#### Paiements (`/api/payments`)
| Méthode | Endpoint | Accès |
|---|---|---|
| POST | `/api/payments` | CUSTOMER, EMPLOYEE, ADMIN |
| GET | `/api/payments/{id}` | Propriétaire, ADMIN, EMPLOYEE |
| GET | `/api/payments` | ADMIN, EMPLOYEE |

#### Admin (`/api/admin`) — ADMIN
| Méthode | Endpoint | Description |
|---|---|---|
| GET | `/api/admin/statistics` | Statistiques du tableau de bord |
| GET | `/api/admin/users` | Liste des utilisateurs |
| GET | `/api/admin/users/{id}` | Détail d'un utilisateur |
| PUT | `/api/admin/users/{id}/enable` | Activer un compte |
| PUT | `/api/admin/users/{id}/disable` | Désactiver un compte |
| PUT | `/api/admin/users/{id}/roles` | Modifier les rôles |

CORS est activé pour toutes les origines (nécessaire pour la version web de l'application Flutter) — à restreindre en production.

#### Images
- Formats acceptés : **JPEG, PNG, WEBP** (le type est vérifié sur le contenu du fichier, pas sur l'extension), 5 Mo maximum.
- Erreurs : `400` image invalide, `413` fichier trop volumineux.
- Les fichiers sont enregistrés dans le dossier `uploads/` (sous-dossiers `vehicles/` et `users/`) ; la base ne garde que le nom du fichier. Ce dossier est ignoré par Git : à sauvegarder avec la base en production.

La sécurité par ressource (ownership) est vérifiée via `@PreAuthorize` avec des expressions SpEL (`@securityService.isOwner(...)`, `isPaymentOwner(...)`, etc.) définies dans `SecurityConfig`.

### Configuration

Fichier `src/main/resources/application.properties` :

```properties
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=rideease;encrypt=true;trustServerCertificate=true
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver
spring.datasource.username=rideease_user
spring.datasource.password=rideease_user

spring.jpa.hibernate.ddl-auto=update
spring.jpa.database-platform=org.hibernate.dialect.SQLServerDialect

jwt.secret=RideEaseSuperSecretKeyForJwtAuthentication2026
jwt.expiration=86400000

spring.sql.init.mode=never

# images (photos de véhicules et de profil)
app.upload-dir=uploads
spring.servlet.multipart.max-file-size=6MB
spring.servlet.multipart.max-request-size=7MB
```

Les colonnes `vehicle.photo_file` et `users.photo_file` (nullables) sont créées automatiquement par `ddl-auto=update`.

Un script `data.sql` insère les rôles de base (`ADMIN`, `CUSTOMER`, `EMPLOYEE`) — activer avec `spring.sql.init.mode=always` si besoin d'une initialisation automatique.

> ⚠️ Adapter l'URL, les identifiants SQL Server et le secret JWT avant tout déploiement (ne jamais garder un secret en clair dans un dépôt public).

### Prérequis

- JDK 17
- Une instance **SQL Server** accessible sur `localhost:1433` avec une base `rideease` créée et un utilisateur `rideease_user`
- Maven (ou utiliser le wrapper fourni `./mvnw`)

### Lancer le projet

```bash
# Cloner / se placer dans le dossier du projet
./mvnw spring-boot:run
```

Ou en packageant :

```bash
./mvnw clean package
java -jar target/RideEase-car-rental-management-system-0.0.1-SNAPSHOT.jar
```

L'application démarre par défaut sur `http://localhost:8080`.

### Documentation API (Swagger)

Une fois l'application lancée :

- Swagger UI : `http://localhost:8080/swagger-ui.html`
- OpenAPI JSON : `http://localhost:8080/v3/api-docs`

### Authentification

1. `POST /api/auth/register` pour créer un compte
2. `POST /api/auth/login` pour obtenir un token JWT
3. Ajouter le token aux requêtes protégées :

```
Authorization: Bearer <token>
```

### Tests

```bash
./mvnw test
```

---

## 2. Frontend — Application Flutter

### Stack technique

- **Flutter** (Dart ≥ 3.5, Material 3, thème clair / sombre automatique)
- **flutter_riverpod** — gestion d'état
- **go_router** — navigation et redirection selon la connexion
- **dio** — appels HTTP, intercepteur JWT, upload multipart
- **flutter_secure_storage** + **jwt_decoder** — stockage du token et détection d'expiration
- **image_picker** — choix des photos (galerie, caméra sur téléphone)
- **google_fonts**, **intl**, **shimmer**

### Structure du projet

```
lib/
├── main.dart, app.dart
├── core/
│   ├── theme.dart          # couleurs (AppColors), thème clair/sombre — un seul endroit
│   ├── config.dart         # adresse du backend, devise
│   ├── router.dart         # routes + redirections
│   ├── network/            # client dio, gestion des erreurs API
│   ├── storage/            # token JWT
│   ├── models/             # modèles (Vehicle, Reservation, Customer...) et enums
│   ├── media/              # sélection de photo (galerie / caméra)
│   └── widgets/            # composants communs (logo, image de véhicule, avatar...)
└── features/
    ├── auth/               # connexion, inscription
    ├── home/               # barre de navigation selon le rôle
    ├── vehicles/           # liste, filtres, détail, formulaire ajout/modification
    ├── reservations/       # réservation, mes réservations
    ├── payments/           # paiement
    ├── profile/            # profil et photo de profil
    └── admin/              # tableau de bord, gestion des utilisateurs
assets/images/              # logo et images par défaut des véhicules
```

### Fonctionnalités par rôle

| Rôle | Onglets | Possibilités |
|---|---|---|
| **CUSTOMER** | Explore, My trips, Profile | Parcourir et filtrer les véhicules, réserver, payer, annuler une réservation |
| **EMPLOYEE** | Fleet, Profile | Ajouter / modifier / supprimer des véhicules et leurs photos |
| **ADMIN** | Dashboard, Fleet, Users, Profile | Statistiques, gestion de la flotte, activer / désactiver les comptes, modifier les rôles |

#### Photos
- **Photo de véhicule** : chaque véhicule affiche sa photo, sinon l'image par défaut de sa catégorie (`assets/images/vehicles/{economy,compact,suv,luxury}.jpg`). Dans *Add / Edit vehicle*, ADMIN et EMPLOYEE peuvent ajouter ou changer la photo ; en modification, ne rien changer garde la photo actuelle, et « Use default » revient à l'image par défaut.
- **Photo de profil** : onglet Profile, toucher l'avatar (galerie, et caméra sur téléphone, ou supprimer). Elle s'affiche aussi dans l'en-tête de l'écran des véhicules. Formats JPEG / PNG / WEBP, 5 Mo maximum.

#### Identité visuelle
- Palette orange brûlé / ambre sur neutres chauds, modifiable dans `lib/core/theme.dart`.
- Logo : `assets/images/logo.png` (écrans de connexion / inscription et icônes de l'application sur toutes les plateformes).

### Prérequis

- Flutter stable récent (`flutter upgrade` si les dossiers de plateforme ne passent pas)
- Le backend lancé (voir `../backend/README.md`) : SQL Server, rôles `1 = ADMIN`, `2 = CUSTOMER`, `3 = EMPLOYEE`

### Configuration

L'adresse du backend est définie à **un seul endroit** : `lib/core/config.dart`.

| Cible | Adresse par défaut |
|---|---|
| Émulateur Android | `http://10.0.2.2:8080` |
| Windows / macOS / Linux / Web | `http://localhost:8080` |
| Vrai téléphone (même Wi-Fi) | `--dart-define=API_BASE_URL=http://192.168.x.x:8080` |

Android : permission INTERNET et HTTP en clair autorisé (développement uniquement), `minSdk >= 23`.

### Lancer l'application

```bash
cd rideease_mobile
flutter pub get
flutter run                                                      # émulateur Android
flutter run -d windows                                           # desktop
flutter run -d chrome                                            # web
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8080   # vrai téléphone
```

Le backend (`./mvnw spring-boot:run` dans `../backend`) doit tourner ; vérifier `http://localhost:8080/swagger-ui/index.html`.

### Tests

```bash
flutter test
```

### Modifications du backend nécessaires à l'application

Détail dans `backend_patch/` :
- `rideease_backend.patch` : `customerId` renvoyé au login, bean `securityService`, `/api/admin/statistics`, activation / désactivation / rôles, rôles dans le JSON utilisateur, contrôle de la plaque à la modification, CORS (nécessaire pour le web).
- `rideease_photos.patch` : photos de véhicules (`/api/vehicles/{id}/photo`) et photo de profil (`/api/profile/photo`). Ces deux patchs sont **déjà appliqués** dans `backend/`.

---

## 3. Démarrage rapide

1. Démarrer SQL Server (base `rideease`, identifiants dans `backend/src/main/resources/application.properties`) avec les rôles `1 = ADMIN`, `2 = CUSTOMER`, `3 = EMPLOYEE`.
2. Lancer le backend : `cd backend && ./mvnw spring-boot:run` (Windows : `mvnw.cmd spring-boot:run`), puis vérifier `http://localhost:8080/swagger-ui/index.html`.
3. Lancer l'application : `cd rideease_mobile && flutter pub get && flutter run`.
