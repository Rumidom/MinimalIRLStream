from PIL import Image,ImageDraw,ImageFilter,ImageFont
import numpy as np
from ultralytics import YOLO
import math

resW = 640
resH = 640
 
def detect(img,facmodel,licpmodel,faces=True,licenseplates=True):
    detections = []
    labels = []

    if faces:
        results = facmodel(img, verbose=False)
        detections.extend(results[0].boxes)
        labels.append('Face')

    if licenseplates:
        results = licpmodel(img, verbose=False)
        detections.extend(results[0].boxes)
        labels.append('License Plate')

    return detections,labels,img

def pointsDistance(p0, p1):
    return math.sqrt((p0[0] - p1[0])**2 + (p0[1] - p1[1])**2)

def blurRectangle(img,p0,p1):
    # Create rectangle mask
    mask = Image.new('L', img.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rectangle([ p0,p1], fill=255)

    blurred_image = img.filter(ImageFilter.GaussianBlur(radius=5))
    img.paste(blurred_image, mask=mask)

    return img

def drawDetections(im,detections,min_thresh,box = False,blur=True,circle=False,detectionsize=None):

    # Create a drawing object
    draw = ImageDraw.Draw(im)
    dets = 0
    for i in range(len(detections)):

        # Get bounding box coordinates
        # Ultralytics returns results in Tensor format, which have to be converted to a regular Python array
        xyxy_tensor = detections[i].xyxy.cpu() # Detections in Tensor format in CPU memory
        xyxy = xyxy_tensor.numpy().squeeze() # Convert tensors to Numpy array
        xmin, ymin, xmax, ymax = xyxy.astype(int) # Extract individual coordinates and convert to int
        
        xratio = im.size[0]/detectionsize[0]
        yratio = im.size[1]/detectionsize[1]

        xmin = xratio*xmin
        ymin = yratio*ymin
        xmax = xratio*xmax
        ymax = yratio*ymax
        # Get bounding box class ID and name
        classidx = int(detections[i].cls.item())

        # Get bounding box confidence
        conf = detections[i].conf.item()

        # Draw box if confidence threshold is high enough
        if conf > min_thresh:
            dets += 1
            if circle:
                #center = (int((xmin + xmax)/2),int((ymin + ymax)/2))
                #radius = int(pointsDistance(center, (xmax,ymax)))
                draw.ellipse((xmin,ymin,xmax,ymax), outline ='red')
            if blur:
                im = blurRectangle(im,(xmin,ymin),(xmax,ymax))
            if box:
                draw.rectangle(((xmin,ymin), (xmax,ymax)), outline = 'red')
                conf_str = f'{int(conf*100)}%'
                font = ImageFont.truetype('Roboto-Bold.ttf', 15)  # You can change the font and size
                draw.text((xmin, ymin), conf_str, fill='red', font=font)
    print('n detections: ', dets)
    return im

def getImgAnonymized(img,faces=True,licenseplates=True,box = False,blur=True,min_thresh = 0.5):
    facmodel = YOLO('utils/models/best_faces_yolo11m_100epochs_13-6-2025.pt', task='detect')
    licpmodel = YOLO('utils/models/best_licenseplates_yolo11m_100epochs_11-6-2025.pt', task='detect')
    img = img.convert('RGB')
    thumb_img = resize_image_to_max_width(img,640)
    detections,labels,thumb_img = detect(thumb_img,facmodel,licpmodel,faces=faces,licenseplates=licenseplates)
    img = drawDetections(img,detections,min_thresh,box = box,blur=blur,detectionsize=thumb_img.size)
    return img


def resize_image_to_max_width(img, max_width):
    ratio = img.size[1]/img.size[0]
    height = int(ratio*max_width)
    resized_img = img.resize((max_width, height))
    return resized_img

