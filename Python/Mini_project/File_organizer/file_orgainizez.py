import os 
import shutil

# define the source and destination directories

#folder path you want to organize

# FOLDER_PATH = "C:/Users/YourUsername/Downloads"  # Change this to your folder path  

FOLDER_PATH = "E:\\Downloads"  # Change this to your folder path

#file type mappings to their respective folders
FILE_TYPE_MAPPING = {
    'Images': ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff'],
    'Documents': ['.pdf', '.docx', '.txt', '.xlsx', '.pptx'],
    'Audio': ['.mp3', '.wav', '.aac'],
    'Videos': ['.mp4', '.avi', '.mov', '.mkv'],
    'Archives': ['.zip', '.rar', '.tar.gz'],
    'Scripts': ['.py', '.js', '.sh'],
    'Others': []  # For files that don't match any of the above types
}

#create folders for each file type if they don't exist
for folder in FILE_TYPE_MAPPING.keys(): 
    folder_path = os.path.join(FOLDER_PATH, folder)
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)

#Oragnise files in the folder based on their extensions
for filename in os.listdir(FOLDER_PATH):
    file_path = os.path.join(FOLDER_PATH, filename)
    
    # Skip directories
    if os.path.isdir(file_path):
        continue
    
    # Get the file extension
    _, file_extension = os.path.splitext(filename)
    
    # Determine the destination folder based on the file extension
    destination_folder = None
    for folder, extensions in FILE_TYPE_MAPPING.items():
        if file_extension.lower() in extensions:
            destination_folder = folder
            break
    
    # If no matching folder was found, move to 'Others'
    if destination_folder is None:
        destination_folder = 'Others'
    
    # Move the file to the appropriate folder
    destination_path = os.path.join(FOLDER_PATH, destination_folder, filename)
    shutil.move(file_path, destination_path)

    #print(f"Moved: {filename} to {destination_folder}")
    print(f"Moved: {filename} to {destination_folder}")
    
