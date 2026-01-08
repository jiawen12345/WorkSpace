from django.contrib import admin
from .models import Mutant, Experiment, Field, Animal, TraitDefinition, Observation, MediaFile


@admin.register(Mutant)
class MutantAdmin(admin.ModelAdmin):
    list_display = ['mutant_code', 'name', 'created_at']
    search_fields = ['mutant_code', 'name']
    list_filter = ['created_at']


@admin.register(Experiment)
class ExperimentAdmin(admin.ModelAdmin):
    list_display = ['name', 'year', 'experiment_type', 'location', 'status', 'start_date']
    list_filter = ['year', 'experiment_type', 'status']
    search_fields = ['name', 'location']
    date_hierarchy = 'start_date'


@admin.register(Field)
class FieldAdmin(admin.ModelAdmin):
    list_display = ['field_code', 'experiment', 'mutant', 'status', 'last_collected']
    list_filter = ['status', 'experiment']
    search_fields = ['field_code', 'mutant_code']
    raw_id_fields = ['experiment', 'mutant']


@admin.register(Animal)
class AnimalAdmin(admin.ModelAdmin):
    list_display = ['ear_tag', 'experiment', 'sex', 'birth_date', 'status', 'building', 'pen']
    list_filter = ['sex', 'status', 'experiment']
    search_fields = ['ear_tag', 'sire_code', 'dam_code']
    date_hierarchy = 'birth_date'


@admin.register(TraitDefinition)
class TraitDefinitionAdmin(admin.ModelAdmin):
    list_display = ['code', 'name', 'unit', 'data_type']
    list_filter = ['data_type']
    search_fields = ['code', 'name']


@admin.register(Observation)
class ObservationAdmin(admin.ModelAdmin):
    list_display = ['trait', 'value', 'observer', 'measure_date', 'field_link', 'animal_link']
    list_filter = ['trait', 'measure_date', 'observer']
    search_fields = ['value', 'observer']
    raw_id_fields = ['field_link', 'animal_link', 'trait']
    date_hierarchy = 'measure_date'


@admin.register(MediaFile)
class MediaFileAdmin(admin.ModelAdmin):
    list_display = ['media_type', 'captured_by', 'capture_time', 'field_link', 'animal_link']
    list_filter = ['media_type', 'capture_time']
    search_fields = ['captured_by', 'description']
    raw_id_fields = ['field_link', 'animal_link']
    date_hierarchy = 'capture_time'