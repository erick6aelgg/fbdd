from django.urls import path
from . import views
from .views import persona as persona_views

app_name = 'pkmn_fbdd'

urlpatterns = [
    path('', views.index, name='index'),
    path('personas/', views.lista_personas, name='lista_personas'),
    path('api/personas/', persona_views.api_personas, name='api_personas'),
    path('api/personas/create/', persona_views.api_persona_create, name='api_persona_create'),
    path('api/personas/delete/', persona_views.api_persona_delete, name='api_persona_delete'),
    path('api/personas/update/', persona_views.api_persona_update, name='api_persona_update'),

]
