# Poki Godot Setup 
This Repo contains a Godot 4.7 Godot project, with a basic setup to access the poki SDK via a .gd and .html script.

Tutorial for making Poki integration work without cloning this:
1. Import [poki_sdk.gd](https://github.com/TomGrzembke/Godot-Poki-Setup/blob/main/poki/poki_sdk.gd) to your desired location; this will be what you work with later
2. Add the script to autoload as a global 
<img width="1197" height="270" alt="image" src="https://github.com/user-attachments/assets/48a5146b-2692-4824-8460-25a9d7569f4c" />

3. Import [poki_shell.html](https://github.com/TomGrzembke/Godot-Poki-Setup/blob/main/poki/poki_shell.html) to your desired destination
4. Add an export preset under Project->Export and set the custom html shell to the poki_shell
   <img width="1386" height="961" alt="image" src="https://github.com/user-attachments/assets/9dc06062-59b5-4e0e-b49b-960023ed935e" />

5. Export and test [here](https://inspector.poki.dev/):
<img width="913" height="535" alt="image" src="https://github.com/user-attachments/assets/ede4dfb5-8f0c-430d-b2c4-de4f0baa8dd9" />
