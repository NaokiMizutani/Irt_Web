import cgi
from tempfile import TemporaryFile

html_head = '''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
'''

html_get = '''<head>
<title>ファイル・アップロードのテスト</title>
</head>
<body>
<h1>ファイル・アップロード操作画面</h1>
<form action="http://localhost/upload.py" method="post" enctype="multipart/form-data">
--- Select File and Push Upload-Button --- <br /><br />
<input type="file" name="upfile" size="50" /><br /><br />
<input type="submit" value=" Upload " />
</form>
</body>
</html>
'''

html_post = '''<head>
<title>ファイル・アップロードのテスト</title>
</head>
<body>
<h1>アップロードされたファイルの内容</h1>
--- Uploaded Text --- <br /><br />
<p>%s</p>
</body>
</html>
'''

def application(environ, start_response):
	method = environ.get('REQUEST_METHOD')
	data = ''
	if method == "GET":
		output = html_head + html_get
	elif method == "POST":
		form = cgi.FieldStorage(environ['wsgi.input'], environ=environ, keep_blank_values=True)
		data = form.getvalue('upfile', '').decode('utf-8')
		output = html_head + html_post % data
		outf = open('/tmp/tmp.txt', 'w')
		outf.write(data)
		outf.close()
	status = '200 OK'
	response_headers = [('Content-type', 'text/html; charset=utf-8'),
				('Content-Length', str(len(output.encode('utf-8'))))]
	start_response(status, response_headers)
	return [output.encode('utf-8')]

