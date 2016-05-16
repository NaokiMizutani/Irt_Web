import cgi

html = '''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
<head>
<title>テキスト入力フィールドに入力された文字を取得する</title>
</head>
<body>
<h1>テキスト入力フィールドに入力された文字を取得する</h1>
<p>入力された文字は、「%s」です。</p>
<form action="http://localhost/input.py" method="post" AcceptEncoding="utf-8">
<input type="text" name="text" />
<input type="submit" />
</form>
</body>
</html>
'''

def application(environ, start_response):
	method = environ.get('REQUEST_METHOD')
	data = ''
	if method == "GET":
		pass
	elif method == "POST":
		wsgi_input = environ.get('wsgi.input')
		form = cgi.FieldStorage(fp=wsgi_input, environ=environ, keep_blank_values=True)
#		for key in form:
#			data += "name:" + key + " value:" + form[key].value + "<br>"
		data = form['text'].value

	output = html % data
	status = '200 OK'
	response_headers = [('Content-type', 'text/html; charset=utf-8'),
				('Content-Length', str(len(output.encode('utf-8'))))]
	start_response(status, response_headers)
	return [output.encode('utf-8')]

