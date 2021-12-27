from django.contrib.auth import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User

class UserCreationFormModified(UserCreationForm):
	class Meta:
		model = User
		fields = ('username', 'email', 'first_name', 'last_name')
