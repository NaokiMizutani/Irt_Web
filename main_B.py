import cgi, io
import pyper as pr

html = '''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
<head>
<title>R from remote client</title>
</head>
<body>
<h1>リモートから R を動作させる</h1>
<form action="./main_B.py" method="post" AcceptEncoding="utf-8">
> <input type="text" name="text" size="70" />
<input type="submit" />
</form>
<br />
<hr />
<pre><code>
{0}
</code></pre>
</body>
</html>
'''

class R_Web(object):

    def __init__(self):
        self.R = pr.R()
        self.data = ''

    def __call__(self, environ, start_response):
        method = environ.get('REQUEST_METHOD')
        if method == "GET":
            output = html.format(self.data)
        elif method == "POST":
            form = cgi.FieldStorage(environ['wsgi.input'], environ=environ, keep_blank_values=True)
            command = form['text'].value
            if command == 'reset' or command == 'RESET':
                self.R = pr.R()
                self.data = ''
                command = "sessionInfo()"
            self.data += '> ' + command + '\n'
            self.data += self.R(command)
#            self.data += 'ObjectID of self : ' + str(id(self)) + '\n'

            output = html.format(self.data)
        else:
            start_response('501 Not Implemented', [('Content-type', 'text/plain')])
            return ['Not Implemented'.encode('utf-8')]

        status = '200 OK'
        response_headers = [('Content-type', 'text/html; charset=utf-8'),
                    ('Content-Length', str(len(output.encode('utf-8'))))]
        start_response(status, response_headers)
        return [output.encode('utf-8')]

application = R_Web()
