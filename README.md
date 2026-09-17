# RideEase — Car Rental Management System

API REST Spring Boot pour la gestion d'une agence de location de véhicules : véhicules, clients, réservations, paiements, authentification JWT et rôles (ADMIN / EMPLOYEE / CUSTOMER).

## Stack technique

- **Java 17**
- **Spring Boot 3.5.5** (Web, Data JPA, Validation, Security)
- **SQL Server** (via `mssql-jdbc`) — base `rideease`
- **JWT** (`jjwt` 0.13.0) pour l'authentification stateless
- **Swagger / OpenAPI** (`springdoc-openapi` 2.8.5) pour la documentation interactive
- **H2** présent en dépendance runtime (utile pour des tests rapides sans SQL Server)
- **Maven** (wrapper `mvnw` inclus)

## Structure du projet

```
src/main/java/com/RideEase_car_Rental_managment_System/
├── config/            # Sécurité, filtre JWT, config OpenAPI, encodeur de mot de passe
├── controller/         # Endpoints REST (Auth, Admin, Customer, Vehicle, Reservation, Payment)
├── CustomExceptions/   # Exceptions métier + handler global (@ControllerAdvice)
├── DTO/                # Objets de requête/réponse
├── entity/             # Entités JPA (User, Customer, Vehicle, Reservation, Payment, Role...)
├── enumeration/        # Enums métier (statuts, rôles, catégories)
├── repository/         # Interfaces Spring Data JPA
├── security/           # Services JWT, authentification, inscription, UserDetailsService
└── service/            # Logique métier
```

## Modèle de domaine

- **User / Role** — comptes applicatifs avec rôle `ADMIN`, `EMPLOYEE` ou `CUSTOMER`
- **Customer** — profil client, lié à un `User`
- **Vehicle** — catégories `ECONOMY`, `COMPACT`, `SUV`, `LUXURY` ; statuts `AVAILABLE`, `RENTED`, `MAINTENANCE`
- **Reservation** — statuts `PENDING`, `CONFIRMED`, `CANCELLED`, `COMPLETED`
- **Payment** — méthodes `CREDIT_CARD`, `DEBIT_CARD`, `CASH` ; statuts `PENDING`, `COMPLETED`, `FAILED`

## Endpoints principaux

### Auth (`/api/auth`) — public
| Méthode | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/register` | Inscription d'un utilisateur |
| POST | `/api/auth/login` | Connexion, retourne un token JWT |

### Véhicules (`/api/vehicles`)
| Méthode | Endpoint | Accès |
|---|---|---|
| GET | `/api/vehicles` | Public |
| GET | `/api/vehicles/{id}` | Public |
| POST | `/api/vehicles` | ADMIN, EMPLOYEE |
| PUT | `/api/vehicles/{id}` | ADMIN, EMPLOYEE |
| DELETE | `/api/vehicles/{id}` | ADMIN, EMPLOYEE |

### Clients (`/api/customers`)
| Méthode | Endpoint | Accès |
|---|---|---|
| GET | `/api/customers/{id}` | Propriétaire, ADMIN, EMPLOYEE |
| GET | `/api/customers` | ADMIN, EMPLOYEE |
| PUT | `/api/customers/{id}` | Authentifié |
| DELETE | `/api/customers/{id}` | ADMIN ou propriétaire |

### Réservations (`/api/reservations`)
| Méthode | Endpoint | Accès |
|---|---|---|
| POST | `/api/reservations` | CUSTOMER, EMPLOYEE, ADMIN |
| GET | `/api/reservations/{id}` | CUSTOMER, EMPLOYEE, ADMIN |
| GET | `/api/reservations/customers/{customerId}` | Propriétaire, EMPLOYEE, ADMIN |
| PUT | `/api/reservations/{id}/cancel` | CUSTOMER, EMPLOYEE, ADMIN |
| GET | `/api/reservations` | ADMIN, EMPLOYEE |

### Paiements (`/api/payments`)
| Méthode | Endpoint | Accès |
|---|---|---|
| POST | `/api/payments` | CUSTOMER, EMPLOYEE, ADMIN |
| GET | `/api/payments/{id}` | Propriétaire, ADMIN, EMPLOYEE |
| GET | `/api/payments` | ADMIN, EMPLOYEE |

### Admin (`/api/admin`) — ADMIN, EMPLOYEE
| Méthode | Endpoint | Description |
|---|---|---|
| GET | `/api/admin/users` | Liste des utilisateurs |
| GET | `/api/admin/users/{id}` | Détail d'un utilisateur |

La sécurité par ressource (ownership) est vérifiée via `@PreAuthorize` avec des expressions SpEL (`@securityService.isOwner(...)`, `isPaymentOwner(...)`, etc.) définies dans `SecurityConfig`.

## Configuration

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
```

Un script `data.sql` insère les rôles de base (`ADMIN`, `CUSTOMER`, `EMPLOYEE`) — activer avec `spring.sql.init.mode=always` si besoin d'une initialisation automatique.

> ⚠️ Adapter l'URL, les identifiants SQL Server et le secret JWT avant tout déploiement (ne jamais garder un secret en clair dans un dépôt public).

## Prérequis

- JDK 17
- Une instance **SQL Server** accessible sur `localhost:1433` avec une base `rideease` créée et un utilisateur `rideease_user`
- Maven (ou utiliser le wrapper fourni `./mvnw`)

## Lancer le projet

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

## Documentation API (Swagger)

Une fois l'application lancée :

- Swagger UI : `http://localhost:8080/swagger-ui.html`
- OpenAPI JSON : `http://localhost:8080/v3/api-docs`

## Authentification

1. `POST /api/auth/register` pour créer un compte
2. `POST /api/auth/login` pour obtenir un token JWT
3. Ajouter le token aux requêtes protégées :

```
Authorization: Bearer <token>
```

## Tests

```bash
./mvnw test
```
