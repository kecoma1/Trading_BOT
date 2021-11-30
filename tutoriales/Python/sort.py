import random
from faker import Faker

# Just for random strings
fake = Faker()

# Generating the list
nums = [random.randint(0, 10) for _ in range(10)]
print("Unsorted list:", nums)
nums = sorted(nums)
print("Sorted list:", nums)

# List of tuples
tuples = [(fake.first_name(), random.randint(0, 10)) for _ in range(10)]
print("Unsorted list:", tuples)
tuples = sorted(tuples)  # Not working as expected
# tuples = sorted(tuples, key=lambda tuple: tuple[1])
print("Sorted list:", tuples)

# Sorting values of a dictionary
dictionary = {fake.first_name(): random.randint(0, 10) for _ in range(10)}
print("Unsorted dictionary:", dictionary)
# dictionary = sorted(dictionary.values())
dictionary = sorted(dictionary.items(), key=lambda tuple: tuple[1], reverse=True)
print("Sorted dictionary:", dictionary)