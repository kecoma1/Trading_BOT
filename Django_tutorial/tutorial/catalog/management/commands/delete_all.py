from django.core.management.base import BaseCommand
from catalog.models import Actor, Film, Comment


class Command(BaseCommand):

	def handle(self, *args, **kwargs):
		Actor.objects.all().delete()
		Film.objects.all().delete()
		Comment.objects.all().delete()