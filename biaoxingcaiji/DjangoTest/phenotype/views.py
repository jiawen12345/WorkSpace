"""
表型采集系统 Views
包含 Django REST Framework ViewSets
"""
from django.shortcuts import render
from django.http import HttpResponse
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Mutant, Experiment, Field, Animal, TraitDefinition, Observation, MediaFile
from .serializers import (
    MutantSerializer, ExperimentSerializer, ExperimentDetailSerializer,
    FieldSerializer, FieldDetailSerializer, AnimalSerializer, AnimalDetailSerializer,
    TraitDefinitionSerializer, ObservationSerializer, MediaFileSerializer
)
from .pagination import FlexiblePagination  


def index(request):
    """首页视图"""
    return HttpResponse("""
    <h1>欢迎使用表型采集系统！</h1>
    <ul>
        <li><a href="/admin/">管理后台</a></li>
        <li><a href="/api/">REST API</a></li>
        <li><a href="/api/mutants/">种质列表</a></li>
        <li><a href="/api/experiments/">实验列表</a></li>
        <li><a href="/api/fields/">小区列表</a></li>
        <li><a href="/api/animals/">动物列表</a></li>
        <li><a href="/api/traits/">性状定义</a></li>
        <li><a href="/api/observations/">观测数据</a></li>
    </ul>
    """)

class MutantViewSet(viewsets.ModelViewSet):
    """种质/突变体 ViewSet"""
    queryset = Mutant.objects.all()
    serializer_class = MutantSerializer
    pagination_class = FlexiblePagination  
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['mutant_code']
    search_fields = ['mutant_code', 'name', 'description']
    ordering_fields = ['mutant_code', 'created_at']
    ordering = ['-created_at']

class ExperimentViewSet(viewsets.ModelViewSet):
    """实验 ViewSet"""
    queryset = Experiment.objects.all()
    serializer_class = ExperimentSerializer
    pagination_class = FlexiblePagination  
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['year', 'experiment_type', 'status', 'location']
    search_fields = ['name', 'location', 'description']
    ordering_fields = ['year', 'start_date', 'created_at']
    ordering = ['-created_at']
    
    def get_serializer_class(self):
        """根据action返回不同的serializer"""
        if self.action == 'retrieve':
            return ExperimentDetailSerializer
        return ExperimentSerializer
    
    @action(detail=True, methods=['get'])
    def fields(self, request, pk=None):
        """获取实验的所有小区"""
        experiment = self.get_object()
        fields = experiment.fields.all()
        serializer = FieldSerializer(fields, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def animals(self, request, pk=None):
        """获取实验的所有动物"""
        experiment = self.get_object()
        animals = experiment.animals.all()
        serializer = AnimalSerializer(animals, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def statistics(self, request, pk=None):
        """获取实验统计信息"""
        experiment = self.get_object()
        stats = {
            'fields_count': experiment.fields.count(),
            'animals_count': experiment.animals.count(),
            'observations_count': Observation.objects.filter(
                field_link__experiment=experiment
            ).count() + Observation.objects.filter(
                animal_link__experiment=experiment
            ).count(),
        }
        return Response(stats)

class FieldViewSet(viewsets.ModelViewSet):
    """小区 ViewSet"""
    queryset = Field.objects.select_related('experiment', 'mutant').all()
    serializer_class = FieldSerializer
    pagination_class = FlexiblePagination  
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['experiment', 'mutant', 'status']
    search_fields = ['field_code', 'mutant_code', 'description']
    ordering_fields = ['field_code', 'created_at', 'last_collected']
    ordering = ['field_code']
    
    def get_serializer_class(self):
        """根据action返回不同的serializer"""
        if self.action == 'retrieve':
            return FieldDetailSerializer
        return FieldSerializer
    
    @action(detail=True, methods=['get'])
    def observations(self, request, pk=None):
        """获取小区的所有观测数据"""
        field = self.get_object()
        observations = field.observations.all()
        serializer = ObservationSerializer(observations, many=True, context={'request': request})
        return Response(serializer.data)

class AnimalViewSet(viewsets.ModelViewSet):
    """动物个体 ViewSet"""
    queryset = Animal.objects.select_related('experiment').all()
    serializer_class = AnimalSerializer
    pagination_class = FlexiblePagination 
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['experiment', 'sex', 'status', 'building', 'pen']
    search_fields = ['ear_tag', 'sire_code', 'dam_code', 'description']
    ordering_fields = ['ear_tag', 'birth_date', 'created_at']
    ordering = ['-created_at']
    
    def get_serializer_class(self):
        """根据action返回不同的serializer"""
        if self.action == 'retrieve':
            return AnimalDetailSerializer
        return AnimalSerializer
    
    @action(detail=True, methods=['get'])
    def observations(self, request, pk=None):
        """获取动物的所有观测数据"""
        animal = self.get_object()
        observations = animal.observations.all()
        serializer = ObservationSerializer(observations, many=True, context={'request': request})
        return Response(serializer.data)

class TraitDefinitionViewSet(viewsets.ModelViewSet):
    """性状定义 ViewSet"""
    queryset = TraitDefinition.objects.all()
    serializer_class = TraitDefinitionSerializer
    pagination_class = FlexiblePagination  
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['data_type', 'code']
    search_fields = ['code', 'name', 'description']
    ordering_fields = ['code', 'created_at']
    ordering = ['code']


class ObservationViewSet(viewsets.ModelViewSet):
    """观测数据 ViewSet"""
    queryset = Observation.objects.select_related('trait', 'field_link', 'animal_link').all()
    serializer_class = ObservationSerializer
    pagination_class = FlexiblePagination 
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['trait', 'field_link', 'animal_link', 'observer']
    search_fields = ['value', 'observer', 'comment']
    ordering_fields = ['measure_date']
    ordering = ['-measure_date']
    
    @action(detail=False, methods=['get'])
    def by_field(self, request):
        """按小区查询观测数据"""
        field_id = request.query_params.get('field_id')
        if field_id:
            observations = self.queryset.filter(field_link_id=field_id)
            serializer = self.get_serializer(observations, many=True)
            return Response(serializer.data)
        return Response({'error': 'field_id parameter is required'}, status=400)
    
    @action(detail=False, methods=['get'])
    def by_animal(self, request):
        """按动物查询观测数据"""
        animal_id = request.query_params.get('animal_id')
        if animal_id:
            observations = self.queryset.filter(animal_link_id=animal_id)
            serializer = self.get_serializer(observations, many=True)
            return Response(serializer.data)
        return Response({'error': 'animal_id parameter is required'}, status=400)

class MediaFileViewSet(viewsets.ModelViewSet):
    """多媒体文件 ViewSet"""
    queryset = MediaFile.objects.select_related('field_link', 'animal_link').all()
    serializer_class = MediaFileSerializer
    pagination_class = FlexiblePagination  
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['media_type', 'field_link', 'animal_link', 'captured_by']
    search_fields = ['description', 'captured_by']
    ordering_fields = ['capture_time']
    ordering = ['-capture_time']

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
import json
import re

def validate_username_frontend(username):
    """与前端完全一致的验证规则"""
    if not username:
        return '用户名不能为空'
    
    if len(username) < 4 or len(username) > 20:
        return '用户名长度必须在4-20位之间'
    
    if not re.match(r'^[a-zA-Z0-9_]+$', username):
        return '用户名只能包含字母、数字或下划线'
    
    if username.startswith('_') or username.endswith('_'):
        return '用户名不能以下划线开头或结尾'
    
    return ''

def validate_password_frontend(password):
    """与前端完全一致的验证规则"""
    if not password:
        return '密码不能为空'
    
    if len(password) < 8 or len(password) > 20:
        return '密码长度必须在8-20位之间'
    
    if not re.search(r'[A-Za-z]', password):
        return '密码必须包含字母'
    
    if not re.search(r'[0-9]', password):
        return '密码必须包含数字'
    
    return ''

def validate_email_frontend(email):
    """与前端类似的邮箱验证"""
    if not email:
        return '电子邮箱不能为空'
    

    if not re.match(r'^[^\s@]+@[^\s@]+\.[^\s@]+$', email):
        return '请输入有效的电子邮箱'
    
    return ''

@csrf_exempt  
def simple_register(request):
    if request.method != 'POST':
        return JsonResponse({'error': '只支持POST请求'}, status=405)
    try:
        data = json.loads(request.body) if request.body else {}
        username = data.get('username', '').strip()
        email = data.get('email', '').strip()
        password = data.get('password', '')
        confirm_password = data.get('confirmPassword', '')

        username_error = validate_username_frontend(username)
        if username_error:
            return JsonResponse({
                'success': False, 
                'message': username_error,
                'field': 'username' 
            }, status=400)
  
        email_error = validate_email_frontend(email)
        if email_error:
            return JsonResponse({
                'success': False, 
                'message': email_error,
                'field': 'email'
            }, status=400)
    
        password_error = validate_password_frontend(password)
        if password_error:
            return JsonResponse({
                'success': False, 
                'message': password_error,
                'field': 'password'
            }, status=400)
      
        if confirm_password and password != confirm_password:
            return JsonResponse({
                'success': False, 
                'message': '两次输入的密码不一致',
                'field': 'confirmPassword'
            }, status=400)
    
        if User.objects.filter(username=username).exists():
            return JsonResponse({
                'success': False, 
                'message': '用户名已存在',
                'field': 'username'
            }, status=400)
        
        if email and User.objects.filter(email=email).exists():
            return JsonResponse({
                'success': False, 
                'message': '该邮箱已被注册',
                'field': 'email'
            }, status=400)
        
        try:
            validate_email(email)
        except ValidationError:
            return JsonResponse({
                'success': False, 
                'message': '电子邮箱格式无效',
                'field': 'email'
            }, status=400)
        
        try:
            user = User.objects.create_user(
                username=username,
                email=email,  
                password=password
            )
        except Exception as e:
           
            return JsonResponse({
                'success': False, 
                'message': f'创建用户失败: {str(e)}'
            }, status=500)
        
        return JsonResponse({
            'success': True,
            'message': '注册成功',
            'data': {
                'user': {
                    'id': user.id,
                    'username': user.username,
                    'email': user.email
                }
            }
        }, status=201)
        
    except json.JSONDecodeError:
        return JsonResponse({
            'success': False, 
            'message': '无效的JSON数据'
        }, status=400)
    except Exception as e:
    
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f'注册失败: {str(e)}', exc_info=True)
        
        return JsonResponse({
            'success': False, 
            'message': '系统错误，请稍后重试'
        }, status=500)