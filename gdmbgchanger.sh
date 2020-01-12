#!/bin/sh

# Simple script that will help you set new background for GNOME Display Manager
# Contain some part of extractgst.sh found on ArchWiki

GST=/usr/share/gnome-shell/gnome-shell-theme.gresource

# Assign some variables
XML_1='
<?xml version="1.0" encoding="UTF-8"?>
<gresources>
  <gresource prefix="/org/gnome/shell/theme">
'

XML_3='
  </gresource>
</gresources>
'
XML_2=''
XML=''

# Choose working directory
read -e -p $'\033[1mEnter absolute path to working directory: \033[0m' -i "${HOME}/gnome-shell" WORKDIR
echo -e "\033[32m[OK]\e[0m \033[1mWorking directory set to:\033[0m $WORKDIR"

if [ -d ${WORKDIR}/theme ]; then
  rm -rf ${WORKDIR}/theme
fi
mkdir -p ${WORKDIR}/theme

# Choose background image and check if it exists
while true; do
    read -e -p $'\033[1mEnter absolute path of new background: \033[0m' -i "${WORKDIR}/" NEWBG
    if [ -f "$NEWBG" ]; then
        echo -e "\033[32m[OK]\033[0m \033[1mNew background:\033[0m $NEWBG"
        break
    else
        echo -e "\033[31m[ERR]\033[0m \033[1mFile: $NEWBG does not exists!\033[0m"
    fi
done

NEWBGFILE="${NEWBG##*/}"
NEWBGPATH="${WORKDIR}/theme/${NEWBGFILE}"

cp $NEWBG $NEWBGPATH

# Optionally apply some gegl filters (requires gegl)
while true; do
    read -p $'\033[1mDo you wish to add some (more) filters to your background? (Requires gegl, profided with GIMP) [y/N]: \033[0m' yn
    case "$yn" in
        [Yy]* )
            read -p $'\033[1mU want some blur? (gaussian-blur) [Y/n]: \033[0m' bluryn
            case "$bluryn" in
                [Nn]* )
                    :
                    ;;
                * )
                    while true; do
                        read -e -p $'\033[1mHow strong U want to blur it? (6 is already cool): \033[0m' -i "6" SIZE
                        if [ -z "$SIZE" ]; then
                            echo -e "\033[31m[ERR]\e[0m \033[1mSize not provided!\033[0m"
                        elif [[ -n ${SIZE//[0-9]/} ]]; then
                            echo -e "\033[31m[ERR]\e[0m \033[1mSize has to be a number!\033[0m"
                        else
                            BLURCMD="gegl -i ${NEWBGPATH} -o ${NEWBGPATH} -- gaussian-blur std-dev-x=${SIZE} std-dev-y=${SIZE} filter=auto abyss-policy=clamp clip-extent=true"
                            eval $BLURCMD
                            break
                        fi
                    done
                    ;;
            esac
            read -p $'\033[1mU want to tile it seamlessly? (Usefull for multi monitor setups) [Y/n]: \033[0m' tileyn
            case "$tileyn" in
                [Nn]* )
                    :
                    ;;
                * )
                    TILECMD="gegl -i ${NEWBGPATH} -o ${NEWBGPATH} -- tile-seamless"
                    eval $TILECMD
                    ;;
            esac
            ;;
        * )
            break
            ;;
    esac
done

# Extract GNOME Shell Theme and log all files in a .xml

for r in `gresource list $GST`; do
        gresource extract $GST $r >$WORKDIR/${r#\/org\/gnome\/shell/}
        FILE=${r:23}
	    printf -v XML_2 "$XML_2  <file>${FILE}</file>\n"
done

printf -v XML "${XML_1}\n  <file>${NEWBGFILE}</file>\n${XML_2}${XML_3}"

printf "${XML}" >> ${WORKDIR}/theme/gnome-shell-theme.gresource.xml

# Edit background in gnome-shell.css 
echo -e "\033[33m[INFO]\033[0m \033[1mModifying file: gnome-shell.css ...\033[0m"
AWKCSS="gawk -i inplace -v INPLACE_SUFFIX=.bak '1;/lockDialogGroup/{getline; \$3=\"url(${NEWBGFILE});\"; print}' ${WORKDIR}/theme/gnome-shell.css"
eval $AWKCSS

# Compile new gnome-shell-theme.gresource using glib and new .xml file
echo -e "\033[33m[INFO]\033[0m \033[1mCompiling file: gnome-shell-theme.gresource ...\033[0m"
GLIBC="/bin/glib-compile-resources --sourcedir=${WORKDIR}/theme ${WORKDIR}/theme/gnome-shell-theme.gresource.xml"
eval $GLIBC

# Copy files to /usr/share/gnome-shell
while true; do
    read -p $'\033[1mCopy newly compiled files to: /usr/share/gnome-shell ? (sudo required) [y/N]: \033[0m' copyyn
    case "$copyyn" in
        [Yy] )
            echo -e "\033[33m[INFO]\033[0m \033[1mCopying file: gnome-shell-theme.gresource ...\033[0m"
            COPYFL="sudo cp ${WORKDIR}/theme/gnome-shell-theme.gresource /usr/share/gnome-shell"
            eval $COPYFL
            break
            ;;
        * )
            read -p $'\033[1mDo you wish to exit? [y/N]: \033[0m' exityn
            case "$exityn" in 
                [Yy] )
                    exit 1
                    ;;
                * )
                    :
                    ;;
            esac
            ;;
    esac
done 

# Restart GDM to apply changes
while true; do
    read -p $'\033[1mThis is the last step, thank you for using this script :) \n\033[31m[WARNING]\033[0m \033[1mYour graphical session will be lost!\033[0m \nDo you want to restart GDM? [y/N]: \033[0m' gdmyn
    case "$gdmyn" in
        [Yy] )
            RESTARTGDM="sudo systemctl restart gdm"
            eval $RESTARTGDM
            break
            ;;
        * )
            read -p $'\033[1mDo you wish to exit? [y/N]: \033[0m' exityn
            case "$exityn" in 
                [Yy] )
                    exit 1
                    ;;
                * )
                    :
                    ;;
            esac
            ;;
    esac
done

