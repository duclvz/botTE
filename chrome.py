#!/usr/bin/python

import sys, getopt

links=[]

try:
    myopts, args = getopt.getopt(sys.argv[1:],"l:u:p:")
except getopt.GetoptError as e:
    print (str(e))
    print("Usage: %s -l <link>" % sys.argv[0])
    sys.exit(2)
for o, a in myopts:
    if o == '-l':
        links=a.split(',')

from pyvirtualdisplay import Display
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
import time
import random
import string
display = Display(visible=0, size=(1280, 720))
display.start()

youtube = None

def playVideo(link):
    youtube.get('https://www.youtube.com/watch?v='+link)
    print('Started Video - div[aria-label="Play"]')
    time.sleep(3)
    print('Viewing video Url: '+youtube.current_url)
    youtube.save_screenshot('screenie.png')
    i = 0
    while i < 120:
        try:
            time.sleep(7)
            i=i+5
            youtube.find_element_by_css_selector('div.videoAdUiVisitAdvertiserLinkText').click()
            youtube.save_screenshot('screenie2.png')
        except:
            print('Error when click ads')
# Loop
for x in xrange(0,len(links)):
    print('--------------')
    desktopOption = Options()
    desktopOption.add_argument('--user-data-dir="/root/chromeTE"')
    desktopOption.add_argument("--no-sandbox")
    desktopOption.add_argument("--disable-setuid-sandbox")
    desktopOption.add_argument('--user-agent='+"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36")
    youtube = webdriver.Chrome(chrome_options = desktopOption)
    playVideo(links[x])
try:
    youtube.quit()
except:
    print('Error when quit Chrome')
display.stop()
print('Stopped Chrome Selenium and Xvfb')