from django.urls import path
from . import views

app_name = 'pkmn_fbdd'

urlpatterns = [
    path('', views.index, name='index'),
    path('personas/', views.lista_personas, name='lista_personas'),
    path('api/personas/', views.api_personas, name='api_personas'),
    path('api/personas/create/', views.api_persona_create, name='api_persona_create'),
]
