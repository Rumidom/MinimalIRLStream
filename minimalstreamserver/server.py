import FreeSimpleGUI as sg
from io import BytesIO
import time
from utils.rediscloud import RedisController
import utils.UI as ui
from datetime import datetime
import os
import ffmpeg
import os 
import gc
import psutil
from utils.anonpill import getImgAnonymized
import json
import os


startFromZero = True
last_Img = None
StartingDateTime = datetime.now()
foldername = StartingDateTime.strftime("Session_%Y-%m-%d_%H_%M_%S")
loglist = []
settings = {"redisServer": "", "redisPort": "", "redisUser": "", "redisPassword": "", "BBimgKey": "", "startFromZeroSteps": True, "saveFrames": True}
disablestart = False
rds = None

if os.path.exists('settings.json'):
    with open('settings.json') as f:
        settings = json.load(f)
    loglist.append("Settings file found")
else:
    loglist.append("Settings file not found, please set settings")
    disablestart = True


mem = psutil.virtual_memory()

tab_layout1 = [
    [sg.Image('test_img.png', expand_x=True, expand_y=True,key = "-IMAGE-")],
    [sg.Multiline(default_text="/".join(loglist),size=(30, 5),disabled = True, autoscroll = True, key='-MLINE-')],
    [sg.Button('Start',key='-START-',disabled = disablestart),sg.Button('Stop',key='-STOP-',disabled=True), sg.Button('Generate Video', disabled=False,key='-GENVIDEO-'),sg.InputText(key='-IMAGESFOLDERINPUT-', enable_events=True),sg.FolderBrowse('select folder',key='-FOlDERBROWSER-')],
]

tab_layout2 = [
    [sg.Text("Step/Distance: ")],
    [sg.Checkbox('Start from zero steps', default=settings['startFromZeroSteps'],enable_events=True, key='-STARTFROMZEROSTEPS-')],
    [sg.Text("Video Generation: ")],
    [sg.Checkbox('Save Frames (Needed to Generate Video)', default=settings['saveFrames'],enable_events=True, key='-SAVEFRAMES-')],
    [sg.Text("Cloud db settings: ")],
    [sg.Text("Redis Server: "),sg.InputText(default_text=settings['redisServer'],key='-REDISSERVER-', enable_events=True)],
    [sg.Text("Redis Port: "),sg.InputText(default_text=settings['redisPort'],key='-REDISPORT-', enable_events=True)],
    [sg.Text("Redis Server User: "),sg.InputText(default_text=settings['redisUser'],key='-REDISUSER-', enable_events=True)],
    [sg.Text("Redis Server Password: "),sg.InputText(default_text=settings['redisPassword'],key='-REDISPASS-', enable_events=True)],
    [sg.Text("BBimg key: "),sg.InputText(settings['BBimgKey'],key='-BBIMGKEY-', enable_events=True)],  
    [sg.Button('Save settings',key='-SAVESETTINGS-')]   
    ]

layout = [[sg.TabGroup([[sg.Tab("Stream", tab_layout1), sg.Tab("Stream Settings", tab_layout2)]])]]

window = sg.Window('MIRL Server', layout, keep_on_top=True,finalize=True)
window['-MLINE-'].expand(expand_x=True)
event, values = window.read(timeout=10)


def generate_video(foldername):
    ffmpeg.input(foldername+'/*.png', pattern_type='glob', framerate=1).output(foldername+'.mp4',loglevel="quiet").run(overwrite_output=True)

def logdata(msg):
    loglist.append(msg)
    if len(loglist) > 100:
        loglist.pop()

def saveImage(im):
    current_datetime = datetime.now()
    timestamp = current_datetime.timestamp()
    if not os.path.exists(foldername):
        os.makedirs(foldername)
    im.save(foldername+"/"+str(timestamp)+".png")

def checkDict(di):
    for key in di:
        if len(di[key]) != 0:
            return True
    return False

def StartServer():
    logdata('Starting')
    print('Starting')
    rds = RedisController(
    settings['redisServer'],# 'redis-15456.c308.sa-east-1-1.ec2.redns.redis-cloud.com',
    int(settings['redisPort']),# 15456
    settings['redisUser'],# streamingserver
    settings['redisPassword'],# E-5X|?]B2:Cy0Lso]"_|PqlE*
    settings['BBimgKey'],#40c55ae70e20ccebe2d7e90343434180
    )
    if rds.flushServer():
        logdata('Server flushed.')
    else:
        logdata('Error flushing server')
    
    if rds.initStremingServer():
        logdata('Server initiated')
        print('Server initiated')
    else:
        logdata('Server init faild')
        print('Server init faild')
    
    logdata('Time: ' + StartingDateTime.strftime("%Y-%m-%d %H:%M:%S"))
    return rds
    

DataDict = {'steps':[],'distance':[],'heartrates':[]}
print("Data: ", DataDict)
init_steps = None
init_dist = None
pubSubListening = False
message = None
anonymize = True

while True:
    event, values = window.read(timeout=10)
    
    if event != '__TIMEOUT__':
        #print(event," : ",values)
        pass

    if event == sg.WINDOW_CLOSED:
        break
    
    if event == '-SAVESETTINGS-':
        setingsDict = {"redisServer":values['-REDISSERVER-'],
                       "redisPort":values['-REDISPORT-'],
                       "redisUser":values['-REDISUSER-'],
                       "redisPassword":values['-REDISPASS-'],
                       "BBimgKey":values['-BBIMGKEY-'],
                       "startFromZeroSteps":values['-STARTFROMZEROSTEPS-'],
                       "saveFrames":values['-SAVEFRAMES-']
                       }

        with open('settings.json', 'w') as f:
            json.dump(setingsDict, f)

    if event == '-IMAGESFOLDERINPUT-':
        #print(event,values)
        window['-IMAGESFOLDERINPUT-'].Update(values['-IMAGESFOLDERINPUT-'].split("/")[-1])

    if event == '-GENVIDEO-':
        #print(values)
        logdata('Generating Video')
        generate_video(values['-IMAGESFOLDERINPUT-'])

    if event == '-START-':
        rds = StartServer()
        pubSubListening = True
        window['-START-'].update(disabled=True)
        window['-STOP-'].update(disabled=False)
        window['-GENVIDEO-'].update(disabled=True)
        window['-IMAGESFOLDERINPUT-'].Update(foldername)

    if event == '-STOP-':
        DataDict = {'steps':[],'distance':[],'heartrates':[]}
        window['-IMAGE-'].update('test_img.png', size=(1024,512))
        
        pubSubListening = False
        window['-START-'].update(disabled=False)
        window['-STOP-'].update(disabled=True)
        if os.path.isdir(foldername):
            window['-GENVIDEO-'].update(disabled=False)
        
    if pubSubListening:
        message = rds.get_message()

    if message:
        
        #print(message)
        key = message['channel'].split('__keyspace@0__:')[1]  
        if message['data'] == 'lpush':
            dataUpdate = rds.getLastDataUpdate(key)
            if dataUpdate != None:
                logdata(str(key)+":"+str(dataUpdate))
                rds.addData(DataDict[key],dataUpdate)
                if key == 'distance' and init_dist == None:
                    init_dist = int(dataUpdate.split(",")[1])
                if key == 'steps' and init_steps == None :
                    init_steps = int(dataUpdate.split(",")[1])

        elif message['data'] == 'hset':

            if key == 'imMetaDataJson':
                imJSON = rds.getImgJson()
                logdata('URL: '+imJSON['url']+'Timestamp: '+imJSON['timestamp']) 
                last_Img = ui.downloadImgbb(imJSON,saveToStreamLogs = True,finalimgsize=(1280,720))
            if anonymize:
                last_Img = getImgAnonymized(last_Img).convert("RGBA")

        if len(loglist) > 0:
            #print(loglist)
            window['-MLINE-'].update('\n'.join(loglist))

        if checkDict(DataDict):
            frame = ui.GenerateFrame(distanceData = DataDict['distance'],heartRateData=DataDict['heartrates'],stepsData=DataDict['steps'],photo=last_Img,startFromZero = settings['startFromZeroSteps'], init_dist= init_dist, init_steps = init_steps)
            if settings['saveFrames']:
                saveImage(frame)
            frame.thumbnail((1024, 512))
            window['-IMAGE-'].update(data=ui.image_to_data(frame), size=(1024,512))
        
        #print("gc: ",gc.collect(), "Free Mem: ",mem.free)
        gc.collect()
        
window.close()