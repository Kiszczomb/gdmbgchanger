# gdmbgchanger

Change your GNOME Desktop Manager (GDM) background/walpaper easier.
Script is quite self-explanatory and will guide you thru the whole process.

![Screenshot](screenshot.jpg)

## Step-by-step manual guide for curious ;) :
1. Create working directory
2. Extract GNOME Shell Theme
3. Provide new background file
4. Create new gnome-shell-theme.gresource.xml file
5. Modify gnome-shell.css "#lockDialogGroup" background atribute
6. Compile new gnome-shell-theme.gresource with glib-compile-resource and .xml file
7. Copy newly compiled file to /usr/share/gnome-shell
8. Restart GDM service

---

*Written on Manjaro with GNOME Shell 3.34.2*
