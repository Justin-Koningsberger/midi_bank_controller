import sys
import mido

names = mido.get_input_names()

print "Found the following inputs:"
print names
print "Selecting the following input:"
print names[1]
sys.stdout.flush()

with mido.open_input(names[1]) as inport:
	for msg in inport:
		print(msg)
		sys.stdout.flush()
