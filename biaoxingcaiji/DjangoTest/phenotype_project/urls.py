"""
URL configuration for phenotype_project
包含 Django Admin 和 REST API
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('phenotype.urls')),
    path('api/auth/', include('rest_framework.urls')),   # DRF 登录/登出
]

# 开发环境下提供媒体文件服务
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)