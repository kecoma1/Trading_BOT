from django.contrib import admin
from .models import Actor, Film, Comment


@admin.register(Actor)
class ActorAdmin(admin.ModelAdmin):
	list_display = ('id', 'name', 'display_films')

@admin.register(Film)
class FilmAdmin(admin.ModelAdmin):
	list_display = ('id', 'title', 'score', 'price', 'display_actors')

@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
	list_display = ('id',)