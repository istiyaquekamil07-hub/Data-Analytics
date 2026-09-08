# numbers = [1, 2, 3, 4, 5]

# squared = []
# for x in numbers:
#     squared.append(x * x)
# print(squared)

# #List Comprehension
# squared = [x * x for x in numbers]
# print(squared)

def get_numbers():
    for i in range(5):
        yield i

for x in get_numbers():
    print(x)