import os

waybar_dir = os.path.expanduser("~/.config/waybar")
themes_dir = os.path.join(waybar_dir, "themes")

def fix_config_v2(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # 1. Fix the broken definition line
    content = content.replace('"custom/updates",\n        "custom/power": {', '"custom/power": {')
    
    # 2. Fix missing commas between modules
    # This is tricky with regex, but we can look for '} "custom/updates"'
    content = content.replace('}\n\n    "custom/updates":', '},\n\n    "custom/updates":')
    content = content.replace('}    "custom/updates":', '},\n    "custom/updates":')
    
    # Also handle the updates module itself potentially missing a trailing comma if there's something after it
    # (Though in our case it's usually at the end)
    
    with open(file_path, 'w') as f:
        f.write(content)

for theme in os.listdir(themes_dir):
    theme_path = os.path.join(themes_dir, theme)
    if os.path.isdir(theme_path):
        config_p = os.path.join(theme_path, "config.jsonc")
        if os.path.exists(config_p):
            fix_config_v2(config_p)

fix_config_v2(os.path.join(waybar_dir, "config.jsonc"))
