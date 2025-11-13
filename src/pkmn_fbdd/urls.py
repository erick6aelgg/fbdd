from django.urls import path
from . import views
from .views import persona as persona_views
from .views import personal as personal_views

app_name = 'pkmn_fbdd'

urlpatterns = [
    path('', views.index, name='index'),
    path('persona/', views.lista_personas, name='lista_personas'),
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
]
