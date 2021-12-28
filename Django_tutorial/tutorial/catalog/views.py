from django.shortcuts import render
from .models import Actor, Film

def home_page(request):
	num_actors = Actor.objects.all().count()
	num_film = Film.objects.all().count()

	data_dict = {
		'number_actors': num_actors,
		'number_films': num_film,
	}

	return render(request, 'index.html', context=data_dict)