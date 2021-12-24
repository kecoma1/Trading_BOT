from django.db import models
from django.template.defaultfilters import slugify


class Author(models.Model):
    name = models.CharField(max_length=100)
    slug = models.SlugField(null=True,
                            blank=True)

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        self.slug = slugify(self.name)
        return super().save(*args, **kwargs)


class Book(models.Model):
    title = models.CharField(max_length=100)
    price = models.DecimalField(decimal_places=2,
                                max_digits=4)
    slug = models.SlugField(null=True,
                            blank=True)
    author = models.ManyToManyField(Author)

    class Meta:
        ordering = ['title', 'price']

    def save(self, *args, **kwargs):
        self.slug = slugify(self.title)
        return super().save(*args, **kwargs)

    def __str__(self):
        return self.title+" - "+str(self.price)+"€"
