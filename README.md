# flutter_application

A new Flutter project.

# app-scanner-epaa`

## 1. Limpiar Proyecto

```shell
flutter clean
```

## 2. Limpiar Cache

```shell
flutter pub cache repair
```

## 3. Re-generar Iconos

```shell
dart run flutter_launcher_icons
```

## 4. Actualizar Dependencias

```shell
flutter pub get
```

## 5. Actualizar Generación de Código

```shell
pub run build_runner build --delete-conflicting-outputs
```

## Compilar App

```shell
# APK de producción (instalar directo en dispositivo)
flutter build apk --release --flavor prod

# App Bundle de producción (Google Play Store)
flutter build appbundle --release --flavor prod
```

## Crear 2do APK

```shell
flutter build apk --release --flavor prod --split-per-abi
flutter build apk --release --flavor prod
```
