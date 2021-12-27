from django.shortcuts import render
from django.views import generic
from .forms import UserCreationFormModified

class SignUpView(generic.CreateView):
	form_class = UserCreationFormModified
	# success_url = 
	template_name = 'signup.html'