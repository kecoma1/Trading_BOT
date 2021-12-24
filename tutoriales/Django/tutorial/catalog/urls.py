from django import views
from django.contrib import admin
from django.urls import path
from . import views

urlpatterns = [
    path('books/', views.BookListView.as_view(), name='books'),
    path('authors/', views.AuthorListView.as_view(), name='authors'),
    path('book/<slug:slug>/', views.BookDetailView.as_view(), name='book'),
    path('author/<slug:slug>/', views.AuthorDetailView.as_view(), name='author')
]
