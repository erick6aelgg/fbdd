"""
Configuración de WSGI para el proyecto `proyecto`.
Proporciona la interfaz de servidor para aplicaciones web.
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'proyecto.settings')

application = get_wsgi_application()
