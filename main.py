import os
import time 
import sys

while(True):
    try:
        x = os.environ['TWORPTEST']
        
    except:
        x = "A variável de ambiente não foi encontrada"
        
    print(x, file = sys.stderr)
    time.sleep(20)
    
