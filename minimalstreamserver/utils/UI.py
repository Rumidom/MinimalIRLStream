import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import requests
from PIL import Image,ImageOps,ImageDraw,ImageFont
from datetime import datetime
import io
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

def drawDataBubble(data,label,offset=0,scale=1.0,iconpath='icons/steps.png'):
    img = Image.new("RGBA", (210,150),(255, 0, 0, 0))
    pos = (0,0)
    draw = ImageDraw.Draw(img)
    # Draw a rounded rectangle
    draw.rounded_rectangle((pos[0], pos[1], pos[0]+200, pos[1]+140),  outline="white",width=3, radius=10)
    icon = Image.open(iconpath)
    icon.thumbnail((50,50))
    fnt = ImageFont.truetype("Roboto-Bold.ttf", 30)
    draw.text((pos[0]+60,pos[1]+10), label, font=fnt, fill=(255, 255, 255))
    fnt = ImageFont.truetype("Roboto-Bold.ttf", 40)
    draw.text((pos[0]+30+offset,pos[1]+70), str(data), font=fnt, fill=(255, 255, 255))
    img.paste(icon, (pos[0], pos[1]))
    return img

def subtractConst(df,const):
    #df_hr.apply(lambda x:x-first_instance.to_numpy()[1])
    df[df.columns[1]] = df[df.columns[1]]-const
    return df
    
def GenerateFrame(Titlefont = Rf, stepsData = None,heartRateData = None,distanceData = None,Title = "IRL Stream" ,photo = None, resolution = res, bg_color = (16, 17, 24), startFromZero =False,init_dist= 0, init_steps = 0):
    outputimg = Image.new("RGBA", resolution, bg_color)
    photores = (1280,720)
    if photo == None:
        photo = Image.new("RGBA", photores, (0, 0, 0))
    pastepos = (int(photores[0]*0.078),int(photores[1]*0.1389))
    outputimg.paste(photo, pastepos, photo)
    draw = ImageDraw.Draw(outputimg)
    titlePos = (int(resolution[0]*0.4)-(len(Title)*10),int(resolution[1]*0.02))
    draw.text(titlePos, Title, fill=(255, 255, 255),stroke_width=1, stroke_fill=(0, 0, 0), font=Titlefont)
    
    if not heartRateData is None:
        if len(heartRateData) > 0: 
            df_hr = convertRawRedisToDF(heartRateData,label="Heartrate")
            hrplot = GenerateMiniPlot(df_hr,dataMaxVal = 40,dataMinVal = 130,title="Heartrate")
            pastepos = (int(resolution[0]*0.7448),int(resolution[1]*0.08))
            outputimg.paste(hrplot, pastepos, hrplot)
            last_hr = int(df_hr.nlargest(1, ['datetime'])['Heartrate'].iloc[0])
            heartratebubble = drawDataBubble(str(last_hr)+' bpm',"Heartrate",scale=1.0,iconpath='icons/chart.png')
            outputimg.paste(heartratebubble, (500,900), heartratebubble)
        
    if not stepsData is None:
        if len(stepsData) > 0: 
            df_st = convertRawRedisToDF(stepsData,label="Steps")
            if startFromZero:
                #print('test: ',init_steps)
                df_st = subtractConst(df_st,init_steps)
            stplot = GenerateMiniPlot(df_st,title= "Steps")
            pastepos = (int(resolution[0]*0.7448),int(resolution[1]*0.45))
            outputimg.paste(stplot, pastepos, stplot)
            last_steps = int(df_st.nlargest(1, ['datetime'])['Steps'].iloc[0])    
            stepsbubble = drawDataBubble(last_steps,"Steps",scale=1.0,iconpath='icons/steps.png')
            outputimg.paste(stepsbubble, (200,900), stepsbubble)

    if not distanceData is None:
        if len(distanceData) > 1: 
            df_dst = convertRawRedisToDF(distanceData,label="Distance")
            if startFromZero:
                df_dst = subtractConst(df_dst,init_dist)
            last_dst_2 = df_dst.nlargest(2, ['datetime'])
            last_dst = format(last_dst_2['Distance'].iloc[0]/1000, ".2f")
            timedelta = last_dst_2['datetime'].iloc[0] - last_dst_2['datetime'].iloc[1] 
            deltaSeconds = timedelta.total_seconds()
            if deltaSeconds == 0:
                deltaSeconds = 0.1
            distancebubble = drawDataBubble(last_dst+" Km","Distance",scale=1.0,iconpath='icons/distance.png')
            outputimg.paste(distancebubble, (800,900), distancebubble)
            deltaDist = last_dst_2['Distance'].iloc[0] - last_dst_2['Distance'].iloc[1] 
            deltaTime = last_dst_2['datetime'].iloc[0] - last_dst_2['datetime'].iloc[1] 
            speedbubble = drawDataBubble("{:.1f}".format(deltaDist/deltaSeconds)+" m/s","Speed",scale=1.0,iconpath='icons/speed.png')
            outputimg.paste(speedbubble, (1100,900), speedbubble)
        
    return outputimg

def GenerateMiniPlot(df_data,dataMaxVal = None,dataMinVal = None,title="Mesurement"):
    textcolor = (0.9,0.9,0.9)
    fig = plt.figure(figsize=(5, 3))
    sns.set_style("darkgrid", {'grid.linestyle': ':',"axes.edgecolor":".9","grid.color": ".9","axes.facecolor": (63/255, 65/255, 85/255)})
    df_keys = df_data.keys()
    ax = sns.lineplot(data=df_data,color='white', linewidth = 3,x=df_keys[0], y=df_keys[1])
    ax.tick_params(axis='x', rotation=-45,labelcolor=textcolor)
    ax.tick_params(axis='y',labelcolor=textcolor)
    ax.set_title(title, color=textcolor,fontsize=18,weight='bold')
    ax.set(xlabel=None)
    ax.set(ylabel=None)
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
    ax.tick_params(labelsize=15)
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
