#!/bin/sh

TMPDIR=$(mktemp -d)
trap 'rm -rf $TMPDIR; exit 1' 0 1 2 3 13 15

if xclip -o | qrencode -s 2 -m 2 -o - > $TMPDIR/qrcode.png
then 
    TXT=$(xclip -o)
elif xclip -o -selection clipboard | qrencode -s 2 -m 2 -o - > $TMPDIR/qrcode.png
then
	TXT=$(xclip -o -selection clipboard)
else
	STXT=$( echo "$(xclip -o)" | head -n 1 | cut -c 1-50 )
	notify-send -i unknown "Conversion Error" "Cannot provide a QR Code for the current clipboard contents:\
	\
	$STXT ..."
	exit 0
fi
echo "$TXT" > $TMPDIR/content.txt
python - <<PYEND
import Tkinter,Image,ImageTk
tk = Tkinter.Tk()
tk.geometry("%dx%d+0+0" % (tk.winfo_screenwidth(), tk.winfo_screenheight()))
tk.wm_focusmodel(Tkinter.ACTIVE)
def handler(event):
    tk.quit()
    tk.destroy()
tk.bind("<Key>", handler)
tk.bind("<KeyPress>", handler)
tk.bind("<Button>", handler)
tk.protocol("WM_DELETE_WINDOW", tk.destroy)
txt = ""
tkim = None
try:
	img = Image.open("$TMPDIR/qrcode.png").convert()
	while (img.size[1] < tk.winfo_screenheight() * 0.4) and (img.size[0] < tk.winfo_screenwidth() * 0.45):
		img = img.resize(([x*2 for x in img.size]), Image.NONE)
	tkim = ImageTk.PhotoImage(img)
	txt = file("$TMPDIR/content.txt").read()
except Exception as e:
	txt = "Error while retrieving text: " + str(e)
	
lh = Tkinter.Label(tk, text="QR Code from Clipboard", font=("sans-serif", 12), background="#000", foreground="#FFF", justify=Tkinter.CENTER).pack(fill=Tkinter.BOTH, expand=1)
li = Tkinter.Label(tk, image=tkim, background="#000", foreground="#FFF", justify=Tkinter.CENTER).pack(fill=Tkinter.BOTH, expand=1)
lt = Tkinter.Label(tk, text=txt, font=("sans-serif", 9), background="#000", foreground="#FFF", justify=Tkinter.LEFT, wraplength=tk.winfo_screenwidth()*0.9).pack(fill=Tkinter.BOTH, expand=1)
tk.overrideredirect(True)
tk.lift()
tk.focus_force()
tk.grab_set()
tk.grab_set_global()
tk.mainloop()
PYEND
rm -rf $TMPDIR
trap 0 1 2 3 13 15
