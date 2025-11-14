"""
Vistas relacionadas con el modelo `Personal`.
Incluyen vistas para manejar solicitudes HTTP y renderizar plantillas HTML.
"""

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import render
import json

from pkmn_fbdd.models import Personal, Persona
from pkmn_fbdd.services.persona import list_personas
from ..services.personal import create_personal, delete_personal, list_personal, update_personal, get_personal

@csrf_exempt
def api_personal_create(request):
    """
    Crea un nuevo registro de personal a través de una solicitud HTTP POST.
    """
    if request.method != 'POST':
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    try:
        data = json.loads(request.body.decode('utf-8') or '{}')
    except Exception:
        return JsonResponse({'error': 'JSON inválido'}, status=400)

    # aceptar 'id_persona' o 'persona'
    pid = data.get('id_persona') if data.get('id_persona') is not None else data.get('persona')
    if pid is None:
        return JsonResponse({'error': 'falta id_persona'}, status=400)

    try:
        persona = Persona.objects.get(pk=pid)
    except Persona.DoesNotExist:
        return JsonResponse({'error': 'Persona no encontrada'}, status=400)

    # evitar violar la restricción OneToOne
    # usar lookup por relación para forzar JOIN y no referenciar id_persona directamente
    if Personal.objects.filter(persona__id_persona=persona.id_persona).exists():
        return JsonResponse({'error': 'Personal ya existente para esa persona'}, status=400)

    esparticipante = bool(data.get('esparticipante', False))
    esorganizador = bool(data.get('esorganizador', False))

    personal = Personal(persona=persona, esparticipante=esparticipante, esorganizador=esorganizador)
    personal.save()

    return JsonResponse({
    'id_personal': personal.pk,
        'persona': persona.id_persona,
        'esparticipante': personal.esparticipante,
        'esorganizador': personal.esorganizador
    }, status=201)


@csrf_exempt
def api_personal_update(request):
    """
    Actualiza los datos de un registro de personal existente mediante una solicitud HTTP PUT o PATCH.
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
        personal = update_personal(id_persona, payload)
    except Personal.DoesNotExist:
        return JsonResponse({'error': 'no existe persona con ese id'}, status=404)
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=400)

    result = {
        'id_persona': personal.pk,
        'esparticipante': personal.esparticipante,
        'esorganizador': personal.esorganizador,
    }
    return JsonResponse(result, status=200)

@csrf_exempt
def api_personal_delete(request):
    """
    Elimina un registro de personal existente mediante una solicitud HTTP DELETE.
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
        delete_personal(id_persona)
    except Personal.DoesNotExist:
        return JsonResponse({'error': 'no existe personal con ese id'}, status=404)
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=400)

    return JsonResponse({'id_persona': id_persona, 'deleted': True}, status=200)

@csrf_exempt
def api_personal(request):
    """
    Devuelve una lista de todo el personal en formato JSON mediante una solicitud HTTP GET.
    """
    if request.method != 'GET':
        return JsonResponse({'error': 'método incorrecto'}, status=405)

    try:
        personal = list_personal()
        result = []
        for p in personal:
            result.append({
                'id_personal': p.pk,
                'esparticipante': p.esparticipante,
                'esorganizador': p.esorganizador,
            })
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=400)

    return JsonResponse({'personal': result}, status=200)


@csrf_exempt
def api_personal_detail(request, id_persona):
    """
    Maneja solicitudes HTTP para obtener, actualizar o eliminar un registro de personal específico.
    """
    if request.method == 'GET':
        personal = get_personal(id_persona)
        if not personal:
            return JsonResponse({'error': 'no existe personal con ese id'}, status=404)

        return JsonResponse({
            'id_personal': personal.pk,
            'persona': personal.persona.id_persona if personal.persona else None,
            'esparticipante': personal.esparticipante,
            'esorganizador': personal.esorganizador,
        }, status=200)

    if request.method in ('PUT', 'PATCH'):
        try:
            payload = json.loads(request.body.decode('utf-8'))
        except Exception:
            return JsonResponse({'error': 'json inválido'}, status=400)

        try:
            personal = update_personal(id_persona, payload)
        except Personal.DoesNotExist:
            return JsonResponse({'error': 'no existe personal con ese id'}, status=404)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=400)

        return JsonResponse({
            'id_personal': personal.pk,
            'esparticipante': personal.esparticipante,
            'esorganizador': personal.esorganizador,
        }, status=200)

    if request.method == 'DELETE':
        try:
            delete_personal(id_persona)
        except Personal.DoesNotExist:
            return JsonResponse({'error': 'no existe personal con ese id'}, status=404)
        except Exception as exc:
            return JsonResponse({'error': str(exc)}, status=400)

        return JsonResponse({'id_persona': id_persona, 'deleted': True}, status=200)

    return JsonResponse({'error': 'método incorrecto'}, status=405)


def crear_personal_html(request):
    """
    Renderiza la plantilla HTML para crear un nuevo registro de personal.
    """
    return render(request, 'pkmn_fbdd/crear_personal.html')


def update_personal_html(request, id_persona):
    """
    Renderiza la plantilla HTML para actualizar un registro de personal existente.
    """
    return render(request, 'pkmn_fbdd/update_personal.html', {'id_persona': id_persona})


def delete_personal_html(request, id_persona):
    """
    Renderiza la plantilla HTML para eliminar un registro de personal existente.
    """
    return render(request, 'pkmn_fbdd/eliminar_personal.html', {'id_persona': id_persona})

