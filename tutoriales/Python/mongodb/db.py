import pymongo

# Stablishing the connection with the db
myclient = pymongo.MongoClient("mongodb://localhost:27017/")

example_db = myclient["example_db"]
example_collection = example_db["example_collection"]


example_collection.insert_one({"name": "Kevin", "year": 1999})
example_collection.insertMany([
                                {"name": "Kevin", "year": 1999},
                                {"name": "a", "year": 1},
                                {"name": "b", "year": 2},
                                {"name": "c", "year": 3},
                                {"name": "d", "year": 4},
                                {"name": "e", "year": 5},
                                {"name": "f", "year": 6},
                                {"name": "g", "year": 7}
                              ])
