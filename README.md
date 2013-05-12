clip2qr
=======

Grabs the contents of the X clipboard, generates a QR code image and displays it for 
immediate use. Main usecase: get a URL or some text snippet to your smartphone.
You need to have an app installed on your smartphone that can read QR Codes (e.g. QRDroid).

There are no options. Save the clip2qr.sh file somewhere, make it executable and somehow 
register it in your Desktop Environment.
 * You might register it to run on a keyboard shortcut, e.g. Ctrl-B.
 * You might assign a starter icon on your panel to this script.
 * Or you might find a completely different method to invoke this script.

Dependencies
------------

On Ubuntu, the following packages need to be installed: python, python-tk, qrencode, xclip.

    $ sudo apt-get install python python-tk qrencode xclip

Install
-------

Start a terminal and type the following commands:

    $ wget https://raw.github.com/orithena/clip2qr/master/clip2qr.sh -O /tmp/clip2qr.sh
    $ sudo cp /tmp/clip2qr.sh /usr/local/bin
    $ sudo chmod +x /usr/local/bin/clip2qr.sh
    
Then decide on a method to run this script and register it in your Desktop Environment.
For example, locate the "Keyboard Shortcut" preferences dialog and assign a global shortcut 
to `/usr/local/bin/clip2qr.sh`. Or add a starter to your desktop panel (maybe by right-clicking 
on it?). You could generate an icon for the starter like this:

    $ sudo qrencode -s 1 -m 1 -o /usr/share/icons/qrcode.png "Clipboard to QR Code"
    
Increase the value after -s if you need a bigger icon.

