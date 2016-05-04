#!/usr/bin/python

import digitalocean
import time
import paramiko
import random
import string
import threading
link=['QrKBrf7wMp0','8Gml-qSwBj8','8Gml-qSwBj8','NnDruK2Oh8M','fRlXA45_pPc','8Gml-qSwBj8','8Gml-qSwBj8']
region=['tor1','nyc1','nyc2','nyc3','sfo1','lon1','ams2','ams3']

def process():
	counter=0
	while True:
		dropletName=''.join(random.SystemRandom().choice(string.ascii_letters) for _ in range(9))
		regionName=random.choice(region)
		try:
			droplet = digitalocean.Droplet(token="fbf35c63a278b8af1c078b9f8fcb8cdbf568c5c63d93544274ec73da39bf370f",name=dropletName,region=regionName,image='17892994',size_slug='512mb',ssh_keys=[2036926],backups=False)
			droplet.create()
			droplet.get_actions()[0].wait()
			droplet.load()
		except Exception as e:
			print('Error when create Droplet.')
			print(e)
			break
		ip=str(droplet.ip_address)
		sshcon = paramiko.SSHClient()
		sshcon.set_missing_host_key_policy(paramiko.AutoAddPolicy())
		while True:
			try:
				sshcon.connect(hostname=ip, username='root', key_filename='/home/ubuntu/workspace/digital')
				break
			except:
				continue
		listLink=','.join(random.sample(link,5));
		sshcon.exec_command('nohup bash -c \'wget --no-check-certificate http://duclvz.github.io/chrome.py -O chrome.py; chmod +x chrome.py; ./chrome.py -l "'+listLink+'"\' > out.log 2> err.log < /dev/null &')
		
		print('-------------')
		print('Created IP'+droplet.ip_address+' - '+dropletName+' - '+regionName)
		print('Connected IP '+ip)
		print('Watching around 5 video: '+listLink)
		counter=counter+1
		print('Total view: '+str(counter*5))
		time.sleep(300)
		sshcon.close()
		try:
			droplet.destroy()
			droplet.get_actions()[len(droplet.get_actions())-1].wait()
			time.sleep(15)
		except Exception as e:
			print('Error when destroy Droplet')
			print(e)
			break

t1=threading.Thread(target=process)
t2=threading.Thread(target=process)
t3=threading.Thread(target=process)
t4=threading.Thread(target=process)
t5=threading.Thread(target=process)
t6=threading.Thread(target=process)
t7=threading.Thread(target=process)
t8=threading.Thread(target=process)
t1.start()
t2.start()
t3.start()
t4.start()
t5.start()
t6.start()
t7.start()
t8.start()
t1.join()
t2.join()
t3.join()
t4.join()
t5.join()
t6.join()
t7.join()
t8.join()