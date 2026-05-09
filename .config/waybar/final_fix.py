import os

waybar_dir = os.path.expanduser("~/.config/waybar")

def final_fix(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    for i in range(len(lines)):
        if '"modules-right": [' in lines[i]:
            for j in range(i+1, len(lines)):
                if ']' in lines[j]:
                    if ',' not in lines[j]:
                        lines[j] = lines[j].replace(']', '],')
                    break
            break
            
    with open(file_path, 'w') as f:
        f.writelines(lines)

for root, dirs, files in os.walk(waybar_dir):
    for file in files:
        if file == 'config.jsonc':
            final_fix(os.path.join(root, file))
