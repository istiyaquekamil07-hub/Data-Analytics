import time
import random

sentences = [
    "The quick brown fox jumps over the lazy dog.",
     "A journey of a thousand miles begins with a signle step.",
     "This is the our way to refrence the object of the class."
]

def typing_test():
    test_sentence = random.choice(sentences)
    print("Type the following sentence:")
    print(test_sentence)
    input("Press Enter when you are ready to start...")
    start_time = time.time() #measure the time taken to type the sentence
    user_input = input("\n Start typing: ")
    end_time = time.time() 

    time_taken = end_time - start_time
    words = user_input.split()
    num_words = len(words)

    print("Results:")
    print(f"Time taken: {time_taken:.2f} seconds")
    print(f"words per minute (WPM): {num_words / (time_taken / 60):.2f}")

    print(f"Number of words typed: {num_words}")    

typing_test()


