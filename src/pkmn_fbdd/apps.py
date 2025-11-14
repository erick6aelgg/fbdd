"""
Configuración de la aplicación `pkmn_fbdd`.
Define el nombre de la aplicación y otras configuraciones específicas.
"""

from django.apps import AppConfig


class PkmnFbddConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'pkmn_fbdd'
