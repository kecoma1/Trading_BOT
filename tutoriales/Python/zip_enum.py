from faker import Faker

# Just for random strings
fake = Faker()

l1 = [i for i in range(10)]
l2 = [fake.first_name() for _ in range(10)]

l3 = []
d = {}

for number, name in zip(l1, l2):
    l3.append((number, name))
    d[name] = number

print("New list:", l3)
print("New dict:", d)

# New names
l2 = [fake.first_name() for _ in range(10)]
enumerated = []

# Lets enumerate them
for i, name in enumerate(l2):
    enumerated.append((i, name))

print("Enumerated names:", enumerated)
