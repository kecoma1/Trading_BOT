from django.shortcuts import render
from .models import Actor, Film
from django.views import generic

def home_page(request):
	num_actors = Actor.objects.all().count()
	num_film = Film.objects.all().count()

	data_dict = {
		'number_actors': num_actors,
		'number_films': num_film,
	}

	return render(request, 'index.html', context=data_dict)


class ActorListView(generic.ListView):
	model = Actor
	context_object_name = 'actor_list'


class FilmListView(generic.ListView):
	model = Film
	context_object_name = 'film_list'


class ActorDetailView(generic.DetailView):
	model = Actor


class FilmDetailView(generic.DetailView):
	model = Film