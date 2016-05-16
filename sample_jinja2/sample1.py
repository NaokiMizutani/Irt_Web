import csv
from jinja2 import Environment, FileSystemLoader
env = Environment(loader=FileSystemLoader('./', encoding='utf8'))
template = env.get_template('template.txt')

dictlist = []
with open('data.csv', 'r') as f:
    reader = csv.reader(f)
    header = next(reader)
    for row in reader:
        dictlist.append({'year_w': row[0], 'year_j': row[1], 'eto': row[2], 'eto_yomi': row[3] })

text = template.render({'datadict': dictlist})

print(text)

