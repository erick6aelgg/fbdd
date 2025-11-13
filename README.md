# Django Pokemon 🧑‍💻

## ¿Qué es esto?

Una app en **Django** que usa **PostgreSQL**.
La base de datos ya viene con estructura y datos listos (`DDL.sql` y `DDM.sql`).

---

## Lo que necesitas

- Docker (para correr PostgreSQL en un contenedor) 🐳
- Python 3.13+
- Virtualenv (opcional, pero recomendado)
- **Instalar dependencias del proyecto**: `pip install -r requirements.txt`

---

## Levantando todo rápido (modo dev)

### 1. PostgreSQL en Docker

```bash
docker run --name postgres-container \
  -e POSTGRES_USER=usuario \
  -e POSTGRES_PASSWORD=contraseña \
  -e POSTGRES_DB=midatabase \
  -p 5432:5432 \
  -d postgres:16
```

### 2. Meter los SQL adentro del contenedor

```bash
docker cp ~/Downloads/DDL.sql postgres-container:/DDL.sql
docker cp ~/Downloads/DDM.sql postgres-container:/DDM.sql
```

### 3. Importar la base de datos

```bash
docker exec -it postgres-container psql -U usuario -d midatabase -f /DDL.sql
docker exec -it postgres-container psql -U usuario -d midatabase -f /DDM.sql
```

### 4. Configurar Django

- Crear y activar entorno virtual:

```bash
python -m venv .venv
source .venv/bin/activate
```

- Instalar dependencias:

```bash
pip install -r requirements.txt
```

- Configurar base de datos en `settings.py`:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'midatabase',
        'USER': 'usuario',
        'PASSWORD': 'contraseña',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

- Modelos que usan datos preexistentes:

```python
class Persona(models.Model):
    ...
    class Meta:
        managed = False
        db_table = 'persona'
```

---

## Levantar el servidor

```bash
python manage.py runserver
```

- Va a estar en [http://127.0.0.1:8000/](http://127.0.0.1:8000/)
- Listado de personas: `/personas/`

### Comandos útiles

- Arrancar PostgreSQL:

```bash
docker start postgres-container
```

- Entrar a la consola de PostgreSQL:

```bash
docker exec -it postgres-container psql -U usuario -d midatabase
```

---

## Endpoints de la API para `personas`

| Método | Endpoint                | Qué hace                 | Ejemplo de payload                                                                                                                                                     |
| ------ | ----------------------- | ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GET    | `/api/personas/`        | Lista todas las personas | —                                                                                                                                                                      |
| POST   | `/api/personas/create/` | Crea una persona nueva   | `json { "nombres": "Juan", "apellido_paterno": "Pérez", "apellido_materno": "Gómez", "fecha_de_nacimiento": "1990-01-01", "espersonal": false, "esespectador": true }` |
| PUT    | `/api/personas/update/` | Actualiza una persona    | `json { "id_persona": 1, "nombres": "Juan Carlos", "espersonal": true }`                                                                                               |
| DELETE | `/api/personas/delete/` | Borra persona por ID     | `json { "id_persona": 1 }`                                                                                                                                             |

## Endpoints de la API para `personal`

| Método | Endpoint                | Qué hace                          | Ejemplo de payload                                                           |
| ------ | ----------------------- | --------------------------------- | ---------------------------------------------------------------------------- |
| GET    | `/api/personal/`        | Lista todo el personal            | —                                                                            |
| POST   | `/api/personal/create/` | Crea un registro de personal      | `json { "id_persona": 600, "esparticipante": true, "esorganizador": false }` |
| PUT    | `/api/personal/update/` | Actualiza un registro de personal | `json { "id_persona": 600, "esparticipante": false, "esorganizador": true }` |
| DELETE | `/api/personal/delete/` | Borra un registro por ID          | `json { "id_persona": 600 }`                                                 |
