from django.urls import path
from . import views

app_name = 'pkmn_fbdd'

urlpatterns = [
    path('', views.index, name='index'),
    path('personas/', views.lista_personas, name='lista_personas'),
]
