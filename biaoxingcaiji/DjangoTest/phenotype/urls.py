"""
表型采集系统 URL配置
包含 REST API 路由
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views
from .views import simple_register 

app_name = 'phenotype'

router = DefaultRouter()
router.register(r'mutants', views.MutantViewSet, basename='mutant')
router.register(r'experiments', views.ExperimentViewSet, basename='experiment')
router.register(r'fields', views.FieldViewSet, basename='field')
router.register(r'animals', views.AnimalViewSet, basename='animal')
router.register(r'traits', views.TraitDefinitionViewSet, basename='trait')
router.register(r'observations', views.ObservationViewSet, basename='observation')
router.register(r'media', views.MediaFileViewSet, basename='media')

urlpatterns = [
    path('', views.index, name='index'),
    path('api/', include(router.urls)),
    # 在这里添加认证路由
    path('api/auth/', include('rest_framework.urls')),
    path('api/auth/register/', simple_register, name='register'),
]