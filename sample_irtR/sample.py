import pyper as pr
import re

r = pr.R()
r("library(ltm)")
r("data <- read.csv('irt_sample.csv', header=T)")
r("model2 <- ltm(data~z1)")
text = r("model2")
print("=== Results from R ===")
print(text)
print("======================")

lines = re.split('\n', text)
# print(lines)

data = []

mode = 0
for line in lines:
  if mode == 0:
    m = re.search('Dffclt\s+Dscrmn', line)
    if m:
      mode = 1
      print('\n' + 'Name   ' + m.group())
  elif mode == 1:
    m = re.search('(?P<Name>[\w\.]+)\s+(?P<Dffclt>\-*[0-9]*\.*[0-9]*)\s+(?P<Dscrmn>[0-9]*\.*[0-9]*)\s*', line)
    if m:
      print(m.group('Name') + ' --- ' + m.group('Dffclt') + ' --- ' + m.group('Dscrmn'))
      data.append({'Name': m.group('Name'), 'Dffclt': float(m.group('Dffclt')), 'Dscrmn': float(m.group('Dscrmn'))})

print('\n' + "=== python dict-list for next process ===")
print(data)
print("=========================================")
