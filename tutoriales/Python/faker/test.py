from faker import Faker


# Incase you want to create the object with different languages
languages = ['it_IT', 'en_US', 'ja_JP']


# Creating the fake object
fake = Faker(languages)

# Creating 10 names
print("Names:")
for _ in range(10):
    name = fake.name()
    print(name)


# Use unique values
print("\nUnique names:")
names = [fake.unique.first_name() for _ in range(50)]
print(names)

# A lot of things can be generated 
# https://faker.readthedocs.io/en/master/providers.html
for _ in range(5):
    print(fake.isbn13())
    