import os

waybar_dir = os.path.expanduser("~/.config/waybar")
themes_dir = os.path.join(waybar_dir, "themes")

def fix_bracket_commas(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Fix the missing comma after modules-right list
    # Look for "]," before "custom/launcher"
    # Actually, look for the closing bracket of modules-right specifically
    
    import re
    # Find modules-right block and ensure it ends with ],
    pattern = r'("modules-right": \[[^\]]*\])(\s+"custom/launcher")'
    content = re.sub(pattern, r'\1,\2', content)
    
    with open(file_path, 'w') as f:
        f.write(content)

for theme in os.listdir(themes_dir):
    theme_path = os.path.join(themes_dir, theme)
    if os.path.isdir(theme_path):
        config_p = os.path.join(theme_path, "config.jsonc")
        if os.path.exists(config_p):
            fix_bracket_commas(config_p)

# Also fix the root one
fix_bracket_commas(os.path.join(waybar_dir, "config.jsonc"))
