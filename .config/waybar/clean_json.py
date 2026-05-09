import os

waybar_dir = os.path.expanduser("~/.config/waybar")
themes_dir = os.path.join(waybar_dir, "themes")

def clean_and_fix_v2(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    new_lines = []
    in_modules_right = False
    
    for line in lines:
        if '"modules-right": [' in line:
            in_modules_right = True
            new_lines.append(line)
            continue
        
        if in_modules_right and ']' in line:
            new_lines.append('    ],\n') # Fixed to have a comma
            in_modules_right = False
            continue
            
        new_lines.append(line)
    
    with open(file_path, 'w') as f:
        f.writelines(new_lines)

for theme in os.listdir(themes_dir):
    theme_path = os.path.join(themes_dir, theme)
    if os.path.isdir(theme_path):
        config_p = os.path.join(theme_path, "config.jsonc")
        if os.path.exists(config_p):
            clean_and_fix_v2(config_p)

clean_and_fix_v2(os.path.join(waybar_dir, "config.jsonc"))
