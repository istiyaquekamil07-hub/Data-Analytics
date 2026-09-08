a=int(input("Enter a Number: "))
b=int(input("Enter a Number: "))

try:
    print(a/b)
except ValueError:
    print("Enter a valid number")
except:
    print("Thank you")
finally:
    print("End of the programme")