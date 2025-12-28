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

## Base de datos Sigame

```env
DATABASE_NAME=dbame
USERNAME=sa
PASSWORD=BddW72021
HOST=172.16.102.123
PORT=1433
```

## Tabla para llevar la auditoria de la tabla inv_inventario en la Base de Datos sigame;

```sql
CREATE TABLE dbo.inv_inventario (
    inv_identificador    INT             NOT NULL,
    cta_co_codigo        VARCHAR(70)     NULL,
    inv_codigo           VARCHAR(20)     NULL,
    inv_nombre           VARCHAR(100)    NULL,
    inv_estado           CHAR(1)         NULL,
    inv_stock_min        NUMERIC(15,2)   NULL,
    inv_existencia       NUMERIC(15,2)   NULL,
    inv_nivel            SMALLINT        NULL,
    inv_valor_pp         NUMERIC(15,6)   NULL,
    inv_tipo             CHAR(1)         NULL,
    inv_unid_medida      VARCHAR(50)     NULL,
    inv_iva              CHAR(1)         NULL,
    inv_cod_anterior     VARCHAR(50)     NULL
);
GO

CREATE TABLE auditoria_inv_inventario (
    id_auditoria_inv_inventario INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    inv_identificador INT NOT NULL,
    inv_preview_stock NUMERIC(15,2) NOT NULL,  -- Stock antes de la acción
    inv_current_stock NUMERIC(15,2) NOT NULL,  -- Stock después de la acción
    action_type VARCHAR(10) NOT NULL,          -- 'INSERT', 'UPDATE', 'DELETE'
    user_id INT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updatedAt = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_updated_at
BEFORE UPDATE ON auditoria_inv_inventario
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();


GO

SELECT
    inv_identificador,
    COUNT(*) AS repeticiones
FROM inv_inventario
GROUP BY inv_identificador
HAVING COUNT(*) > 1;


SELECT
    cta_co_codigo,
    COUNT(*) AS repeticiones
FROM inv_inventario
WHERE cta_co_codigo IS NOT NULL
GROUP BY cta_co_codigo
HAVING COUNT(*) > 1;

SELECT
    inv_codigo,
    COUNT(*) AS repeticiones
FROM inv_inventario
WHERE inv_codigo IS NOT NULL
GROUP BY inv_codigo
HAVING COUNT(*) > 1;


```

✅ 4. Ver cuántos duplicados existen en cada campo

Solo cantidad total:

```sql
SELECT COUNT(*) AS total_duplicados_identificador
FROM (
    SELECT inv_identificador
    FROM inv_inventario
    GROUP BY inv_identificador
    HAVING COUNT(*) > 1
) t;

SELECT COUNT(*) AS total_duplicados_cta_co_codigo
FROM (
    SELECT cta_co_codigo
    FROM inv_inventario
    WHERE cta_co_codigo IS NOT NULL
    GROUP BY cta_co_codigo
    HAVING COUNT(*) > 1
) t;

SELECT COUNT(*) AS total_duplicados_inv_codigo
FROM (
    SELECT inv_codigo
    FROM inv_inventario
    WHERE inv_codigo IS NOT NULL
    GROUP BY inv_codigo
    HAVING COUNT(*) > 1
) t;
```
