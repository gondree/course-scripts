import zipfile
import os, sys
import re, tempfile

def rm_pptx(str):
    return re.sub(r'<p:txBody>.*</p:txBody>', '<p:txBody><a:bodyPr/><a:lstStyle/><a:p><a:endParaRPr/></a:p></p:txBody>', str)

def rm_apxl(str):
    return re.sub(r'<key:notes [^>]*>.*?</key:notes>', '', str)

def pptx_main(fn,fn2):
    old = zipfile.ZipFile(fn, "r")
    new = zipfile.ZipFile(fn2, "w")
    for item in old.infolist():
        data = old.read(item.filename)
        if item.filename.startswith("ppt/notesSlides/notesSlide") \
                and item.filename.endswith(".xml"):
            print ". . .", "cleaning", item.filename
            data = rm_pptx(data)
        new.writestr(item, data)
    new.close()
    old.close()
    print "Complete. Saved as", fn2

def key_main(fn,fn2):
    old = zipfile.ZipFile(fn, "r")
    new = zipfile.ZipFile(fn2, "w")
    for item in old.infolist():
        data = old.read(item.filename)
        if item.filename.startswith("index") \
                and item.filename.endswith(".apxl"):
            print ". . .", "cleaning", item.filename
            data = rm_apxl(data)
        new.writestr(item, data)
    new.close()
    old.close()
    print "Complete. Saved as", fn2

if __name__ == '__main__':
    try:
        if len(sys.argv) > 1:
            for arg in sys.argv[1:]:
                fn = os.path.abspath(arg)
                clean_path = os.path.dirname(fn)+"/cleaned"
                if not os.path.exists(clean_path):
                    os.makedirs(clean_path)
                fn2 = os.path.dirname(fn)+"/cleaned/"+os.path.basename(fn)
                print "Processing %s -- please wait." % fn
                if fn[-5:] == '.pptx':
                    pptx_main(fn, fn2)
                elif fn[-4:] == '.key':
                    key_main(fn, fn2)
                else:
                    raise RuntimeError("I don't recognize that file type.")
                print "---"
        else:
            print "You need to drag your .pptx file(s) onto this one."
    finally:
        print "Done."
