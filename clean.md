## Estructura del Proyecto Aplicando Clean Architecture

```
lib/
└── features/
    └── work_orders/
        ├── data/
        │   ├── datasources/
        │   │   ├── work_order_remote_datasource.dart
        │   │   └── work_order_local_datasource.dart   ← opcional (cache / sqlite)
        │   │
        │   ├── mappers/
        │   │   ├── work_order_mapper.dart
        │   │   └── work_order_list_item_mapper.dart
        │   │
        │   ├── models/
        │   │   ├── create_work_order_request.dart
        │   │   ├── update_work_order_request.dart
        │   │   ├── assign_work_order_request.dart
        │   │   ├── work_order_response.dart
        │   │   └── work_order_list_item_response.dart
        │   │
        │   └── repositories/
        │       └── work_order_repository_impl.dart
        │
        ├── domain/
        │   ├── entities/
        │   │   ├── work_order_entity.dart
        │   │   ├── work_order_list_item_entity.dart
        │   │   └── assigned_user_entity.dart
        │   │
        │   ├── repositories/
        │   │   └── work_order_repository.dart
        │   │
        │   └── usecases/
        │       ├── create_work_order.dart
        │       ├── edit_work_order.dart
        │       ├── delete_work_order.dart
        │       ├── assign_work_order.dart
        │       ├── list_work_orders.dart
        │       └── get_work_order_details.dart
        │
        ├── presentation/
        │   ├── blocs/
        │   │   ├── create_work_order/
        │   │   │   ├── create_work_order_bloc.dart
        │   │   │   ├── create_work_order_event.dart
        │   │   │   └── create_work_order_state.dart
        │   │   │
        │   │   ├── edit_work_order/
        │   │   │   ├── edit_work_order_bloc.dart
        │   │   │   ├── edit_work_order_event.dart
        │   │   │   └── edit_work_order_state.dart
        │   │   │
        │   │   ├── delete_work_order/
        │   │   │   ├── delete_work_order_bloc.dart
        │   │   │   ├── delete_work_order_event.dart
        │   │   │   └── delete_work_order_state.dart
        │   │   │
        │   │   ├── assign_work_order/
        │   │   │   ├── assign_work_order_bloc.dart
        │   │   │   ├── assign_work_order_event.dart
        │   │   │   └── assign_work_order_state.dart
        │   │   │
        │   │   ├── list_work_orders/
        │   │   │   ├── list_work_orders_bloc.dart
        │   │   │   ├── list_work_orders_event.dart
        │   │   │   └── list_work_orders_state.dart
        │   │   │
        │   │   └── work_order_details/
        │   │       ├── work_order_details_bloc.dart
        │   │       ├── work_order_details_event.dart
        │   │       └── work_order_details_state.dart
        │   │
        │   ├── screens/
        │   │   ├── create_work_order_screen.dart
        │   │   ├── edit_work_order_screen.dart
        │   │   ├── list_work_orders_screen.dart
        │   │   ├── work_order_details_screen.dart
        │   │   └── assign_work_order_screen.dart
        │   │
        │   └── widgets/
        │       ├── work_order_form.dart
        │       ├── work_order_card_item.dart
        │       ├── assign_user_dropdown.dart
        │       └── work_order_details_view.dart
        │
        └── work_orders_module.dart  ← **punto de integración del feature**
```

# 🧱 Explicación del diseño

- ✔ 1. Feature completo en un solo directorio
  Todo lo relacionado a "Work Orders" vive aquí, totalmente aislado del resto del proyecto.
- ✔ 2. Data / Domain / Presentation separado perfectamente
  Garantiza:

  - independencia de framework
  - testabilidad
  - mantenibilidad a largo plazo
  - control total del flujo de datos

- ✔ 3. Cada flujo funcional tiene su BLoC dedicado

  - Esto es vertical slicing, usado en:
    Very Good Ventures (creadores de Flutter Favorite Packages)

Reso Coder

TDD Clean Architecture

✔ 4. Modelos separados para acciones diferentes

Ejemplo:

create_work_order_request no sirve para editar

assign_work_order_request no tiene campos para eliminar

Esto mejora claridad y reduce errores.

✔ 5. Widgets reusables pero específicos del feature

No se mezclan con widgets globales.

✔ 6. Principio SOLID + DDD aplicado

Repositorio → frontera clara

UseCase → acción única

Entity → objeto puro de dominio

Model → serializable / API

🎯 Resumen

Esta estructura está lista para un proyecto:

grande

con más de 20 developers

con microfrontends

con modularización

con testing automatizado

con CI/CD

con integración a API REST o GraphQL
