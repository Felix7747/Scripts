# A Python script to detect the files in a folder which are actually encoded as PNG and rename the extension as .PNG.
# Information taken from these two pages and merged to create this.
#
#
# https://stackoverflow.com/questions/11310220/why-am-i-getting-the-error-not-a-jpeg-file-starts-with-0x89-0x50
# https://stackoverflow.com/questions/2900035/changing-file-extension-in-python

import glob
import os
import re
import logging
import traceback

filelist=glob.glob("*.jpg")
for file_obj in filelist:
	try:
		jpg_str=os.popen("file \""+str(file_obj)+"\"").read()
		if (re.search('PNG image data', jpg_str, re.IGNORECASE)) or (re.search('Png patch', jpg_str, re.IGNORECASE)):
			print("Renaming jpg as it contains png encoding - "+str(file_obj))
			base = os.path.splitext(file_obj)[0]
			print("Has base "+str(base))
			os.rename(file_obj, base + ".png")
	except Exception as e:
		logging.error(traceback.format_exc())
print("Cleaning PNG's done")
