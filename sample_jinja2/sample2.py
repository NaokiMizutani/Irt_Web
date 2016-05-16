import math
from jinja2 import Environment, FileSystemLoader

class AppSample(object):

    def __init__(self):
        pass

    def __call__(self, environ, start_response):
        method = environ['REQUEST_METHOD']
        if method == 'GET':
            return self.message1(environ, start_response)
        else:
            start_response('501 Not Implemented', [('Content-type', 'text/plain')])
            return 'Not Implemented'

    def message1(self, environ, start_response):

        env = Environment(loader=FileSystemLoader('/var/www/html/', encoding='utf8'))
        template = env.get_template('template.html')
        
        selection_color = ["color: 'rgba(255,    0,    0, 1.0)',\n", 
        		   "color: 'rgba(  0,  255,    0, 1.0)',\n", 
        		   "color: 'rgba(  0,    0,  255, 1.0)',\n", 
        		   "color: 'rgba(  0,  255,  255, 1.0)',\n", 
        		   "color: 'rgba(255,    0,  255, 1.0)',\n", 
        		   "color: 'rgba(255,  255,    0, 1.0)',\n", 
        		   "color: 'rgba(128,    0,    0, 1.0)',\n", 
        		   "color: 'rgba(  0,  128,    0, 1.0)',\n", 
        		   "color: 'rgba(  0,    0,  128, 1.0)',\n", 
        		   "color: 'rgba(100,  100,  100, 1.0)',\n"]
        
        insert_text = ''
        tab = ' ' * 4
        
        case_list = [["Data1", 1.0, 0.0],
                     ["Data2", 2.0, -0.5],
                     ["Data3", 3.0, 0.3],
        	     ["Data4", 4.0, -2.0],
                     ["Data5", 5.0, 1.5],
                     ["Data6", 6.0, 0.7],
        	     ["Data7", 7.0, -1.5],
                     ["Data8", 8.0, 0.8],
                     ["Data9", 9.0, 1.2],
        	     ["Data10", 10.0, -0.7]]
        
        val_D = 1.701
        for n in range(len(case_list)):
            case = case_list[n]
            val_a = case[1] 
            val_b = case[2]
            insert_text += tab*2 + "{\n"
            insert_text += tab*3 + "name: '{0}: ({1:5.3f}, {2:5.3f})',\n".format(case[0], val_a, val_b)
            insert_text += tab*3 + selection_color[n]
            insert_text += tab*3 + "data: [\n"
            for ntheta in range(-40, 41, 1):
                val_theta = ntheta / 10.0
                val_prob = 1.0 / (1.0 + math.exp(- val_D * val_a * (val_theta - val_b))) 
                if ntheta == 40:
                    insert_text += (tab*4 + "[{0:3.1f},{1:5.3f}]\n".format(val_theta, val_prob))
                else:
                    insert_text += (tab*4 + "[{0:3.1f},{1:5.3f}],\n".format(val_theta, val_prob))
            insert_text += tab*3 + "]\n"
            if n == len(case_list) - 1:
                insert_text += tab*2 + "}\n"
            else:
                insert_text += tab*2 + "},\n"
        text = template.render({'data_contents': insert_text})
        
        start_response('200 OK', [('Content-type', 'text/html; charset=utf-8')])

        return [text.encode('utf-8')]


application = AppSample()


