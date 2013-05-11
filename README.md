clip2qr
=======

Grabs the contents of the X clipboard, generates a QR code image and displays it for immediate use.

There are no options. Save the clip2qr.sh file somewhere, make it executable and somehow register it in your Desktop Environment.
 * You might register it to run on a keyboard shortcut, e.g. Ctrl-B.
 * You might assign a starter icon on your panel to this script.
 * Or you might find a completely different method to invoke this script.

Install
-------

    $ wget https://raw.github.com/orithena/clip2qr/master/clip2qr.sh -O /tmp/clip2qr.sh
    $ sudo cp /tmp/clip2qr.sh /usr/local/bin
    $ sudo chmod +x /usr/local/bin/clip2qr.sh

Dependencies
------------

On Ubuntu, the following packages need to be installed: python, python-tk, qrencode, xclip.

    $ sudo apt-get install python python-tk qrencode xclip
