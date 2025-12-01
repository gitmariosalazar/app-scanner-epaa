lib/features/scan/
├── data/
│ └── models/
│ └── reading_info_response.dart ← TU CÓDIGO AQUÍ
│ └── mappers/
│ └── reading_info_mapper.dart ← Mapeador de respuesta a entidad
│ └── repositories/
│ └── reading_repository_impl.dart ← Implementación del repositorio
│ └── datasources/
│ └── data_source.dart ← Fuente de datos (API, local, etc.)
├── domain/
│ └── entities/
│ └── reading.dart ← Entidad pura (sin JSON)
│ └── repositories/
│ └── reading_repository.dart ← Interfaz del repositorio
│ └── usecases/
│ └── get_reading_info.dart ← Caso de uso para obtener información de lectura
│
├── presentation/
│ └── blocs/
│ └── reading_bloc.dart ← Bloc para la gestión del estado de lectura
│ └── reading_event.dart ← Eventos para el Bloc de lectura
│ └── reading_state.dart ← Estados para el Bloc de lectura
│ └── pages/
│ └── scan_page.dart ← Página de escaneo, Aqui mediante cámara se escanea el código QR y se obtiene la información de lectura, para luego mostrarla en la pantalla en otro formulario
│
└── injection.dart

Method: POST
URL: `https://dev.sigepaa-aa.com:8443/work-orders/create-work-order`
Body:

```json
{
  "description": "Fix leaking pipe in apartment 3B",
  "workOrderTypeId": 2,
  "priorityId": 1,
  "workOrderStatusId": 3,
  "connectionId": "23-42",
  "clientId": "1000202729",
  "createdUserId": 1
}
```

Headers:
Content-Type: application/json
Authorization
: Bearer YOUR_ACCESS_TOKEN

Response:

```json
{
  "status_code": 201,
  "time": "2025-11-19T16:57:15.043Z",
  "message": ["Work order created successfully"],
  "url": "/work-orders/create-work-order",
  "data": {
    "workOrderId": 2,
    "description": "Fix leaking pipe in apartment 3B",
    "creationDate": "2025-11-19T16:57:15.003Z",
    "startDate": null,
    "completionDate": null,
    "workOrderTypeId": 2,
    "priorityId": 1,
    "workOrderStatusId": 3,
    "clientId": "1000202729",
    "assignedUserId": null,
    "observations": null
  }
}
```

Tabla de WorkOrders:

| workOrderId | description                      | creationDate             | startDate | completionDate | workOrderTypeId | priorityId | workOrderStatusId | clientId   | assignedUserId | observations |
| ----------- | -------------------------------- | ------------------------ | --------- | -------------- | --------------- | ---------- | ----------------- | ---------- | -------------- | ------------ |
| 2           | Fix leaking pipe in apartment 3B | 2025-11-19T16:57:15.003Z | null      | null           | 2               | 1          | 3                 | 1000202729 | null           | null         |
