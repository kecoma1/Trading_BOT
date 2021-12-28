from django.shortcuts import render
from django.views import generic
from django.urls import reverse_lazy
from .forms import UserCreationFormModified

class SignUpView(generic.CreateView):
	form_class = UserCreationFormModified
	success_url = reverse_lazy('home')
	template_name = 'signup.html'