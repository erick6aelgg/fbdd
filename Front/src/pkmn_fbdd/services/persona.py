"""
Servicios relacionados con el modelo `Persona`.
Incluyen operaciones CRUD y lógica de negocio asociada.
"""

from django.db import transaction
from ..models import Persona
import datetime

def list_personas():
    """
    Devuelve una lista de todas las personas registradas en la base de datos.
    """
    return Persona.objects.all()

def get_persona(id_persona):
    """
    Obtiene una persona específica por su ID.
    """
    return Persona.objects.filter(id_persona=id_persona).first()

@transaction.atomic
def create_persona(data):
    """
    Crea una nueva persona en la base de datos con los datos proporcionados.
    """
    fecha = data.get('fecha_de_nacimiento')
    if fecha and isinstance(fecha, str):
        fecha = datetime.date.fromisoformat(fecha)
    persona = Persona.objects.create(
        nombres=data.get('nombres',''),
        apellido_paterno=data.get('apellido_paterno',''),
        apellido_materno=data.get('apellido_materno',''),
        fecha_de_nacimiento=fecha or datetime.date(1970,1,1),
        espersonal=bool(data.get('espersonal', False)),
        esespectador=bool(data.get('esespectador', False)),
    )
    return persona

@transaction.atomic
def update_persona(id_persona, updates):
    """
    Actualiza los datos de una persona existente.
    """
    persona = Persona.objects.get(id_persona=id_persona)
    for k in ('nombres','apellido_paterno','apellido_materno','fecha_de_nacimiento','espersonal','esespectador'):
        if k in updates:
            val = updates[k]
            if k == 'fecha_de_nacimiento' and isinstance(val, str):
                val = datetime.date.fromisoformat(val)
            setattr(persona, k, val)
    persona.save()
    return persona

@transaction.atomic
def delete_persona(id_persona):
    """
    Elimina una persona de la base de datos por su ID.
    """
    persona = Persona.objects.get(id_persona=id_persona)
    persona.delete()
    return True
