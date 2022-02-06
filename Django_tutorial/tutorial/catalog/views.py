from django.contrib.auth.decorators import login_required
from django.shortcuts import redirect, render
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

@login_required
def post_score(request, slug):
	score = request.POST.get("score")
	film = Film.objects.filter(slug=slug)[0]
	if score is not None and score != "":
		film.set_score(int(score))
	return redirect(film.get_absolute_url())