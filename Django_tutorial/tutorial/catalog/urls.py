
from django.urls import path, include
from catalog.views import home_page
from .views import FilmListView, ActorListView

urlpatterns = [
    path('films/', FilmListView.as_view(), name='films'),
    path('actors/', ActorListView.as_view(), name='actors'),
]
