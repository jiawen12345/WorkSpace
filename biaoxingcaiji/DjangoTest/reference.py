"""
表型采集系统 Models
基于 ccge/model_new.py 优化和完善
"""

from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from ccge.models import Mutant
import uuid


class Experiment(models.Model):
    """实验模型"""
    STATUS_CHOICES = [
        ('ongoing', '进行中'),
        ('completed', '已完成'),
        ('paused', '已暂停'),
    ]
    TYPE_CHOICES = [
        ('plant', '植物/作物'),
        ('animal', '动物/家畜'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=200, verbose_name='实验名称')
    year = models.IntegerField(verbose_name='实验年份', help_text="例如: 2025")
    experiment_type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='plant', verbose_name='实验类型')
    location = models.CharField(max_length=200, blank=True, null=True, verbose_name='实验地点')
    description = models.TextField(blank=True, null=True, verbose_name='实验描述')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='ongoing', verbose_name='状态')
    start_date = models.DateField(verbose_name='开始日期')
    end_date = models.DateField(null=True, blank=True, verbose_name='结束日期')
    created_name = models.CharField(max_length=150, blank=True, null=True, verbose_name='创建者姓名')
    is_invisible = models.BooleanField(default=False, blank=True, null=True, verbose_name='是否隐藏')
    comment = models.TextField(blank=True, null=True, verbose_name='备注')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')

    class Meta:
        db_table = 'pt_experiments'
        verbose_name = '实验'
        verbose_name_plural = '实验'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['year', 'location']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f"{self.year} - {self.name}"


class Field(models.Model):
    """小区模型 (Field/Plot)"""
    STATUS_CHOICES = [
        ('not_collected', '未采集'),
        ('collected', '已采集'),
        ('submitted', '已提交'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    field_code = models.CharField(max_length=50, verbose_name='小区编号')
    experiment = models.ForeignKey(
        'Experiment', 
        on_delete=models.CASCADE, 
        related_name='fields', 
        verbose_name='所属试验'
    )
    mutant = models.ForeignKey(
        Mutant,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='fields',
        verbose_name='关联种质'
    )
    
    mutant_code = models.CharField(max_length=100, blank=True, null=True, verbose_name='突变体编码(快照)')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='not_collected', verbose_name='采集状态')
    last_collected = models.DateTimeField(null=True, blank=True, verbose_name='最后采集时间')
    is_invisible = models.BooleanField(default=False, verbose_name='是否隐藏')
    description = models.TextField(blank=True, null=True, verbose_name='种植描述')
    comment = models.TextField(blank=True, null=True, verbose_name='备注')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'pt_fields'
        verbose_name = '小区'
        verbose_name_plural = '小区列表'
        unique_together = [['experiment', 'field_code']]
        ordering = ['field_code']
        indexes = [
            models.Index(fields=['experiment', 'field_code']),
        ]

    def __str__(self):
        mutant_str = self.mutant.mutant_code if self.mutant else (self.mutant_code or "未知")
        return f"{self.experiment.name} - {self.field_code} ({mutant_str})"

    def save(self, *args, **kwargs):
        if self.mutant:
            self.mutant_code = self.mutant.mutant_code
        super().save(*args, **kwargs)


class Animal(models.Model):
    """动物个体模型"""
    SEX_CHOICES = [
        ('M', '公 (Boar)'),
        ('F', '母 (Sow/Gilt)'),
        ('C', '阉公 (Barrow)'),
    ]
    STATUS_CHOICES = [
        ('active', '存栏'),
        ('dead', '死亡'),
        ('sold', '出售/淘汰'),
        ('transferred', '转出'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    experiment = models.ForeignKey(Experiment, on_delete=models.CASCADE, related_name='animals')
    
    ear_tag = models.CharField(max_length=100, unique=True, verbose_name='耳号/RFID')
    building = models.CharField(max_length=100, blank=True, null=True, verbose_name='栋/舍')
    pen = models.CharField(max_length=100, blank=True, null=True, verbose_name='栏位号')

    sex = models.CharField(max_length=10, choices=SEX_CHOICES, verbose_name='性别')
    birth_date = models.DateField(blank=True, null=True, verbose_name='出生日期')
    birth_weight = models.FloatField(blank=True, null=True, verbose_name='出生重(kg)')
    
    sire_code = models.CharField(max_length=100, blank=True, null=True, verbose_name='父本耳号')
    dam_code = models.CharField(max_length=100, blank=True, null=True, verbose_name='母本耳号')

    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active', verbose_name='状态')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_invisible = models.BooleanField(default=False, verbose_name='是否隐藏')
    description = models.TextField(blank=True, null=True, verbose_name='描述')
    comment = models.TextField(blank=True, null=True, verbose_name='备注')

    class Meta:
        db_table = 'pt_animals'
        verbose_name = '动物个体'
        verbose_name_plural = '动物个体'
        indexes = [
            models.Index(fields=['ear_tag']),
            models.Index(fields=['experiment', 'pen']),
        ]

    def __str__(self):
        return f"{self.ear_tag} ({self.get_sex_display()})"


class TraitDefinition(models.Model):
    """性状定义表"""
    DATATYPE_CHOICES = [
        ('number', '数值型'),
        ('text', '文本型'),
        ('category', '选项型'),
        ('date', '日期型'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100, verbose_name="性状名称")
    code = models.CharField(max_length=50, unique=True, verbose_name="性状代码")
    unit = models.CharField(max_length=50, blank=True, verbose_name="单位")
    data_type = models.CharField(max_length=20, choices=DATATYPE_CHOICES, default='number', verbose_name="数据类型")
    description = models.TextField(blank=True, verbose_name="描述")
    is_invisible = models.BooleanField(default=False, verbose_name='是否隐藏')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'pt_trait_definitions'
        verbose_name = '性状定义'
        verbose_name_plural = '性状定义'
        ordering = ['code']

    def __str__(self):
        return f"{self.code} - {self.name}"


class Observation(models.Model):
    """采集数据表"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    field_link = models.ForeignKey(
        Field, 
        null=True, 
        blank=True, 
        on_delete=models.CASCADE, 
        related_name='observations',
        verbose_name='关联小区'
    )
    animal_link = models.ForeignKey(
        Animal, 
        null=True, 
        blank=True, 
        on_delete=models.CASCADE, 
        related_name='observations',
        verbose_name='关联动物'
    )
    trait = models.ForeignKey(
        TraitDefinition, 
        on_delete=models.PROTECT, 
        related_name='observations',
        verbose_name='性状'
    )
    
    value = models.CharField(max_length=500, verbose_name="测量值")
    observer = models.CharField(max_length=100, verbose_name="采集人")
    measure_date = models.DateTimeField(auto_now_add=True, verbose_name="采集时间")
    is_invisible = models.BooleanField(default=False, verbose_name='是否隐藏')
    comment = models.TextField(blank=True, null=True, verbose_name='备注')

    class Meta:
        db_table = 'pt_observations'
        verbose_name = '观测数据'
        verbose_name_plural = '观测数据'
        indexes = [
            models.Index(fields=['field_link', 'trait']),
            models.Index(fields=['animal_link', 'trait']),
            models.Index(fields=['measure_date']),
        ]

    def __str__(self):
        target = self.field_link or self.animal_link
        return f"{target} - {self.trait.code}: {self.value}"


class MediaFile(models.Model):
    """多媒体文件表"""
    MEDIA_TYPES = [
        ('image', '照片'),
        ('video', '视频'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    field_link = models.ForeignKey(
        Field, 
        null=True, 
        blank=True, 
        on_delete=models.CASCADE, 
        related_name='medias',
        verbose_name='关联小区'
    )
    animal_link = models.ForeignKey(
        Animal, 
        null=True, 
        blank=True, 
        on_delete=models.CASCADE, 
        related_name='medias',
        verbose_name='关联动物'
    )
    file_path = models.FileField(upload_to='phenotype_media/%Y/%m/', verbose_name="文件路径")
    media_type = models.CharField(max_length=20, choices=MEDIA_TYPES, default='image', verbose_name="媒体类型")
    capture_time = models.DateTimeField(verbose_name="拍摄时间")
    captured_by = models.CharField(max_length=100, verbose_name="拍摄者")
    is_invisible = models.BooleanField(default=False, blank=True, null=True, verbose_name='是否隐藏')
    description = models.TextField(blank=True, verbose_name="描述")
    comment = models.TextField(blank=True, null=True, verbose_name='备注')

    class Meta:
        db_table = 'pt_media_files'
        verbose_name = '多媒体文件'
        verbose_name_plural = '多媒体文件'
        indexes = [
            models.Index(fields=['field_link']),
            models.Index(fields=['animal_link']),
            models.Index(fields=['capture_time']),
        ]

    def __str__(self):
        return f"{self.get_media_type_display()} - {self.capture_time}"


