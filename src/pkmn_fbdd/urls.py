"""
Definición de las rutas (endpoints) de la aplicación `pkmn_fbdd`.
Cada endpoint está asociado a una vista que maneja la lógica correspondiente.
"""

from django.urls import path
from . import views
from .views import persona as persona_views
from .views import personal as personal_views
from .views import persona as persona_views

app_name = 'pkmn_fbdd'

urlpatterns = [
    path('', views.index, name='index'),
    path('persona/', views.lista_personas, name='lista_personas'),
    path('personal/', views.lista_personal, name='lista_personal'),
    path('api/persona/', persona_views.api_persona, name='api_persona'),
    path('api/persona/create/', persona_views.api_persona_create, name='api_persona_create'),
    path('api/persona/delete/', persona_views.api_persona_delete, name='api_persona_delete'),
    path('api/persona/update/', persona_views.api_persona_update, name='api_persona_update'),
    path('api/persona/<int:id_persona>/', persona_views.api_persona_detail, name='api_persona_detail'),
    path('api/personal/', personal_views.api_personal, name='api_personal'),
    path('api/personal/create/', personal_views.api_personal_create, name='api_personal_create'),
    path('api/personal/update/', personal_views.api_personal_update, name='api_personal_update'),
    path('api/personal/delete/', personal_views.api_personal_delete, name='api_personal_delete'),
    path('api/personal/<int:id_persona>/', personal_views.api_personal_detail, name='api_personal_detail'),
    # HTML pages to manage Personal (formularios)
    path('personal/', views.lista_personal, name='lista_personal'),
    path('crear-personal/', personal_views.crear_personal_html, name='crear_personal_html'),
    path('actualizar-personal/<int:id_persona>/', personal_views.update_personal_html, name='update_personal_html'),
    path('eliminar-personal/<int:id_persona>/', personal_views.delete_personal_html, name='delete_personal_html'),
    path('crear-persona/', persona_views.crear_persona_html, name='crear_persona_html'),
    path('actualizar-persona/<int:id_persona>/', persona_views.update_persona_html, name='update_persona_html'),
    path('eliminar-persona/<int:id_persona>/', persona_views.delete_persona_html, name='delete_persona_html'),
]
