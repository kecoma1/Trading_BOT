from faker.providers.person.en import Provider
from faker import Faker
from faker.providers import internet


# Incase you want to create the object with different languages
languages = ['it_IT', 'en_US', 'ja_JP']


# Creating the fake object
fake = Faker()  # Faker(languages)

# Creating 10 names
print("Names:")
for _ in range(10):
    name = fake.name()
    print(name)


# Adding to the fake object IP's
print("\nIp's:")
fake.add_provider(internet)
for _ in range(10):
    ip = fake.ipv4_private()
    print(ip)

# Use unique values
print("\nUnique names:")
names = [fake.unique.first_name() for _ in range(50)]
print(names)

# A lot of things can be generated 
# https://faker.readthedocs.io/en/master/providers.html
for _ in range(5):
    fake.isbn13()
