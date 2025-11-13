from sqlite3 import IntegrityError
from django.db import transaction, IntegrityError
from ..models import Personal, Persona
import datetime


def list_personal():
    return Personal.objects.all()


def get_personal(id_persona):
    # The Personal model uses a OneToOneField named `persona` whose
    # underlying DB column is `id_persona`. Use persona_id (or pk) to look up.
    return Personal.objects.filter(persona_id=id_persona).first()


@transaction.atomic
def create_personal(data):
    """Create a Personal row linked to an existing Persona.

    Raises ValueError with a user-friendly message when the referenced Persona
    does not exist or when a constraint is violated (e.g. already exists).
    """
    # Preventive check
    if not Persona.objects.filter(id_persona=data.get('id_persona')).exists():
        raise ValueError(f"No existe Persona con id {data.get('id_persona')}")

    try:
        # Create using the FK field name (persona_id) since the OneToOneField
        # is the primary key and maps to the DB column `id_persona`.
        personal = Personal.objects.create(
            persona_id=data.get('id_persona'),
            esparticipante=bool(data.get('esparticipante')),
            esorganizador=bool(data.get('esorganizador')),
        )
    except IntegrityError as exc:
        raise ValueError("No se pudo crear Personal: la Persona referenciada no existe o ya hay un Personal enlazado") from exc

    return personal


@transaction.atomic
def update_personal(id_persona, updates):
    # Lookup by the FK/PK value
    personal = Personal.objects.get(persona_id=id_persona)
    for k, v in updates.items():
        if k == 'fecha_de_nacimiento' and isinstance(v, str):
            v = datetime.date.fromisoformat(v)
        if hasattr(personal, k):
            setattr(personal, k, v)
    personal.save()
    return personal


@transaction.atomic
def delete_personal(id_persona):
    personal = Personal.objects.get(persona_id=id_persona)
    personal.delete()
    return True
