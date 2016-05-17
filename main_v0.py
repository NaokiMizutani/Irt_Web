import cgi, re, math
import pyper as pr
from jinja2 import Environment, FileSystemLoader
from tempfile import TemporaryFile

html = '''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
<head>
<title>分析対象ファイルのアップロード</title>
</head>
<body>
<h1>ファイル・アップロード操作画面</h1>
<form action="./main_v0.py" method="post" enctype="multipart/form-data">
--- Select File and Push Upload-Button --- <br /><br />
<input type="file" name="upfile" size="50" /><br /><br />
<input type="submit" value=" Upload " />
</form>
</body>
</html>
'''

class Irt_Web(object):

    def __call__(self, environ, start_response):
        method = environ.get('REQUEST_METHOD')
        data = ''
        if method == "GET":
            output = html
        elif method == "POST":
            form = cgi.FieldStorage(environ['wsgi.input'], environ=environ, keep_blank_values=True)
            data = form.getvalue('upfile', '').decode('utf-8')
            outf = open('/tmp/tmp.txt', 'w')
            outf.write(data)
            outf.close()

            param_list = self.irt_analysis()
            output = self.graphhtml(param_list)
        else:
            start_response('501 Not Implemented', [('Content-type', 'text/plain')])
            return ['Not Implemented'.encode('utf-8')]

        status = '200 OK'
        response_headers = [('Content-type', 'text/html; charset=utf-8'),
                    ('Content-Length', str(len(output.encode('utf-8'))))]
        start_response(status, response_headers)
        return [output.encode('utf-8')]

    def irt_analysis(self):
        r = pr.R()
        r("data <- read.csv('/tmp/tmp.txt', header=T)")
        r("require('ltm')")
        r("model2 <- ltm(data~z1)")
        summary = r("summary(model2)")
        
        text = r("model2")
        lines = re.split('\n', text)
        
        data = []
        mode = 0
        for line in lines:
            if mode == 0:
                m = re.search('Dffclt\s+Dscrmn', line)
                if m:
                    mode = 1
            elif mode == 1:
                m = re.search('(?P<Name>[\w\.]+)\s+(?P<Dffclt>\-*[0-9]*\.*[0-9]*)\s+(?P<Dscrmn>[0-9]*\.*[0-9]*)\s*', line)
                if m:
                    data.append([m.group('Name'), float(m.group('Dffclt')), float(m.group('Dscrmn'))])
        
        return([summary, data])
        
    def graphhtml(self, results):

        result_text = results[0]
        case_list = results[1]
        
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

        val_D = 1.701
        for n in range(len(case_list)):
            case = case_list[n]
            val_a = case[2] 
            val_b = case[1]
            insert_text += tab*2 + "{\n"
            insert_text += tab*3 + "name: '{0}: ({1:5.3f}, {2:5.3f})',\n".format(case[0], val_a, val_b)
            insert_text += tab*3 + selection_color[n%10]
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
        text = template.render({'data_contents': insert_text, 'r_summary': result_text})

        return text


application = Irt_Web()
