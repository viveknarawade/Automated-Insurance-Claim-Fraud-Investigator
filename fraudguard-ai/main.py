
import pymupdf

doc = pymupdf.open("/home/vivek/Desktop/images/fir .pdf")
# print(doc.page_count)
# print(doc.metadata)



pageOne = doc[0]


data=""
if data !="":
    print("data ",data)
else:
    print("mobile camera pdf doing ocr")
    zoom = 2.0
    pix = pageOne.get_pixmap()
    pix.save(f"/home/vivek/Desktop/images/{pageOne.number}.png")
    print(pix)



