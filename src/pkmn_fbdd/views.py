from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
import datetime
from .models import Persona

def lista_personas(request):
    personas = Persona.objects.all()
    # use the app-qualified template path so Django's app template loader finds it
    return render(request, './lista.html', {'personas': personas})

def index(request):
    return HttpResponse("Hola — la app pkmn_fbdd está funcionando.")


def api_personas(request):
    """Simple JSON endpoint that returns all personas."""
    # use the actual model field names (lowercase) as defined in models.py
    qs = Persona.objects.all().values('id_persona', 'nombres', 'apellido_paterno', 'apellido_materno', 'fecha_de_nacimiento', 'espersonal', 'esespectador')
    data = []
    for row in qs:
        # convert date to ISO string
        if isinstance(row.get('fecha_de_nacimiento'), (datetime.date, datetime.datetime)):
            row['fecha_de_nacimiento'] = row['fecha_de_nacimiento'].isoformat()
        data.append(row)
    return JsonResponse({'count': len(data), 'results': data})


@csrf_exempt
def api_persona_create(request):
    """Create a Persona from JSON body. For testing only (CSRF exempt).

    Expected JSON fields: nombres, apellido_paterno, apellido_materno, fecha_de_nacimiento (YYYY-MM-DD), esPersonal (bool), esEspectador (bool)
    """
    if request.method != 'POST':
        return JsonResponse({'error': 'method not allowed'}, status=405)
    try:
        payload = json.loads(request.body.decode('utf-8'))
    except Exception:
        return JsonResponse({'error': 'invalid json'}, status=400)
    try:
        fecha = payload.get('fecha_de_nacimiento')
        if fecha:
            fecha = datetime.date.fromisoformat(fecha)
        # accept both camelCase and lowercase boolean keys for compatibility
        espersonal_val = payload.get('espersonal') if 'espersonal' in payload else payload.get('esPersonal', False)
        esespectador_val = payload.get('esespectador') if 'esespectador' in payload else payload.get('esEspectador', False)
        persona = Persona.objects.create(
            nombres=payload.get('nombres', ''),
            apellido_paterno=payload.get('apellido_paterno', ''),
            apellido_materno=payload.get('apellido_materno', ''),
            fecha_de_nacimiento=fecha or datetime.date(1970,1,1),
            espersonal=bool(espersonal_val),
            esespectador=bool(esespectador_val),
        )
    except Exception as exc:
        return JsonResponse({'error': str(exc)}, status=400)
    return JsonResponse({'id_persona': persona.id_persona}, status=201)
