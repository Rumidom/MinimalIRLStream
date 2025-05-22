import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import requests
from PIL import Image,ImageOps,ImageDraw,ImageFont
from datetime import datetime
import io
import redis
import time

res = (1920,1080)
Rf = ImageFont.truetype('Roboto-Bold.ttf', int(0.02*res[0]))

def image_to_data(im):
    with io.BytesIO() as output:
        im.save(output, format="PNG")
        data = output.getvalue()
    return data
    
def convertRawRedisToDF(mesurement_list,label="mesurement"):
    x = []
    y = []
    for mesurement in mesurement_list:
        x.append(datetime.fromtimestamp(int(mesurement.split(",")[0])))
        y.append(int(mesurement.split(",")[1]))
    df = pd.DataFrame({'datetime': x,label: y,})
    return df

def GenerateFrame(Titlefont = Rf, stepsData = None,heartRateData = None,Title = "IRL Stream" ,photo = None, resolution = res, bg_color = (16, 17, 24)):
    outputimg = Image.new("RGBA", resolution, bg_color)
    photores = (1280,720)
    if photo == None:
        photo = Image.new("RGBA", photores, (0, 0, 0))
    pastepos = (int(photores[0]*0.078),int(photores[1]*0.1389))
    outputimg.paste(photo, pastepos, photo)
    draw = ImageDraw.Draw(outputimg)
    titlePos = (int(resolution[0]*0.5)-(len(Title)*10),int(resolution[1]*0.02))
    draw.text(titlePos, Title, fill=(255, 255, 255),stroke_width=1, stroke_fill=(0, 0, 0), font=Titlefont)
                            
    if not heartRateData is None:
        df_hr = convertRawRedisToDF(heartRateData,label="Heartrate")
        hrplot = GenerateMiniPlot(df_hr,dataMaxVal = 40,dataMinVal = 130,title="Heartrate")
        pastepos = (int(resolution[0]*0.7448),int(resolution[1]*0.08))
        outputimg.paste(hrplot, pastepos, hrplot)

    if not stepsData is None:
        df_st = convertRawRedisToDF(stepsData,label="Steps")
        stplot = GenerateMiniPlot(df_st,title= "Steps")
        pastepos = (int(resolution[0]*0.7448),int(resolution[1]*0.45))
        outputimg.paste(stplot, pastepos, stplot)
        
    return outputimg

def GenerateMiniPlot(df_data,dataMaxVal = None,dataMinVal = None,title="Mesurement"):
    textcolor = (0.9,0.9,0.9)
    fig = plt.figure(figsize=(5, 3))
    sns.set_style("darkgrid", {"axes.edgecolor":".9","grid.color": ".9","axes.facecolor": (63/255, 65/255, 85/255)})
    df_keys = df_data.keys()
    ax = sns.lineplot(data=df_data,color='black', x=df_keys[0], y=df_keys[1])
    ax.tick_params(axis='x', rotation=-45,labelcolor=textcolor)
    ax.tick_params(axis='y',labelcolor=textcolor)
    ax.set_title(title, color=textcolor)
    ax.set(xlabel=None)
    ax.set(ylabel=None)
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
    if (not dataMaxVal is None) and (not dataMinVal is None) > 0:
        plt.ylim(dataMaxVal, dataMinVal)
    byio = io.BytesIO()
    fig.patch.set_alpha(0)
    plt.savefig(byio, format="png",bbox_inches='tight')
    plt.close(fig)
    img = Image.open(byio).convert("RGBA")
    return img
    
def downloadImgbb(imgJson,saveToStreamLogs = True,finalimgsize=(1280,720)): # (1280,720)
    response = requests.get(imgJson['url'])
    outputimg = Image.new("RGBA", finalimgsize, (0, 0, 0))
    if response.status_code == 200:
        outcenter = (finalimgsize[0]/2,finalimgsize[1]/2)
        img = Image.open(io.BytesIO(response.content)).convert("RGBA")
        img = ImageOps.contain(img,finalimgsize)
        imgcenter = (img.size[0]/2,img.size[1]/2)
        pastepos = (int(outcenter[0]-imgcenter[0]),int(outcenter[1]-imgcenter[1]))
        outputimg.paste(img, pastepos, img)
        draw = ImageDraw.Draw(outputimg)
        fontsize = int(finalimgsize[0]*0.015)
        Rf = ImageFont.truetype('Roboto-Bold.ttf', fontsize)
        dt_obj = datetime.fromtimestamp(int(imgJson['timestamp']))
        format_string = "%d-%m-%Y %H:%M:%S"
        dt_str = dt_obj.strftime(format_string)
        txtpos = (finalimgsize[0]-int(finalimgsize[0]*0.15625),finalimgsize[1]-int(finalimgsize[1]*0.04630))
        draw.text(txtpos, dt_str, fill=(255, 255, 255),stroke_width=1, stroke_fill=(0, 0, 0), font=Rf)
    return outputimg
