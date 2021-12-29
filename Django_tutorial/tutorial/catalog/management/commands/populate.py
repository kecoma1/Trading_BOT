from django.core.management.base import BaseCommand
from catalog.models import Actor, Film, Comment
import random


film_names = ["Spiderman", "Spiderman 2", "Spiderman 3",
			  "The Amazing Spiderman", "The Amazing Spiderman 2",
			  "Doctor Strange", "Avengers", "Avengers Age of ultron", "Avengers Endgame", "Avengers Infinity war"]

actor_names = ["Tom Holland", "Tom hardy", "Robert dw jn", "Scarlett Johanson", "Benedict cumber", "Chris Evans", "Chris hemsworth", "Zendaya"]

class Command(BaseCommand):

	def handle(self, *args, **kwargs):
		for actor in actor_names:
			a = Actor(name=actor, age=random.randint(18, 50))
			a.save()
		
		for film in film_names:
			f = Film()
			f.title = film
			f.price = 10.99
			f.score = random.randint(0,10)
			f.save()

			actors_in_movie = []
			for _ in range(random.randint(1, 5)):
				index = random.randint(0, len(actor_names)-1)
				while index in actors_in_movie:
					index = random.randint(0, len(actor_names)-1)
				actors_in_movie.append(index)

				f.actor.add(Actor.objects.all()[index])

		for i in range(10):
			c = Comment(text="Comment "+str(i), film=Film.objects.all()[random.randint(0, len(film_names)-1)])
			c.save()

