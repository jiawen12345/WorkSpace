"""
表型采集系统 Serializers
用于 Django REST Framework API
"""
from rest_framework import serializers
from .models import Mutant, Experiment, Field, Animal, TraitDefinition, Observation, MediaFile


class MutantSerializer(serializers.ModelSerializer):
    """种质/突变体序列化器"""
    class Meta:
        model = Mutant
        fields = '__all__'
        read_only_fields = ['created_at', 'updated_at']


class ExperimentSerializer(serializers.ModelSerializer):
    """实验序列化器"""
    fields_count = serializers.SerializerMethodField()
    animals_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Experiment
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_fields_count(self, obj):
        """获取小区数量"""
        return obj.fields.count()
    
    def get_animals_count(self, obj):
        """获取动物数量"""
        return obj.animals.count()


class FieldSerializer(serializers.ModelSerializer):
    """小区序列化器"""
    experiment_name = serializers.CharField(source='experiment.name', read_only=True)
    mutant_name = serializers.CharField(source='mutant.name', read_only=True)
    observations_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Field
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at', 'mutant_code']
    
    def get_observations_count(self, obj):
        """获取观测数据数量"""
        return obj.observations.count()


class AnimalSerializer(serializers.ModelSerializer):
    """动物个体序列化器"""
    experiment_name = serializers.CharField(source='experiment.name', read_only=True)
    sex_display = serializers.CharField(source='get_sex_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    observations_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Animal
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_observations_count(self, obj):
        """获取观测数据数量"""
        return obj.observations.count()


class TraitDefinitionSerializer(serializers.ModelSerializer):
    """性状定义序列化器"""
    data_type_display = serializers.CharField(source='get_data_type_display', read_only=True)
    observations_count = serializers.SerializerMethodField()
    
    class Meta:
        model = TraitDefinition
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_observations_count(self, obj):
        """获取观测数据数量"""
        return obj.observations.count()


class ObservationSerializer(serializers.ModelSerializer):
    """观测数据序列化器"""
    trait_name = serializers.CharField(source='trait.name', read_only=True)
    trait_code = serializers.CharField(source='trait.code', read_only=True)
    trait_unit = serializers.CharField(source='trait.unit', read_only=True)
    field_code = serializers.CharField(source='field_link.field_code', read_only=True)
    animal_ear_tag = serializers.CharField(source='animal_link.ear_tag', read_only=True)
    
    class Meta:
        model = Observation
        fields = '__all__'
        read_only_fields = ['id', 'measure_date']


class MediaFileSerializer(serializers.ModelSerializer):
    """多媒体文件序列化器"""
    media_type_display = serializers.CharField(source='get_media_type_display', read_only=True)
    field_code = serializers.CharField(source='field_link.field_code', read_only=True)
    animal_ear_tag = serializers.CharField(source='animal_link.ear_tag', read_only=True)
    file_url = serializers.SerializerMethodField()
    
    class Meta:
        model = MediaFile
        fields = '__all__'
        read_only_fields = ['id']
    
    def get_file_url(self, obj):
        """获取文件完整URL"""
        request = self.context.get('request')
        if obj.file_path and request:
            return request.build_absolute_uri(obj.file_path.url)
        return None


# 详细序列化器（包含关联数据）

class ExperimentDetailSerializer(ExperimentSerializer):
    """实验详细序列化器"""
    fields = FieldSerializer(many=True, read_only=True)
    animals = AnimalSerializer(many=True, read_only=True)


class FieldDetailSerializer(FieldSerializer):
    """小区详细序列化器"""
    observations = ObservationSerializer(many=True, read_only=True)
    medias = MediaFileSerializer(many=True, read_only=True)


class AnimalDetailSerializer(AnimalSerializer):
    """动物详细序列化器"""
    observations = ObservationSerializer(many=True, read_only=True)
    medias = MediaFileSerializer(many=True, read_only=True)