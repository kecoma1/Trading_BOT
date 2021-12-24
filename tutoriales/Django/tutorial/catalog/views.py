from django.shortcuts import render
from django.views import generic
from .models import Author, Book

class BookListView(generic.ListView):
	model = Book
	context_object_name = 'book_list'

class AuthorListView(generic.ListView):
	model = Author
	context_object_name = 'author_list'

class BookDetailView(generic.DetailView):
	model = Book

class AuthorDetailView(generic.DetailView):
	model = Author

def index(request):
	num_books = Book.objects.all().count()
	num_authors = Author.objects.all().count()

	context_ = {
		'num_books': num_books,
		'num_authors': num_authors,
	}

	return render(request, 'index.html', context=context_)
