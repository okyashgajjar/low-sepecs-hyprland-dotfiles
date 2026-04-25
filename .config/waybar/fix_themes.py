import os
import json

waybar_dir = os.path.expanduser("~/.config/waybar")
themes_dir = os.path.join(waybar_dir, "themes")

updates_module = {
    "format": "󰚰  {}",
    "escape": True,
    "return-type": "json",
    "exec": "~/.config/waybar/scripts/updates.sh",
    "interval": 3600,
    "on-click": "kitty -e yay -Syu; pkill -RTMIN+8 waybar",
    "signal": 8
}

def update_config(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Very simple way to handle jsonc: find the last '}' and insert before it
    # But first, add "custom/updates" to modules-right
    if '"custom/updates"' not in content:
        content = content.replace('"custom/power"', '"custom/updates",\n        "custom/power"')
        
        # Insert module definition before the last '}'
        last_brace = content.rfind('}')
        module_def = '\n    "custom/updates": ' + json.dumps(updates_module, indent=4) + ',\n'
        content = content[:last_brace] + module_def + content[last_brace:]
        
        with open(file_path, 'w') as f:
            f.write(content)

def update_style(file_path):
    with open(file_path, 'r') as f:
        style = f.read()
    
    # Fix import
    style = style.replace('@import "colors.css";', '@import "/home/riceyg/.config/waybar/colors.css";')
    style = style.replace('@import "../../colors.css";', '@import "/home/riceyg/.config/waybar/colors.css";')
    style = style.replace('@import "~/.config/waybar/colors.css";', '@import "/home/riceyg/.config/waybar/colors.css";')

    # Add custom-updates styling if missing
    if '#custom-updates' not in style:
        style += '\n#custom-updates {\n    color: @secondary;\n}\n'
        
    with open(file_path, 'w') as f:
        f.write(style)

for theme in os.listdir(themes_dir):
    theme_path = os.path.join(themes_dir, theme)
    if os.path.isdir(theme_path):
        config_p = os.path.join(theme_path, "config.jsonc")
        style_p = os.path.join(theme_path, "style.css")
        
        if os.path.exists(config_p):
            update_config(config_p)
        if os.path.exists(style_p):
            update_style(style_p)

# Also update the root ones just in case they aren't symlinks yet
update_style(os.path.join(waybar_dir, "style.css"))
update_config(os.path.join(waybar_dir, "config.jsonc"))
