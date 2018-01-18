#!/bin/sh
#
# clip2qr.sh
# ==========
# Grabs the contents of the X clipboard, generates a QR code image and displays it for immediate use.
# 
#
# Released under the terms of the MIT-License (see below).
# Copyright (c) 2013 Dave Kliczbor <maligree@gmx.de>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Set up a temporary directory
TMPDIR=$(mktemp -d)
# ensure removal of said tempdir on exit
trap 'rm -rf $TMPDIR; exit 1' 0 1 2 3 13 15

# First, try to convert data from clipboard and push it into tempdir

# check if primary clipboard contains convertible data
if xclip -o | qrencode -s 2 -m 2 -o - > $TMPDIR/qrcode.png
then 
    TXT=$(xclip -o)

# check if clipboard contains convertible data
elif xclip -o -selection clipboard | qrencode -s 2 -m 2 -o - > $TMPDIR/qrcode.png
then
    TXT=$(xclip -o -selection clipboard)

# no convertible data found -> notify user (maybe you need to insert your notificator of choice here)
else
    STXT=$( echo "$(xclip -o)" | head -n 1 | cut -c 1-50 )
    notify-send -i unknown "Conversion Error" "Cannot provide a QR Code for the current clipboard contents:\
    \
    $STXT ..."
    exit 0
fi

# Write the contents of the qr code as text to tempdir
echo "$TXT" > $TMPDIR/content.txt

# Start python interpreter to display the QR code
python - <<PYEND
import Tkinter
from PIL import Image
from PIL import ImageTk

# Pull up a TK window, make it fullscreen and focusable
tk = Tkinter.Tk()
tk.geometry("%dx%d+0+0" % (tk.winfo_screenwidth(), tk.winfo_screenheight()))
tk.wm_focusmodel(Tkinter.ACTIVE)

# Quit on anything
def handler(event):
    tk.quit()
    tk.destroy()
tk.bind("<Key>", handler)
tk.bind("<KeyPress>", handler)
tk.bind("<Button>", handler)
tk.protocol("WM_DELETE_WINDOW", tk.destroy)

# These variables will be needed after the try block
txt = ""
tkim = None

try:
    # Read QR code image, convert to byte stream
    img = Image.open("$TMPDIR/qrcode.png").convert()
    # Double the size of the image until it fills at least half the screen (minus a margin)
    while (img.size[1] < tk.winfo_screenheight() * 0.4) and (img.size[0] < tk.winfo_screenwidth() * 0.45):
        img = img.resize(([x*2 for x in img.size]), Image.NONE)
    # Wrap image in Tk-Container
    tkim = ImageTk.PhotoImage(img)
    # Read text to display from file
    txt = file("$TMPDIR/content.txt").read()
except Exception as e:
    txt = "Error while retrieving data to display: " + str(e)

# Headline label widget
lh = Tkinter.Label(tk, text="QR Code from Clipboard", font=("sans-serif", 12), background="#000", 
                    foreground="#FFF", justify=Tkinter.CENTER).pack(fill=Tkinter.BOTH, expand=1)
# QR code image label widget
li = Tkinter.Label(tk, image=tkim, background="#000", foreground="#FFF", 
                    justify=Tkinter.CENTER).pack(fill=Tkinter.BOTH, expand=1)
# QR code contents text label widget
lt = Tkinter.Label(tk, text=txt, font=("sans-serif", 9), background="#000", foreground="#FFF", justify=Tkinter.LEFT, 
                    wraplength=tk.winfo_screenwidth()*0.9).pack(fill=Tkinter.BOTH, expand=1)

# Lift window, grab focus
tk.overrideredirect(True)
tk.lift()
tk.focus_force()
tk.grab_set()
tk.grab_set_global()
# run event loop until destruction via handlers above
tk.mainloop()
PYEND

# Clean up
rm -rf $TMPDIR
trap 0 1 2 3 13 15
