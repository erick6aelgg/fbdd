"""
Vistas relacionadas con el modelo `Persona`.
Incluyen vistas para manejar solicitudes HTTP y renderizar plantillas HTML.
"""

from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json
from ..services.persona import create_persona, update_persona, delete_persona, list_personas, get_persona
from ..models import Persona
@csrf_exempt
def api_persona_create(request):
    """
    Crea una nueva persona a través de una solicitud HTTP POST.
    """
    payload = json.loads(request.body.decode('utf-8'))
    persona = create_persona(payload)
    return JsonResponse({'id_persona': persona.id_persona}, status=201)


@csrf_exempt
def api_persona_update(request):
    """
    Actualiza los datos de una persona existente mediante una solicitud HTTP PUT o PATCH.

    Accepts PUT or PATCH with JSON body. Expected JSON:
      {
        "id_persona": 1,
        "nombres": "Nuevo Nombre",
        ...
      }
    """
    if request.method not in ('PUT', 'PATCH'):
        return JsonResponse({'error': 'método incorrecto'}, status=405)
    try:
        payload = json.loads(request.body.decode('utf-8'))
    except Exception:
        return JsonResponse({'error': 'json inválido'}, status=400)

    id_persona = payload.get('id_persona')
    if not id_persona:
        return JsonResponse({'error': 'falta id_persona'}, status=400)

    try:
        persona = update_persona(id_persona, payload)
    except Persona.DoesNotExist:
        return JsonResponse({'error': 'no existe persona con ese id'}, status=404)
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=400)

    result = {
        'id_persona': persona.id_persona,
        'nombres': persona.nombres,
        'apellido_paterno': persona.apellido_paterno,
        'apellido_materno': persona.apellido_materno,
        'fecha_de_nacimiento': persona.fecha_de_nacimiento.isoformat(),
        'espersonal': persona.espersonal,
        'esespectador': persona.esespectador,
    }
    return JsonResponse(result, status=200)

@csrf_exempt
def api_persona_delete(request):
    """
    Elimina una persona existente mediante una solicitud HTTP DELETE.

    Expected JSON fields: id_persona
    """
    if request.method != 'DELETE':
        return JsonResponse({'error': 'método incorrecto'}, status=405)

    id_persona = None
    if request.body:
        try:
            payload = json.loads(request.body.decode('utf-8'))
            id_persona = payload.get('id_persona')
        except Exception:
            return JsonResponse({'error': 'json inválido'}, status=400)

    try:
        delete_persona(id_persona)
    except Persona.DoesNotExist:
        return JsonResponse({'error': 'no existe persona con ese id'}, status=404)
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=400)

    return JsonResponse({'id_persona': id_persona, 'deleted': True}, status=200)

@csrf_exempt
def api_persona(request):
    """
    Devuelve una lista de todas las personas en formato JSON mediante una solicitud HTTP GET.
    """
    if request.method != 'GET':
        return JsonResponse({'error': 'método incorrecto'}, status=405)

    try:
        personas = list_personas()
        result = []
        for persona in personas:
            result.append({
                'id_persona': persona.id_persona,
                'nombres': persona.nombres,
                'apellido_paterno': persona.apellido_paterno,
                'apellido_materno': persona.apellido_materno,
                'fecha_de_nacimiento': persona.fecha_de_nacimiento.isoformat(),
                'espersonal': persona.espersonal,
                'esespectador': persona.esespectador,
            })
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=400)

    return JsonResponse({'personas': result}, status=200)


@csrf_exempt
def api_persona_detail(request, id_persona):
    """
    Maneja solicitudes HTTP para obtener, actualizar o eliminar una persona específica.
    """
    if request.method == 'GET':
        persona = get_persona(id_persona)
        if not persona:
            return JsonResponse({'error': 'no existe persona con ese id'}, status=404)

        result = {
            'id_persona': persona.id_persona,
            'nombres': persona.nombres,
            'apellido_paterno': persona.apellido_paterno,
            'apellido_materno': persona.apellido_materno,
            'fecha_de_nacimiento': persona.fecha_de_nacimiento.isoformat(),
            'espersonal': persona.espersonal,
            'esespectador': persona.esespectador,
        }
        return JsonResponse(result, status=200)

    if request.method in ('PUT', 'PATCH'):
        try:
            payload = json.loads(request.body.decode('utf-8'))
        except Exception:
            return JsonResponse({'error': 'json inválido'}, status=400)

        try:
            persona = update_persona(id_persona, payload)
        except Persona.DoesNotExist:
            return JsonResponse({'error': 'no existe persona con ese id'}, status=404)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=400)

        result = {
            'id_persona': persona.id_persona,
            'nombres': persona.nombres,
            'apellido_paterno': persona.apellido_paterno,
            'apellido_materno': persona.apellido_materno,
            'fecha_de_nacimiento': persona.fecha_de_nacimiento.isoformat(),
            'espersonal': persona.espersonal,
            'esespectador': persona.esespectador,
        }
        return JsonResponse(result, status=200)

    if request.method == 'DELETE':
        try:
            delete_persona(id_persona)
        except Persona.DoesNotExist:
            return JsonResponse({'error': 'no existe persona con ese id'}, status=404)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=400)

        return JsonResponse({'id_persona': id_persona, 'deleted': True}, status=200)

    return JsonResponse({'error': 'método incorrecto'}, status=405)

from django.shortcuts import render

def crear_persona_html(request):
    """
    Renderiza la plantilla HTML para crear una nueva persona.
    """
    return render(request, 'pkmn_fbdd/crear_persona.html')


def update_persona_html(request, id_persona):
    """
    Renderiza la plantilla HTML para actualizar una persona existente.
    """
    # pasamos el id a la plantilla para que el JS haga el GET/PUT al endpoint REST
    return render(request, 'pkmn_fbdd/update_persona.html', {'id_persona': id_persona})


def delete_persona_html(request, id_persona):
    """
    Renderiza la plantilla HTML para eliminar una persona existente.
    """
    return render(request, 'pkmn_fbdd/eliminar_persona.html', {'id_persona': id_persona})

