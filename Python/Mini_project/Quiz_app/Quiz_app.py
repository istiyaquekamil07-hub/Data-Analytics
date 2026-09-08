def run_quiz():
    questions = [
        {
            "question": "What is the capital of France?",
            "options": ["A. Paris", "B. London", "C. Berlin", "D. Madrid"],
            "answer": "A. Paris"
        },
        {
            "question": "What is the largest planet in our solar system?",
            "options": ["A. Earth", "B. Jupiter", "C. Saturn", "D. Mars"],
            "answer": "B. Jupiter"
        },
        {
            "question": "What is the chemical symbol for gold?",
            "options": ["A. Au", "B. Ag", "C. Fe", "D. Pb"],
            "answer": "A. Au"
        }
    ]

    score = 0

    for index, q in enumerate(questions):
        print(f"Question {index + 1}: {q['question']}")

        for option in q["options"]:
            print(option)

        user_answer = input("Enter your answer (A, B, C, or D): ")

        if user_answer.upper() == q["answer"][0]:
            print("Correct!")
            score += 1
        else:
            print(f"Wrong! The correct answer is: {q['answer']}")

        print()

    print(f"Your score is {score}/{len(questions)}")


run_quiz()