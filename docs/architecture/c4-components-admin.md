# Arquitectura del Módulo Administrativo

Este diagrama describe los componentes internos del módulo de administración y su interacción con el sistema de navegación y datos.

```mermaid
C4Component
  title Módulo Administrativo — Componentes (Nivel 3)

  Container_Boundary(frontend, "Frontend (Flutter)") {
    Component(router, "AppRouter", "GoRouter", "Orquesta la navegación y el ShellRoute")
    
    Container_Boundary(admin_module, "Admin Module") {
      Component(shell, "AdminShell", "Widget", "Layout adaptativo (Sidebar/BottomNav)")
      Component(centers, "CentersScreen", "Widget", "CRUD de Centros con NexusDataTable")
      Component(users, "UsersScreen", "Widget", "CRUD de Profesores/Alumnos")
    }

    Container_Boundary(state_mgmt, "State Management") {
      Component(centers_prov, "CentersProvider", "Riverpod", "Lógica de datos de centros")
      Component(users_prov, "AdminUsersProvider", "Riverpod", "Lógica de perfiles y sync Laravel")
    }
  }

  System_Boundary(backend, "Servicios Backend") {
    System_Ext(laravel, "API Laravel", "Gestión de Auth y orquestación de usuarios")
    System_Ext(supabase, "Supabase DB", "Persistencia de datos y RLS")
  }

  Rel(router, shell, "Envuelve con")
  Rel(shell, centers, "Renderiza contenido")
  Rel(shell, users, "Renderiza contenido")
  
  Rel(centers, centers_prov, "Lee/Escribe")
  Rel(users, users_prov, "Lee/Escribe")
  
  Rel(centers_prov, supabase, "Consultas directas", "HTTPS/Postgrest")
  Rel(users_prov, laravel, "Crea usuarios (Sync)", "HTTPS/JSON")
  Rel(users_prov, supabase, "Consulta perfiles", "HTTPS/Postgrest")
```

## Para Stakeholders
**Eficiencia Operativa**: El sistema está diseñado para que la creación de un nuevo colegio o profesor se refleje instantáneamente en la base de datos sin tiempos de espera perceptibles para el administrador.
**Escalabilidad**: Esta estructura permite añadir nuevos módulos (ej. Facturación o Inventario) simplemente añadiendo rutas al `AdminShell` existente, sin afectar lo que ya funciona.
