"""Views package for pkmn_fbdd.

This package organizes views by table. Import submodules (e.g. persona) here so
`from pkmn_fbdd import views` keeps working and `views.persona` is available.
"""
from django.shortcuts import render
from django.http import HttpResponse

# import persona submodule so callers can use views.persona.*
from . import persona  # noqa: F401
from . import personal  # noqa: F401

def lista_personas(request):
    """Render a simple HTML list of personas. Delegates data retrieval to persona module."""
    personas_qs = persona.list_personas()
    return render(request, 'pkmn_fbdd/lista.html', {'personas': personas_qs})

def lista_personal(request):
    """Render a simple HTML list of personal. Delegates data retrieval to personal module."""
    personal_qs = personal.list_personal()
    return render(request, 'pkmn_fbdd/lista_personal.html', {'personal': personal_qs})


def index(request):
    return HttpResponse("Hola — la app pkmn_fbdd está funcionando.")
