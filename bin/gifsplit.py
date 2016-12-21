#!/usr/bin/python
from PIL import Image
import sys
im=Image.open(sys.argv[1])
t=Image.new('RGBA',im.size,None)
p=im.getpalette()
transparency = im.info['transparency'] 
c=1
try:
    while True:
        im.seek(im.tell()+1)
        t=im.copy()
        t.putpalette(p)
        t.save(ur'%s%d.png'%(sys.argv[2],c,),'PNG',transparency=transparency)
        c+=1
except EOFError:
    pass
