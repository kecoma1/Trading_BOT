from catalog.models import Author, Book
from django.core.management.base import BaseCommand
from faker import Faker
from random import randint

class Command(BaseCommand):

	def handle(self, *args, **kwargs):
		fake = Faker()

		Author.objects.all().delete()
		Book.objects.all().delete()

		# Fake authors
		for _ in range(10):
			a = Author(name=fake.name())
			a.save()
		
		# Fake books
		for _ in range(20):
			b = Book()
			b.title = fake.company()
			b.price = 15.99
			b.save()


			prev = -1
			for _ in range(randint(1, 2)):
				index = randint(0, 10-1)
				while index == prev:
					index = randint(0, 10-1)
				b.author.add(Author.objects.all()[index])
				prev = index


