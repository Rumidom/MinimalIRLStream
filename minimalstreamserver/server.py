import FreeSimpleGUI as sg
from io import BytesIO
import time
import utils.redisfunc as rds
import utils.UI as ui
from datetime import datetime
import os

print('Starting')

layout = [
    [sg.Image('test_img.png', expand_x=True, expand_y=True,key = "Image")]
]

window = sg.Window('MIRL Server', layout, keep_on_top=True)
last_Img = None
save_images = True
clear_day = True
StartingDateTime = datetime.now()
foldername = StartingDateTime.strftime("SessionImages_%Y-%m-%d_%H_%M_%S")

def saveImage(im):
    current_datetime = datetime.datetime.now()
    timestamp = current_datetime.timestamp()
    if not os.path.exists(foldername):
        os.makedirs(foldername)
    im.save(foldername+"/"+str(timestamp)+".png")

def checkDict(di):
    for key in di:
        if len(di[key]) == 0:
            return False
    return True
    
print('Starting')
print('Time: ' + StartingDateTime.strftime("%Y-%m-%d %H:%M:%S"))
if rds.flushServer():
    print('Server flushed.')
else:
    print('Error flushing server')
print('Seting BBImg')
rds.setbbimgKey()


DataDict = {'steps':rds.getData(rds.r,'steps'),'distance':rds.getData(rds.r,'distance'),'heartrates':rds.getData(rds.r,'heartrates')}
print("Data: ", DataDict)
while True:
    message = rds.p.get_message()
    event, values = window.read(timeout=10)
    
    if event == sg.WINDOW_CLOSED:
        break
    
    if message:
        #print(message)
        key = message['channel'].split('__keyspace@0__:')[1]  
        if message['data'] == 'lpush':
            dataUpdate = rds.getLastDataUpdate(rds.r,key)
            print(key,":",dataUpdate)
            if dataUpdate != None:
                rds.addData(DataDict[key],dataUpdate)
        elif message['data'] == 'hset':
            if key == 'imMetaDataJson':
                imJSON = rds.getImgJson()
                print('URL: ',imJSON['url'],'Timestamp: ',imJSON['timestamp']) 
                last_Img = ui.downloadImgbb(imJSON,saveToStreamLogs = True,finalimgsize=(1280,720))
        
        if checkDict(DataDict):
            frame = ui.GenerateFrame(distanceData = DataDict['distance'],heartRateData=DataDict['heartrates'],stepsData=DataDict['steps'],photo=last_Img)
            frame.thumbnail((1024, 512))
            saveImage(frame)
            window['Image'].update(data=ui.image_to_data(frame), size=(1024,512))

    else:
        time.sleep(0.01)

window.close()