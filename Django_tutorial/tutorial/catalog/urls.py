
from django.urls import path, include
from catalog.views import home_page
from . import views

urlpatterns = [
    path('films/', views.FilmListView.as_view(), name='films'),
    path('actors/', views.ActorListView.as_view(), name='actors'),
    path('actor/<slug:slug>/', views.ActorDetailView.as_view(), name='actor'),
    path('film/<slug:slug>/', views.FilmDetailView.as_view(), name='film'),
    path('film/<slug:slug>/post_score/', views.post_score, name='post_score'),
]
