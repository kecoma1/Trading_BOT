from django.db import models
from django.template.defaultfilters import slugify
from django.urls import reverse


class Actor(models.Model):
	name = models.CharField(max_length=100)
	age = models.IntegerField()
	slug = models.SlugField(null=True, blank=True)

	class Meta:
		ordering = ['age', 'name']

	def save(self, *args, **kwargs):
		self.slug = slugify(self.name+" "+str(self.age))
		return super().save(*args, **kwargs)

	def __str__(self):
		return "Name: "+self.name+", Age: "+str(self.age)

	def display_films(self):
		return ', '.join(str(film) for film in Film.objects.filter(actor=self))

	def get_films(self):
		return Film.objects.filter(actor=self)



class Film(models.Model):
	title = models.CharField(max_length=100)
	price = models.DecimalField(decimal_places=2, max_digits=4)
	score = models.DecimalField(decimal_places=2, max_digits=4)
	slug = models.SlugField(null=True, blank=True)
	actor = models.ManyToManyField(Actor)

	class Meta:
		ordering = ['score', 'price', 'title']

	def save(self, *args, **kwargs):
		self.slug = slugify(self.title)
		return super().save(*args, **kwargs)

	def __str__(self):
		return self.title

	def display_actors(self):
		return ' | '.join(str(actor) for actor in self.actor.all())

	def set_score(self, score):
		self.score = score
		self.save()

	def get_absolute_url(self):
		return reverse('film', kwargs={'slug': self.slug})


class Comment(models.Model):
	text = models.CharField(max_length=1000)
	film = models.ForeignKey(Film, on_delete=models.SET_NULL, null=True, blank=True)

	def __str__(self):
		return "Comment: "+self.text