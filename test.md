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
