from django.shortcuts import render
from django.http import HttpResponse
from .models import Persona

def lista_personas(request):
    personas = Persona.objects.all()
    # use the app-qualified template path so Django's app template loader finds it
    return render(request, './lista.html', {'personas': personas})

def index(request):
    return HttpResponse("Hola — la app pkmn_fbdd está funcionando.")
