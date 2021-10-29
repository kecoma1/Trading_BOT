class Book:
    name = ""
    author = ""
    num_pages = 0
    
    def __init__(self, name, author, num_pages):
        self.name = name
        self.author = author
        self.num_pages = num_pages
        
    def info(self):
        return self.name+" was written by "+self.author+" and it has "+str(self.num_pages)+" pages"

b1 = Book("Harry Potter", "J. K. Rowling", 700)
b2 = Book("Jujutsu kaysen", "Author 2", 100)

print(b1.info())
print(b2.info())