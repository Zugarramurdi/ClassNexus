# Guía de Lanzamiento Multiplataforma - ClassNexus

Esta guía detalla los pasos necesarios para compilar y ejecutar el frontend de **ClassNexus** en todas las plataformas soportadas: Windows, Android, iOS, macOS, Linux y Web.

---

## 1. Requisitos Globales (Comunes)

Antes de intentar cualquier plataforma, asegúrate de tener:
- **Flutter SDK**: Instalado y configurado en tu `PATH`.
- **flutter doctor**: Ejecuta este comando en la terminal para verificar que tu entorno esté sano.
- **Backend Operativo**: Asegúrate de que el backend de Laravel esté corriendo (`php artisan serve`).

---

## 2. Lanzamiento en Windows 🖥️
*Configurado y funcional desde el primer día.*

1.  **Requisitos**: Visual Studio 2022 con la carga de trabajo "Desarrollo para escritorio con C++".
2.  **Ejecución**:
    ```bash
    flutter run -d windows
    ```
3.  **Nota**: El backend debe estar en `127.0.0.1:8000`.

---

## 3. Lanzamiento en macOS 🍏
*Configurado con permisos de red nativos (App Sandbox).*

1.  **Requisitos**: Un Mac con **Xcode** instalado y **CocoaPods** (`sudo gem install cocoapods`).
2.  **Instalación**:
    ```bash
    cd frontend/macos
    pod install
    ```
3.  **Ejecución**:
    ```bash
    flutter run -d macos
    ```
4.  **Backend**: Usa `127.0.0.1:8000`.

---

## 4. Lanzamiento en iOS 📱
*Configurado con esquemas de lanzamiento y permisos de URL.*

1.  **Requisitos**: Mac + Xcode.
2.  **Instalación**:
    ```bash
    cd frontend/ios
    pod install
    ```
3.  **Ejecución**:
    - **Simulador**: `flutter run -d [ID_SIMULADOR]`
    - **Físico**: Requiere configurar la firma (Signing & Capabilities) en Xcode abriendo `Runner.xcworkspace`.
4.  **Backend**: Usa `127.0.0.1:8000` si usas el simulador en el mismo Mac.

---

## 5. Lanzamiento en Android 🤖
*Configurado con soporte para Cleartext (HTTP) y redirección de red.*

1.  **Requisitos**: Android Studio + Android SDK + Java.
2.  **Ejecución**:
    ```bash
    flutter run -d [ID_EMULADOR_O_DISPOSITIVO]
    ```
3.  **Backend (Crítico)**: El emulador de Android mapea el host del PC a la IP **`10.0.2.2`**. El cliente de red de la app ya detecta esto automáticamente.

---

## 6. Lanzamiento en Linux 🐧
*Estructura base inicializada.*

1.  **Requisitos**: Distribución basada en Debian/Ubuntu con:
    ```bash
    sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
    ```
2.  **Ejecución**:
    ```bash
    flutter run -d linux
    ```

---

## 7. Lanzamiento en Web (Chrome) 🌐

1.  **Requisitos**: Chrome instalado.
2.  **Ejecución**:
    ```bash
    flutter run -d chrome
    ```
3.  **Importante**: Si el backend y el frontend están en dominios diferentes (puertos), asegúrate de que el backend de Laravel tenga habilitado **CORS** para el origen de Flutter.

---

## 💡 Troubleshooting Común

- **Error de Red**: Si la app en móvil/escritorio no conecta, verifica que los firewalls no bloqueen el puerto 8000.
- **CocoaPods (Mac)**: Si un pull trae nuevos plugins, siempre ejecuta `pod install` en las carpetas `macos` o `ios`.
- **JWT Fix (401)**: El backend ya incluye un margen de 60s (`leeway`) para que la hora del dispositivo no cause errores de autenticación.
