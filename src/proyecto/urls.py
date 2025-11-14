"""
Configuración de los endpoints principales de `proyecto`.
Endpoints para la administración y la aplicación `pkmn_fbdd`.
"""

from django.contrib import admin
from django.urls import include, path
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("pkmn_fbdd.urls")),
]

if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
